#!/usr/bin/env python

# Python script that converts SQL dump data to an org table.
# Inverse of org2dbdump.py
#
# usage: sqlite3 <db> .dump | dbdump2org.py > <org-file>
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import re
import csv
# Train CSV to recognize a sample of SQL fields we typically get.
sqlite_dialect = csv.Sniffer().sniff("3, 'ab', 'ab''c'")

create_table_regex = re.compile("^CREATE  *TABLE(.*?)\((.*?)\);$")
insert_into_table_regex = re.compile(
    "^INSERT  *INTO  *(.*?)  *VALUES *\((.*)\);$")


print "* Database"
for line in sys.stdin:

    parse = re.match(insert_into_table_regex, line)
    if (None != parse):
        table = parse.group(1).strip()
        fields = parse.group(2).strip()
        reader = csv.reader([fields], sqlite_dialect)
        for row in reader:
            new_row = []
            for item in row:
                new_row.append(item.replace("|", "BAR"))
            print "|", "|".join(new_row), "|"
        continue

    parse = re.match(create_table_regex, line)
    if (None != parse):
        table = parse.group(1).strip()
        fields = parse.group(2).split(
            ",")
        # We'll trust this to work on fields
        print "** " + table
        print "SQL: " + line.strip()
        variables = []
        typeinfos = []
        for field in fields:
            words = field.strip().split()
            if words[0] == "PRIMARY" and words[1] == "KEY":
                break
            variables.append(words[0])
            typeinfos.append(" ".join(words[1:]))
        print "| " + " | ".join(variables) + " |"
        print "| " + " | ".join(typeinfos) + " |"
        print "|-"
        continue

    print "SQL: " + line.strip()
