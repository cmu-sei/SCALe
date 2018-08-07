#!/usr/bin/env python

# Script takes a Rosecheckers output file and extracts its diagnostic
# information
#
# The only argument indicates the file containing the input.
#
# The script should take the text data via standard input. The data
# should be produced from a build process using make and g++.  A
# suitable command to generate the text data is:
#
# make 2>&! > makelog
#
# This script produces only one message per diagnostic
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import re

if len(sys.argv) != 2:
    raise TypeError("Usage: " + sys.argv[0] + " <raw-input> > <org-output>")
input = sys.argv[1]


directory = ""

for line in open(input):
    line = line.strip()

    parse = re.match(r"^In directory: *(.*)$", line)
    if (parse != None):
        directory = parse.group(1)
        continue

    parse = re.match(
        r"^(.*?):([0-9]*): (warning|error): ([-A-Za-z0-9]*): (.*?) *$", line)
    if (parse == None):
        continue
    line_file = parse.group(1)
    line_line = parse.group(2)
    line_id = parse.group(4)
    line_message = parse.group(5).replace("|", " ")
    print "| " + line_id + " | " + directory + "/" + line_file + " | " + line_line + " | " + line_message + " |"
