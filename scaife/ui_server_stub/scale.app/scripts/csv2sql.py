#!/usr/bin/env python

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
print(scale.SQL_Begin)
for fields in scale.Read_Fields(args.input[0]):
    new_fields = []
    for field in fields:
        new_fields.append(scale.CSV_Quote(field))

    # insert id, name, title into Conditions table
    print("INSERT INTO Conditions VALUES(", \
          str(start_id),",",",".join(new_fields[0:2]),",","NULL", ");")
    # insert everything but name, title into other fields
    del new_fields[0:2]
    print("INSERT INTO \"", args.table, "\" VALUES(",  \
          str(start_id),  ",", ",".join(new_fields), ");")
    start_id += 10

print(scale.SQL_End)
