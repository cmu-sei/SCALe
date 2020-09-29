#!/usr/bin/env python
#
# 1st arg is the tool id
# 2nd arg is the tool name
# 3rd arg is a colon-separated path list of source directories to search for the files
# 4th arg is a colon-separated substitution list, of the form
# <path>=<path>. If any path begins with a left path in the arglist,
# it is replaced with the right path, and tried again.
# 5th arg is the input file containing an org table
# 6th arg is the platform
# 7th arg is the SCALe database
#
# <legal>
# SCALe version r.6.2.2.2.A
# 
# Copyright 2020 Carnegie Mellon University.
# 
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING
# INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON
# UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR
# IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF
# FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS
# OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT
# MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT,
# TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# 
# Released under a MIT (SEI)-style license, please see COPYRIGHT file or
# contact permission@sei.cmu.edu for full terms.
# 
# [DISTRIBUTION STATEMENT A] This material has been approved for public
# release and unlimited distribution.  Please see Copyright notice for
# non-US Government use and distribution.
# 
# DM19-1274
# </legal>

from collections import Counter
import os, sys, re, csv
import scale
import match_paths
import glob
import sqlite3

import bootstrap
from fastavro._schema import path

from bootstrap import VERBOSE

def get_checkers_from_db(database, tool):
    all_checkers = {}
    checker_regexes = []

    con = sqlite3.connect(database)
    con.text_factory = str
    with con:
        cur = con.cursor()
        cur.execute("SELECT * FROM Checkers where tool_id = ?", (tool.id_,))
        for record in cur.fetchall():
            checker_id = record[0]
            checker_name = record[1]
            #tool = record[2]
            is_regex = record[3]
            all_checkers[checker_name] = checker_id
            if is_regex:
                checker_regexes.append(checker_name)
    return all_checkers, checker_regexes


def get_special_checkers(tool):
    special_checkers = {}

    for platform in tool.platforms:
        property_files = bootstrap.properties_files(tool)
    
        if not property_files:
            print("No checkers exist for " + platform + "." + tool.name + " v." + tool.version)

        for file_path in property_files:
            if "regex" in file_path:
                is_regex = True
            else:
                is_regex = False 
           
            input_file = open(file_path, "r")

            for line in input_file:
                line = line.strip()
                # Skip comments and blank lines
                if("" == line or "#" == line[0]):
                    continue

                temp = line.split(":")
                checker = temp[0].strip()
                condition = temp[1].split(",")
                first_entry = condition[0].strip()
 
                if(first_entry == "SPECIAL"):
                    special_checkers[checker] = is_regex
        
    return special_checkers


def get_checker_id(checker_name, primary_msg_text, checkers_to_fix, all_checkers, checker_regexes):
    checker_id = None
    if ("" == checker_name or checker_name in checkers_to_fix):
        # Fix checkers that are blank or map to "SPECIAL"
        for checker_name in checker_regexes:
            try:
                if re.match(checker_name, primary_msg_text):
                    checker_id = str(all_checkers[checker_name])
                    break
            except re.error:
                pass
    if ("" != checker_name and checker_name in all_checkers):
        checker_id = str(all_checkers[checker_name])
    return checker_id


def find_new_id(con, record_id, table):
    sql = "SELECT * FROM " + table + " WHERE id=?"
    while con.execute(sql, (record_id,)).fetchone() is not None:
        record_id += 1
    return record_id


def insert_new_checker(con, name, tool_id, regex, scaife_checker_id):
    sql = "SELECT id FROM Checkers WHERE name=? AND tool_id=?"
    checker_id = con.execute(sql, (name, tool_id)).fetchone()
    if checker_id is not None:
        return checker_id[0]
    
    con.execute("INSERT INTO Checkers VALUES(?,?,?,?,?);",
                  [checker_id, name, tool_id, regex, scaife_checker_id]
               ) 
    sql = "SELECT id FROM Checkers WHERE name=? AND tool_id=?"
    checker_id = con.execute(sql, (name, tool_id)).fetchone()
    return checker_id[0]


