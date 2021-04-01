#!/usr/bin/env python

# Python script that converts complete SCALe db to tabular output
#
# usage: scale2csv.py <db> [-c <select-arg>]? > <csv-file>
#
# <legal>
# SCALe version r.6.5.5.1.A
# 
# Copyright 2021 Carnegie Mellon University.
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

# charuta remove
print("scripts/scale2csv.py")

import sqlite3 as sqlite
import argparse
import scale

parser = argparse.ArgumentParser(
    description="Converts a SCALe database into tabular output")
parser.add_argument("db", help="Database file")
parser.add_argument("-c", "--constraint", nargs=1,
                    help="Selection constraint")
parser.add_argument(
    "-o", "--output", nargs=1, choices=scale.Table_Format_Choices,
    default=["csv"], help="Output format for data")
parser.add_argument(
    "-l", "--link", nargs=1, choices=scale.Link_Format_Choices,
    default=["none"], help="Output format for links")
parser.add_argument("-p", "--prefix", nargs=1, default=["file://localhost/"],
                    help="Prefix to prepend to web links")
args = parser.parse_args()
query = ""
if args.constraint is not None:
    query = " AND " + args.constraint[0]

con = sqlite.connect(args.db)
with con:
    cur = con.cursor()
    cur.execute(
        "SELECT * FROM Alerts, Messages, Checkers, Conditions, Tools " +
        " WHERE Alerts.primary_msg=Messages.id " +
        " AND Alerts.checker_id = Checkers.name " +
        " AND Alerts.tool = Checkers.tool_id " +
        " AND Checkers.rule = Conditions.name " +
        " AND Tools.id = Alerts.tool" + query)
                # add CWEs constraints
    # Order of fields produced by above SELECT statement
    DB_Map = ["id", "flag", "verdict", "previous",
              "checker", "tool", "msgID", "notes",
              "ignored", "dead", "inapplicable_environment",
              "dangerous_construct", "class_label", "confidence", "meta_alert_priority",
              # Alerts
              "msgID", "alertID", "path", "line", "message",  # Messages
              "checker", "condition", "tool", "regex",  # Checkers
              "condition", "title", "severity", "likelihood",
              "remediation", "priority", "level", "platform",  # Rules
              "tool", "name", "platform",  # Tools
              "cwe_likelihood"  # CWEs
              ]
    # Order of fields that we plan to print
    Print_Map = [
        "id", "flag", "verdict", "previous", "path", "line", "link", "message",
        "checker", "tool", "condition", "title", "class_label", "confidence",
        "meta_alert_priority", "severity", "likelihood",
        "remediation", "priority", "level", "cwe_likelihood", "notes",
        "ignored", "dead", "inapplicable_environment",
        "dangerous_construct", "confidence", "meta_alert_priority"
    ]
    scale.Write_Header(Print_Map, args.output[0])

    rows = cur.fetchall()
    for row in rows:
        # First build dictionary mapping fields in our records to their column
        # names
        fields = dict()
        i = 0
        while i < len(row):
            fields[DB_Map[i]] = row[i]
            i = i + 1

        # Convert certain fields
        fields["flag"] = scale.Flag_Map[fields["flag"]]
        fields["verdict"] = scale.Verdict_Map[fields["verdict"]]
        fields["previous"] = scale.Verdict_Map[fields["previous"]]
        fields["link"] = scale.Build_Link(
            fields["path"], fields["line"], args.link[0], args.prefix[0])
        fields["tool"] = fields["name"]  # real tool name
        fields["severity"] = scale.Level_Map[fields["severity"]]
        fields["likelihood"] = scale.Level_Map[fields["likelihood"]]
        fields["remediation"] = scale.Level_Map[fields["remediation"]]
                # charuta is this line necessary / what are the above conversions
                # fields["cwe_likelihood"] =
                # scale.Level_Map[fields["cwe_likelihood"]]

        # Convert map to print list
        items = []
        i = 0
        for item in Print_Map:
            items.append(unicode(fields[item]))

        scale.Write_Fields(items, args.output[0])
