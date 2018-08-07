#!/usr/bin/env python

# Script that converts Understand output to a series of SQL 'insert' commands.
#
# usage: understand2sql.py <table> < <understand-file> | sqlite3 <db>
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import argparse
import scale

parser = argparse.ArgumentParser(description="Converts an Understand CSV table of values into SQL INSERT statements", epilog='''
Data should be provided via standard input.
SQL INSERT statements are produced via standard output.
''')
parser.add_argument(
    "-t", "--table", default="UnderstandMetrics",
    help="Table to add data to")
parser.add_argument(
    "-i", "--input", choices=scale.Table_Format_Choices,
    default=["csv"], help="Input format for data")
args = parser.parse_args()


print scale.SQL_Begin

print "DROP TABLE IF EXISTS " + args.table + ";"
for line in open("create_understand_metrics.sql"):
    print line.rstrip()

skip_first = True
for fields in scale.Read_Fields(args.input[0]):
    if skip_first:
        skip_first = False
        continue

    # field[0] should be flag, not string
    if fields[0] == "File":
        fields[0] = "1"
    else:
        fields[0] = "0"

    new_fields = []
    for field in fields:
        if field == '':
            field = "0"
        new_fields.append(scale.CSV_Quote(field))

    print "INSERT INTO \"" + args.table + "\" VALUES(" + \
        ",".join(new_fields) + ");"
print scale.SQL_End
