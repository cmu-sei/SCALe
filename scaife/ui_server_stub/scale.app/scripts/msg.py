#!/usr/bin/env python

# Script that provides a tabular output of all messages
# corresponding to a particular alert
#
# usage: msg.py <db> <alert-id> > <org-file>
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

import sqlite3 as sqlite
import argparse
import scale

parser = argparse.ArgumentParser(
    description="Provides tabular output of all messages corresponding to a particular alert")
parser.add_argument("db", help="Database file")
parser.add_argument("alert", help="Alert ID")
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
        "SELECT * FROM Messages WHERE Messages.alert_id = ?", [args.alert])
    DB_Map = ["msgID", "alertID", "path", "line", "message"]  # Messages
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
