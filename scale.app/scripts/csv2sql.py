#!/usr/bin/env python

# Copyright (c) 2007-2018 Carnegie Mellon University.
# All Rights Reserved. See COPYRIGHT file for details.
#
# These instructions are obsolete, this script now inserts Taxonomy information
#
# Script that converts input of fields to a series of SQL 'insert' commands.
#
# usage: csv2sql.py <table> < <csv-file> | sqlite3 <db>
# usage: csv2sql.py -i org <table> < <org-file> | sqlite3 <db>
#
# To convert from a SQL selection to a CSV file, you can do this:
# usage: sqlite3 -csv <db> "SELECT ..." > <csv-file>
#
# To convert from a SQL selection to an .org file, you can do this:
# usage: sqlite3 <db> "SELECT ..." | perl -p -e 'chomp; $_ = "|$_|\n";' >
# <org-file>


import argparse
import scale

parser = argparse.ArgumentParser(description="Converts a table of values into SQL INSERT statements", epilog='''
Data should be provided via standard input.
SQL INSERT statements are produced via standard output.
''')
parser.add_argument("table", help="Table to add data to")
parser.add_argument("start_id", help="starting taxonomy id value")
parser.add_argument(
    "-i", "--input", nargs=1, choices=scale.Table_Format_Choices,
    default=["csv"], help="Input format for data")
args = parser.parse_args()

start_id = int(args.start_id)
print scale.SQL_Begin
for fields in scale.Read_Fields(args.input[0]):
    new_fields = []
    for field in fields:
        new_fields.append(scale.CSV_Quote(field))

    # insert id, name, title into TaxonomyEntries table
    print "INSERT INTO TaxonomyEntries VALUES(" + \
        str(start_id) + "," + ",".join(new_fields[0:2]) + ");"
    # insert everything but name, title into other fields
    del new_fields[0:2]
    print "INSERT INTO \"" + args.table + "\" VALUES(" + \
        str(start_id) + "," + ",".join(new_fields) + ");"
    start_id += 10

print scale.SQL_End
