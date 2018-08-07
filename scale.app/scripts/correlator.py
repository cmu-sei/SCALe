#!/usr/bin/env python

# Script takes org file as input, and two int arguments representing
# table columns.  Prints a statistical analysis of the contents of
# these columns
#
# usage: ./correlator.py <int> <int>
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import re
import os

map = {}
key2_totals = {}

if len(sys.argv) < 2:
    print "usage: ", sys.argv[0], " < <org-table> > <stats> <int> <int>"
    exit(1)
c1 = int(sys.argv[1])
c2 = int(sys.argv[2])

# Now read input, count items in map
for line in sys.stdin:
    columns = line.split("|")
    key1 = columns[c1].strip()
    key2 = columns[c2].strip()
    if (not map.has_key(key1)):
        map[key1] = {}
    if (not map[key1].has_key(key2)):
        map[key1][key2] = 0
    map[key1][key2] += 1
    if (not key2_totals.has_key(key2)):
        key2_totals[key2] = 0

# table header
key2_keys = sorted(key2_totals.keys())
print "| | ",
for key2 in key2_keys:
    print key2 + " | ",
print "TOTAL |"

# table
for key1 in sorted(map.keys()):
    print "| " + key1 + " | ",
    key1_total = 0
    for key2 in key2_keys:
        if (map[key1].has_key(key2)):
            print map[key1][key2],
            key1_total += map[key1][key2]
            key2_totals[key2] += map[key1][key2]
        print " | ",
    print key1_total,
    print " | "

# bottm totals row
print "| TOTAL | ",
grand_total = 0
for key2 in key2_keys:
    grand_total += key2_totals[key2]
    print key2_totals[key2],
    print " | ",
print grand_total,
print " |"
