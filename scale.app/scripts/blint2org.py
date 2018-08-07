#!/usr/bin/env python

# Script takes a B::lint text output file and extracts its diagnostic
# information
#
# The only argument indicates the file containing the input.
# The data should be produced from a build process using B::Lint.
#
# This script never produces more than one message per diagnostic
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

import sys
import re

if len(sys.argv) != 2:
    raise TypeError("Usage: " + sys.argv[0] + " <raw-input> > <org-output>")
input = sys.argv[1]

for line in open(input):
    line = line.strip().replace("|", " ")

    parse = re.match(r"^(.*) at (.*) line (\d*)(|\.|, (near|at) (.*))?$", line)
    if (None == parse):
        continue

    msg = parse.group(1)
    path = parse.group(2)
    line = parse.group(3)

    msg = re.sub(r" *\(@INC contains: .*?\)", "", msg)
    print "|| " + path + " | " + line + " | " + msg + " |"
