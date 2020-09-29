#!/usr/bin/env python

# Script takes SCALe database file as input, and updates output from a tool.
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

import argparse
import os, sys, re, json, subprocess, shutil
import sqlite3
from copy import copy
from timeit import default_timer as timer

import bootstrap
from init_project_db import create_project_db
SCRIPTS_DIR = bootstrap.scripts_dir

from bootstrap import VERBOSE

def clean_database(database, tool):
    start_time = timer()
    with sqlite3.connect(database) as con:
        cur = con.cursor()
        # clean all versions of the tool
        cur.execute("""
SELECT DISTINCT tool_id FROM Checkers
JOIN Tools ON Tools.id = Checkers.tool_id
WHERE Tools.name = ?
""".strip(), (tool.name,))
        tool_ids = [str(x[0]) for x in cur.fetchall()]
        in_str = ','.join(['?'] * len(tool_ids))
        if VERBOSE:
            print("Preparing for loading output from tool %s:%s (%d)" \
                % (tool.platform_str, tool.name, tool.id_))
            print("Cleaning database %s of alerts for tool %s:%s (%s)" \
                % (database, tool.platform_str, tool.name, ','.join(tool_ids)))
        if tool.platform_str != "metric":
            # metrics are cleaned by creation operation
            cur.execute("""
DELETE FROM Messages WHERE id IN
(SELECT Messages.id FROM Messages, Alerts, Checkers
 WHERE Messages.alert_id=Alerts.id
 AND Alerts.checker_id=Checkers.id
 AND Checkers.tool_id IN (%s))
""".strip() % in_str, tool_ids)
            cur.execute("""
DELETE FROM MetaAlerts WHERE id IN
(SELECT MetaAlerts.id FROM MetaAlerts,
  MetaAlertLinks, Alerts, Checkers
 WHERE MetaAlertLinks.alert_id=Alerts.id
 AND MetaAlertLinks.meta_alert_id=MetaAlerts.id
 AND Alerts.checker_id=Checkers.id
 AND Checkers.tool_id IN (%s))
""".strip() % in_str, tool_ids)
            cur.execute("""
DELETE FROM MetaAlertLinks WHERE alert_id IN
(SELECT Alerts.id FROM Alerts, Checkers
 WHERE Alerts.checker_id=Checkers.id
 AND Checkers.tool_id IN (%s))
""".strip() % in_str, tool_ids)
            cur.execute("""
DELETE FROM Alerts WHERE id IN
(SELECT Alerts.id FROM Alerts, Checkers
 WHERE Alerts.checker_id=Checkers.id
 AND Checkers.tool_id IN (%s))
""".strip() % in_str, tool_ids)
    if VERBOSE:
        end_time = timer()
        elapsed_time = str(round(end_time - start_time, 1))
        print(elapsed_time + " s to clean database\n")

def add_project_tool(database, tool):
    if VERBOSE:
        print("connecting to: %s" % database)
    with sqlite3.connect(database) as con:
        cur = con.cursor()
        sql = "SELECT COUNT(tool_id) FROM ProjectTools WHERE tool_id = ?"
        cur.execute(sql, [tool.id_])
        row = cur.fetchone()
        if not row[0]:
            sql = "INSERT INTO ProjectTools VALUES(0, ?)"
            cur.execute(sql, (tool.id_,))

