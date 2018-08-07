#!/usr/bin/env python

# Python script that converts org table to an SQL dump.
# Inverse of dbdump2org.py
#
# usage: org2dbdump.py < <org-file> | sqlite3 <db>
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import re
import scale

sql_regex = re.compile("SQL:(.*)")
table_regex = re.compile("\*\* (.*)")
state = None
table = None


for line in sys.stdin:

    if line.startswith("|-"):
        state = "data"  # print data fields
        continue
    elif line.startswith("|"):
        if state == None:
            state = "header"  # ignore header fields
    else:
        state = None

    parse = re.match(sql_regex, line)
    if (None != parse):
        cmd = parse.group(1).strip()
        print cmd
        continue

    parse = re.match(table_regex, line)
    if (None != parse):
        table = parse.group(1).strip()

    if state == "data" and line.startswith("|"):
        fields = line.split("|")[1:-1]
        new_fields = []
        for field in fields:
            new_fields.append(scale.CSV_Quote(field))
        print "INSERT INTO \"" + table + "\" VALUES(" + ",".join(new_fields) + ");"
