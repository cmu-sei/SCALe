#!/usr/bin/env python

# Script that parses/converts input of fields between CSV & ORG modes
#
# usage: csv2csv.py -o org <csv-file> > <org-file>
# usage: csv2csv.py -i org < <org-file> > <csv-file>
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import argparse
import sys
import scale

parser = argparse.ArgumentParser(description="Converts input of fields between CSV & ORG modes", epilog='''
''')
parser.add_argument(
    "-i", "--input", nargs=1, choices=scale.Table_Format_Choices, default=["csv"],
                    help="Input format for data")
parser.add_argument(
    "-o", "--output", nargs=1, choices=scale.Table_Format_Choices, default=["csv"],
                    help="Output format for data")
parser.add_argument("infile", nargs="?",
                    help="Input data file. If undefined, uses sys.stdin")
args = parser.parse_args()

instream = sys.stdin
if args.infile != None:
    instream = open(args.infile, "rU")
for fields in scale.Read_Fields(args.input[0], instream):
    scale.Write_Fields(fields, args.output[0])
