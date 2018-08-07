#!/usr/bin/env python

# Script that provides a tabular output of all messages
# corresponding to a particular diagnostic
#
# usage: msg.py <db> <diagnostic-id> > <org-file>
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sqlite3 as sqlite
import argparse
import scale

parser = argparse.ArgumentParser(
    description="Provides tabular output of all messages corresponding to a particular diagnostic")
parser.add_argument("db", help="Database file")
parser.add_argument("diag", help="Diagnostic ID")
parser.add_argument(
    "-o", "--output", nargs=1, choices=scale.Table_Format_Choices, default=["csv"],
                    help="Output format for data")
parser.add_argument(
    "-l", "--link", nargs=1, choices=scale.Link_Format_Choices, default=["none"],
                    help="Output format for links")
parser.add_argument("-p", "--prefix", nargs=1, default=["file://localhost/"],
                    help="Prefix to prepend to web links")
args = parser.parse_args()


con = sqlite.connect(args.db)
with con:
    cur = con.cursor()
    cur.execute(
        "SELECT * FROM Messages WHERE Messages.diagnostic = ?", [args.diag])
    DB_Map = ["msgID", "diagID", "path", "line", "message"]  # Messages
    Print_Map = ["path", "line", "link", "message"]
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

        fields["link"] = scale.Build_Link(
            fields["path"], fields["line"], args.link[0], args.prefix[0])

        # Convert map to print list
        items = []
        i = 0
        for item in Print_Map:
            items.append(unicode(fields[item]))

        scale.Write_Fields(items, args.output[0])
