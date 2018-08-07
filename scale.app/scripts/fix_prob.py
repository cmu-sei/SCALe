#!/usr/bin/env python

# Script fixes the risk-assessment stats, converting them to numbers.
#
# usage: ./fix_prob.py <platform> < <org-input> > <org-output>
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import re

if len(sys.argv) != 2:
    print "usage: ", sys.argv[0], " < <org-input> > <org-output>"
    exit(1)
platform = sys.argv[1]

for line in sys.stdin:
    # High severity = 3, but high rem cost = 1. (and reverse for low)
    line = re.sub(r"\|\s*High\s*\|(?=\s*\d)", "| 1 |", line)
    line = re.sub(r"\|\s*Low\s*\|(?=\s*\d)",  "| 3 |", line)
    line = re.sub(r"\|\s*High\s*\|",          "| 3 |", line)
    line = re.sub(r"\|\s*Low\s*\|",           "| 1 |", line)
    line = re.sub(r"\|\s*Medium\s*\|",        "| 2 |", line)
    line = re.sub(r"\|\s*Likely\s*\|",        "| 3 |", line)
    line = re.sub(r"\|\s*Unlikely\s*\|",      "| 1 |", line)
    line = re.sub(r"\|\s*Probable\s*\|",      "| 2 |", line)
    print line.strip() + " " + platform + " |"
