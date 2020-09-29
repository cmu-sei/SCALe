#!/usr/bin/env python

# Script fixes the risk-assessment stats, converting them to numbers.
#
# usage: ./fix_prob.py <platform> < <org-input> > <org-output>
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

import sys
import re

if len(sys.argv) != 2:
    print("usage: ", sys.argv[0], " < <org-input> > <org-output>")
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
    print(line.strip()," ",platform," |")