def add_meta_alerts_and_determinations(database, tool):
    if VERBOSE:
        print("Creating meta-alerts")
        start_time = timer()

    con = sqlite3.connect(database)
    with con:
        cur = con.cursor()
        # analyze archive file extensions
        cur.execute("""
SELECT Messages.path
FROM Alerts
JOIN Messages ON Messages.id = Alerts.primary_msg
JOIN Checkers ON Checkers.id = Alerts.checker_id
WHERE Checkers.tool_id = ?
""".strip(), (tool.id_,))
        files = (r[0] for r in cur.fetchall())
        ext2lang, unknown_exts = bootstrap.code_archive_ext2lang_map(files)
        if unknown_exts:
            print("WARNING: Unknown file extensions, code language unknown: %s" % ','.join(sorted(unknown_exts)))
        meta_alerts = dict()
        tool_meta_alerts = dict()
        # Fill meta_alerts with info from all alerts lacking meta alerts
        # Oh...and create new MetaAlerts for each one
        det_cnt = 0
        ma_cnt = 0
        cur.execute("""
SELECT DISTINCT Messages.line, Messages.path,
                ConditionCheckerLinks.condition_id,
                MetaAlertLinks.meta_alert_id, Checkers.tool_id
FROM Alerts
JOIN Messages ON Messages.id = Alerts.primary_msg
JOIN Checkers ON Checkers.id = Alerts.checker_id
JOIN ConditionCheckerLinks ON ConditionCheckerLinks.checker_id = Checkers.id
LEFT JOIN MetaAlertLinks ON MetaAlertLinks.alert_id = Alerts.id
""".strip())
        for [line, path, condition_id, meta_alert, tool_id] in cur.fetchall():
            # Separate this tool's meta_alerts from the other meta_alerts
            if tool_id == tool.id_:
                tool_meta_alerts[(line, path, condition_id)] = meta_alert
            else:
                meta_alerts[(line, path, condition_id)] = meta_alert

        # Create a meta_alert if it doesn't already exist
        for (line, path, condition_id) in tool_meta_alerts:
            if (line, path, condition_id) not in meta_alerts:
                code_language = ''
                file_ext = os.path.splitext(path)[-1].lower()
                if file_ext.startswith('.'):
                    file_ext = file_ext[1:]
                code_language = ext2lang.get(file_ext, '')
                cur.execute(
                    "INSERT INTO MetaAlerts VALUES(NULL, ?, -1, 0, NULL, ?)", [condition_id, code_language])
                meta_alert = cur.lastrowid
                ma_cnt += 1
            else:
                meta_alert = meta_alerts[(line, path, condition_id)]

            meta_alerts[(line, path, condition_id)] = meta_alert

        # Now add meta-alert-links and determinations
        if VERBOSE:
            end_time = timer()
            elapsed_time = str(round(end_time - start_time, 1))
            print("%d meta-alerts added" % ma_cnt)
            print("%d determinations added" % det_cnt)
            print(elapsed_time + " s to create meta-alerts\n")
            start_time = timer()

        cur.execute("""
SELECT DISTINCT Alerts.id, Messages.line, Messages.path,
                ConditionCheckerLinks.condition_id
FROM Alerts
JOIN Messages ON Messages.id = Alerts.primary_msg
JOIN Checkers ON Checkers.id = Alerts.checker_id
JOIN ConditionCheckerLinks ON ConditionCheckerLinks.checker_id = Checkers.id
WHERE Checkers.tool_id = ?
        """.strip(), (tool.id_,))
        mal_cnt = 0
        for [alert_id, line, path, condition_id] in cur.fetchall():
            meta_alert = meta_alerts[(line, path, condition_id)]
            cur.execute("INSERT OR IGNORE INTO MetaAlertLinks" +
                        " VALUES(?, ?)", [alert_id, meta_alert])
            mal_cnt += 1
        if VERBOSE:
            print("%d meta-alert-links added" % mal_cnt)

    if VERBOSE:
        end_time = timer()
        elapsed_time = str(round(end_time - start_time, 1))
        print(elapsed_time + " s to add determinations\n")


def add_alerts(args, tool, input_file, database, tmp_out_dir, src_dirs, swamp_tool=None):
    from satsv2sql import insert_alerts
    if VERBOSE:
        print("Adding alerts to database")
        start_time = timer()

    if tool.platform_str == "metric":
        # load metric data
        script = os.path.join(SCRIPTS_DIR, "%s2sql.py" % tool.name)
        subprocess.check_call("python %s < %s | sqlite3 %s" \
            % (script, input_file, database), shell=True)
    else:
        # Extract Message table info from the provided tool output
        if swamp_tool:
            script = os.path.join(
                SCRIPTS_DIR, "tool_output_parsers/%s2tsv.py" % swamp_tool.name)
        else:
            script = os.path.join(
                SCRIPTS_DIR, "tool_output_parsers/%s2tsv.py" % tool.name)

        parser_output_file = os.path.join(tmp_out_dir, "parser_output")
        parser_args = ["python", script]
        if not swamp_tool:
            if tool.version:
                parser_args.append("--version='%s'" % tool.version)
        parser_args.extend([input_file, parser_output_file])
        subprocess.call(parser_args)

        # Unix command to sort and remove duplicate records
        unique_records_file = str(parser_output_file + "_unique")
        cmd = "sort -u < %s > %s" % (parser_output_file, unique_records_file)
        subprocess.call("sort -u < %s > %s" \
            % (parser_output_file, unique_records_file), shell=True)

        insert_alerts(tool, src_dirs, unique_records_file, database)

    if VERBOSE:
        end_time = timer()
        elapsed_time = str(round(end_time - start_time, 1))
        print(elapsed_time + " s to add alerts to the database, canonicalize path names, & fix null checkers\n")


