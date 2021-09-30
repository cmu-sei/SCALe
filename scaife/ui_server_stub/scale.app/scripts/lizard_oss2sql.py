#!/usr/bin/env python

# Script that converts Lizard output to a series of SQL 'insert' commands.
#
# usage: lizard2sql.py <table> < <lizard-file> | sqlite3 <db>
#
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

import os, argparse
import scale
import bootstrap

parser = argparse.ArgumentParser(description="Converts a Lizard CSV table of values into SQL INSERT statements", epilog='''
Data should be provided via standard input.
SQL INSERT statements are produced via standard output.
''')
parser.add_argument(
    "-t", "--table", default="LizardMetrics",
    help="Table to add data to")
parser.add_argument(
    "-i", "--input", choices=scale.Table_Format_Choices,
    default=["csv"], help="Input format for data")
args = parser.parse_args()


print(scale.SQL_Begin)

print("DROP TABLE IF EXISTS "),
print(args.table),
print(";")
for line in open(os.path.join(
        bootstrap.scripts_dir, "create_lizard_oss_metrics.sql")):
    print(line.rstrip())

for fields in scale.Read_Fields(args.input[0]):
    new_fields = []
    
    #  Only grab the first 15 fields 
    # (some CSVs contain more fields and users may not always use the convert script) 
    end_of_fields = len(fields)
    
    if end_of_fields > 15:
        end_of_fields = 15
        
    for field in fields[:end_of_fields]: 
        if field == '':
            field = "0"
        new_fields.append(scale.CSV_Quote(field))

    print "INSERT INTO \"" + args.table + "\" VALUES(" + \
        ",".join(new_fields) + ");"

print(scale.SQL_End)

