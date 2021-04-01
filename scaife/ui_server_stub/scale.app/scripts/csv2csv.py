#!/usr/bin/env python

# Script that parses/converts input of fields between CSV & ORG modes
#
# usage: csv2csv.py -o org <csv-file> > <org-file>
# usage: csv2csv.py -i org < <org-file> > <csv-file>
#
# <legal>
# SCALe version r.6.5.5.1.A
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