def get_arguments():
    parser = argparse.ArgumentParser(description="Assimilates output from alerts or metrics tool into a SCALe database", epilog='''
If database does not exist, it is created.
If database does exist, any data related to tool is first erased.
''')
    parser.add_argument('-v', '--verbose', action=bootstrap.Verbosity)
    parser.add_argument("database", help="Project database")
    parser.add_argument(
        "input", help="File containing output produced by tool")
    parser.add_argument("-i", "--tool-id", type=int, required=False, default=None,
            help="Tool ID (if known)")
    parser.add_argument("-t", "--tool-name", required=False, default=None,
            help="Tool name")
    parser.add_argument("-p", "--tool-platform", required=False, default=None,
            help="Tool platform (target language)")
    parser.add_argument("-V", "--tool-version", required=False, default=None,
            help="Tool version (if applicable)")
    parser.add_argument("-k", "--swamp-tool-id", required=False, default=None,
            help="Tool ID (if available) of SWAMP tool")
    parser.add_argument('-s', '--src-dirs', action='append', required=True,
            help="Path(s) to source code")
    parser.add_argument('-m', '--map', action='append', default=None,
            help="Path substitution to try when correcting filenames")
    return parser.parse_args()


if __name__=="__main__":
    args = get_arguments()
    if args.map is None:
        args.map = "="
    if VERBOSE:
        print("")
        print("Args are: ", args)
        print("")

    if VERBOSE:
        start_total_time = timer()

    database = args.database
    tool_id = args.tool_id
    tool_name = args.tool_name
    tool_platform = args.tool_platform
    tool_version = args.tool_version
    swamp_tool_id = args.swamp_tool_id
    input_file = args.input
    src_dirs = args.src_dirs

    if ((tool_id is None) and (not tool_name and not tool_platform)):
        print("tool name/platform/version or tool ID required")
        sys.exit()

    tmp_out_dir = os.path.join(SCRIPTS_DIR, "tmp")
    if not os.path.exists(tmp_out_dir):
        os.makedirs(tmp_out_dir)

    # create database if necessary (during normal execution this part
    # get invoked from the create() controller in
    # app/controllers/projects_controller.rb)
    if not os.path.exists(database):
        create_project_db(database)

    if tool_id is not None:
        tool = bootstrap.tool_by_id(database, tool_id)
    else:
        plats = tool_platform.split('/')
        tool_plats_json = json.dumps(plats)
        tool = bootstrap.tool_by_name(database,
            tool_name, tool_plats_json, version=tool_version)

    swamp_tool = None

    if swamp_tool_id is not None:
        swamp_tool = bootstrap.tool_by_id(database, swamp_tool_id)
    
    # Clean database of any preexisting messages
    clean_database(database, tool)

    # add project tool
    add_project_tool(database, tool)

    # Add alerts to the database
    add_alerts(args, tool, input_file, database, tmp_out_dir,
            src_dirs, swamp_tool)

    # Add meta-alerts and determination info
    if tool.platform_str != "metric":
        add_meta_alerts_and_determinations(database, tool)

    if VERBOSE:
        print("Done!")
        end_total_time = timer()
        elapsed_total_time = str(round(end_total_time - start_total_time, 1))
        print(elapsed_total_time," s to run digest_alerts.py \n")
    else:
        # Running in production mode -- clean up temporary files
        shutil.rmtree(tmp_out_dir)
