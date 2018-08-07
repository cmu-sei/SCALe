#!/usr/bin/env python

# Script takes an Eclipse text output file and extracts its diagnostic
# information
#
# The only argument indicates the file containing the input.  The data
# should be produced from Eclipse's Problems tab. After building a
# project, select the warnings to save, copy and past them into a text
# editor, and save it.
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


textRE = re.compile(r"Java Problem\s(\S*)\s(.*)\sline ([0-9]*)\s(\S*).java")

for line in open(input):
    line = line.strip().replace("|", " ")
    parse = re.match(textRE, line)
    if (None == parse):
        continue

    # parse description and class
    path = parse.group(1)
    desc = parse.group(2)
    lineno = parse.group(3)
    classname = parse.group(4)

    # | <Description> | <Path> / <Resource> | <line-number> |
    print "|| " + path + "/" + classname \
        + ".java | " + lineno + " | " + desc + " |"