def insert_alerts(tool, src_dirs, input_file, database):
    tool_id = tool.id_
    initial_id_value = tool_id
    checkers_to_fix = get_special_checkers(tool)
    primary_message_id = initial_id_value
    new_checker_id = initial_id_value
    alert_id = initial_id_value
    incr = 1000
    
    path_map, unix_path_map = match_paths.fill_path_map(src_dirs)

    # Get mapping of checker names to checker ids
    all_checkers, checker_regexes = get_checkers_from_db(database, tool)

    unmapped_checkers = set()
    unmapped_paths = set()

    def _partition(arr, n):
        for i in range(0, len(arr), n):
            yield arr[i:i + n]
    
    with sqlite3.connect(database) as con:
        con.text_factory = str
        cur = con.cursor()

        input_file = open(input_file, "r")
        tsv_reader = csv.reader(input_file, delimiter='\t')

        for fields in tsv_reader:
            if not fields:
                continue
            alert_id = find_new_id(cur, alert_id, "Alerts")
            primary_msg_id = find_new_id(cur, primary_message_id, "Messages")
            primary_msg_text = unicode(fields[3].strip(), "utf-8")
            checker_name = fields[0].strip()
            checker_id = get_checker_id(checker_name, primary_msg_text,
                checkers_to_fix, all_checkers, checker_regexes)
            if(checker_id is None):
                unmapped_checkers.add(checker_name)
                checker_id = insert_new_checker(con, checker_name, tool_id, False, None)


            scaife_alert_id = None
            cur.execute("INSERT INTO Alerts VALUES(?,?,?,?);",
                         [alert_id, checker_id, primary_message_id, scaife_alert_id]
                        ) 

            msg_index = 1
            while msg_index < len(fields) - 1:
                path = fields[msg_index].strip()

                path_found = match_paths.find_filepath(path, path_map, unix_path_map)
                
                if (not path_found):
                    unmapped_paths.add(path)
                else:
                    path = path_found
                    

                line_number = fields[msg_index + 1]
                message = fields[msg_index + 2]

                if sys.version_info[0] < 3:
                    #Python 2
                    message = unicode(message, "utf-8")

                sql = """
                INSERT INTO Messages
                  (id, project_id, alert_id, path, line, link, message)
                  VALUES(?,?,?,?,?,?,?)
                """.strip()
                msg_fields = [primary_message_id,
                              0,      # external project constant
                              alert_id,
                              path,
                              line_number,    
                              "",     # link
                              message]
                try:
                    cur.execute(sql, msg_fields)
                except:
                    raise Exception ("Cannot insert the following record into Messages:\n" + str(msg_fields))

                primary_message_id += incr
                msg_index += 3 # This increment is necessary, because of the way secondary messages are represented
            alert_id += incr

    input_file.close()

    if unmapped_paths:
        print("[Warning] %d path(s) not found in the provided source:" \
                % len(unmapped_paths))
        for path in unmapped_paths:
            print(path)

    if unmapped_checkers and VERBOSE:
        print("[Warning] %d checker(s) have no mappings associated with them:" \
                % len(unmapped_checkers))
        print("(" + ", ".join(unmapped_checkers) + ")")

def get_arguments():
    parser = argparse.ArgumentParser(description="Insert alerts into DB")
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    parser.add_argument("-i", "--tool-id", type=int,
            help="Number indicating valid tool & platform", required=True)
    parser.add_argument("-V", "--tool-version", default=None,
            help="Tool version, if any")
    parser.add_argument("-s", "--src-dirs", action="append", required=True,
            help="Source directories")
    parser.add_argument("-t", "--tsv-file", required=True,
            help="Tab-separated input")
    parser.add_argument("database", required=True,
            help="Project database")
    return parser.parse_args()

if __name__ == "__main__":
    args = get_arguments()
    tool_id = args.tool_id
    tool_version = args.tool_version
    tool = bootstrap.Tool(tool_id, version=tool_version)
    src_dirs = args.src_dirs
    input_file = args.tsv_file
    database = args.database
    
    insert_alerts(tool, src_dirs, input_file, database)
