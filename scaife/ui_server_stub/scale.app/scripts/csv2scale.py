#!/usr/bin/env python

# <legal>
# SCALe version r.6.7.0.0.A
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

import argparse
import scale

parser = argparse.ArgumentParser(description='''
Python script that updates a SCALe db from the contents of a tabular
file.  This file should have been created by scale2csv.py. It produces
the SQL statements needed to modify the db.
''', epilog='''
Data should be provided via standard input.
SQL UPDATE statements are produced via standard output.

Actually, the table file only needs four columns: the ID, flag,
verdict, and notes...any latter columns are ignored. The flag, verdict, and notes for
the corresponding alert ID are updated...all other alerts
are unchanged.

Sample Usage: csv2scale.py < <table> | sqlite3 <db>

Note that if your table has 'unknown' verdicts, they will replace
true or false in the db; you may want to add a 'grep' command to
the pipeline to only update fields that are not unknown, eg:
  ./csv2scale.py < <table> | grep -v verdict=0 | sqlite3 <db> (0=unknown)
''')
parser.add_argument(
    "-i", "--input", nargs=1, choices=scale.Table_Format_Choices, default=["csv"],
                    help="Input format for data")
args = parser.parse_args()

print(scale.SQL_Begin)

scale.Read_Header(args.input[0])
for fields in scale.Read_Fields(args.input[0]):
    alert_id = int(scale.Unquote(fields[0]))
    flag_val = scale.Unquote(fields[1])
    ignored_val = scale.Unquote(fields[5])
    dead_val = scale.Unquote(fields[6])
    inapplicable_environment_val = scale.Unquote(fields[7])
    dangerous_construct_val = int(scale.Unquote(fields[8]))
    flag = 0
    if flag_val != "" and flag_val.upper() != "NULL":
        flag = 1
    verdict = scale.Verdict_Map.index(scale.Unquote(fields[2]).capitalize())
    notes = scale.Unquote(fields[4])  # not 3 because that's "previous verdict"
    ignored = 0
    if ignored_val != "" and ignored_val.upper() != "NULL":
        ignored = 1
    dead = 0
    if dead_val != "" and dead_val.upper() != "NULL":
        dead = 1
    inapplicable_environment = 0
    if inapplicable_environment_val != "" and inapplicable_environment_val.upper() != "NULL":
        inapplicable_environment = 1
    print("UPDATE Alerts SET flag=", str(flag)
           , ", verdict=", str(verdict)
           , ", notes=", str(notes)
           , ", ignored=", str(ignored)
           , ", dead=", str(dead)
           , ", inapplicable_environment=", str(inapplicable_environment)
           , ", dangerous_construct=", str(dangerous_construct)
           , " WHERE id=", str(alert_id)
           , ";")

print(scale.SQL_End)
