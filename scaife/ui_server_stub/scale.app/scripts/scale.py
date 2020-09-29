
#
# Useful routines for the SCALe Python modules
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

import sys
import csv
import urllib
import re
import sqlite3 as sqlite


# For SQLite debugging, try: .log sqlite.error.log
SQL_Begin = """
.log off
PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
"""

SQL_End = "Commit;"


#
# Converts a string to a CSV-style quoted string
#
def CSV_Quote(text):
    text = Unquote(text.strip())
    if text == "" or text == "NULL":
        return "NULL"
    elif re.match(r"^[0-9.]+$", text):
        return text
    elif text.startswith('"') and text.endswith('"'):
        return text
# unnecessary since we use double quotes:
#    text = "''".join(text.split("'"))
    text = '""'.join(text.split('"'))
    text = '"' + text + '"'
    return text


def Unquote(text):
    text = text.strip()
    if len(text) == 0:
        return text
    while (text[0] == '"' and text[-1] == '"') or \
          (text[0] == "'" and text[-1] == "'"):
        text = text[1:-1]
        if len(text) == 0:
            return text
    return text


Table_Format_Choices = ["csv", "org"]
Link_Format_Choices = ["none", "html", "excel", "org"]

# Reads input from stream; returns list of fields
# if input_format is "csv", input is comma-separated values
# if input format is "org", input is ORG-style (pipe-separated values)


def Read_Fields(input_format="csv", stream=sys.stdin):
    if input_format == "csv":
        reader = csv.reader(stream, "excel")
    else:
        reader = stream

    for line in reader:
        if input_format != "csv":
            new_fields = []
            line = line.split("|")[1:-1]
            for field in line:
                new_fields.append(field.replace("BAR", "|"))
            line = new_fields
        yield line


def Read_Header(input_format="csv", stream=sys.stdin):
    for line in stream:
        if input_format == "csv":
            if line.strip().strip(",") == "":
                return
        else:
            if line.startswith("|-") or not line.startswith("|"):
                return


def Write_Fields(fields, output_format="csv", stream=sys.stdout):
    if output_format == "csv":
        new_fields = []
        for field in fields:
            # field = field.encode('utf-8')
            new_fields.append(CSV_Quote(field))
        print ",".join(new_fields)
    else:
        new_fields = []
        for field in fields:
            # field = field.encode('utf-8')
            new_fields.append(field.replace("|", "BAR"))
        print >> stream, "|" + "|".join(new_fields) + "|"


def Write_Header(fields, output_format="csv", stream=sys.stdout):
    Write_Fields(fields, output_format, stream)
    if output_format == "csv":
        print >> stream
    else:
        print >> stream, "|-"


Flag_Map = ["", "x"]
Verdict_Map = ["Unknown", "Complex", "False", "Dependent", "True"]
Level_Map = ["Dummy", "Low", "Medium", "High"]

#
# Creates an org-style link from a path + line
#


def Build_Link(path, line, link_format, prefix):
    if link_format == "none":
        return ""

    # We need to know the filename, and a string-based line is helpful too
    filename = path
    tail = filename.rfind("/")
    if tail != -1:
        filename = filename[tail + 1:]
    line = unicode(line)

    if link_format == "org":
        return "[[file:" + path + "::" + line + \
            "][" + filename + ":" + line + "]]"

    # We need to know details about the HTML global file

    if Build_Link.Global_File_Map is None:
        Build_Link.Global_File_Map = dict()
        for entry in urllib.urlopen(prefix + "/HTML/FILEMAP"):
            fields = entry.split()
            Build_Link.Global_File_Map[fields[0]] = fields[1]

    html_path = Build_Link.Global_File_Map[path]

    if link_format == "html":
        return prefix + "/HTML/" + html_path + "#L" + line

    if link_format == "excel":
        return '"=HYPERLINK(""' + prefix + "/HTML/" \
            + html_path + "#L" + line + '"",""Link"")"'

Build_Link.Global_File_Map = None


def find_new_id(con, id, table):
    while con.execute("SELECT * FROM " + table + " WHERE id=?",
                      [id]).fetchone() is not None:
        id += 1
    return id
