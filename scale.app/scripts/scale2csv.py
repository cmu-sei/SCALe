#!/usr/bin/env python

# Python script that converts complete SCALe db to tabular output
#
# usage: scale2csv.py <db> [-c <select-arg>]? > <csv-file>
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

# charuta remove
print "scripts/scale2csv.py"

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
        "SELECT * FROM Diagnostics, Messages, Checkers, Rules, Tools, CWEs " +
        " WHERE Diagnostics.primary_msg=Messages.id " +
        " AND Diagnostics.checker = Checkers.name " +
        " AND Diagnostics.tool = Checkers.tool " +
        " AND Checkers.rule = Rules.name " +
        " AND Tools.id = Diagnostics.tool" + query)
                # add CWEs constraints
    # Order of fields produced by above SELECT statement
    DB_Map = ["id", "flag", "verdict", "previous",
              "checker", "tool", "msgID", "notes",
              "ignored", "dead", "inapplicable_environment",
              "dangerous_construct", "confidence", "alert_priority",
              # Diagnostics
              "msgID", "diagID", "path", "line", "message",  # Messages
              "checker", "rule", "tool", "regex",  # Checkers
              "rule", "title", "severity", "liklihood",
              "remediation", "priority", "level", "platform",  # Rules
              "tool", "name", "platform",  # Tools
              "cwe_likelihood"  # CWEs
              ]
    # Order of fields that we plan to print
    Print_Map = [
        "id", "flag", "verdict", "previous", "path", "line", "link", "message",
        "checker", "tool", "rule", "title", "confidence",
        "alert_priority", "severity", "liklihood",
        "remediation", "priority", "level", "cwe_likelihood", "notes",
        "ignored", "dead", "inapplicable_environment",
        "dangerous_construct", "confidence", "alert_priority"
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
        fields["liklihood"] = scale.Level_Map[fields["liklihood"]]
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
