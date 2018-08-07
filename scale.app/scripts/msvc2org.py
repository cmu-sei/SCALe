#!/usr/bin/env python

# Scrubs the output of msvc and prints out the dianostics.
#
# The only argument indicates the file containing the input.
#
# This script can produce lots of messages per diagnostic
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import re
import os

if len(sys.argv) != 2:
    raise TypeError("Usage: " + sys.argv[0] + " <raw-input> > <org-output>")
input = sys.argv[1]

uniqueErrors = {}
regexes = []
regexes.append(re.compile("(.*?)\((\d*)\).*?error (.*?): (.*)"))
regexes.append(re.compile("(.*?)\((\d*),\d*\).*?error (.*?): (.*)"))
regexes.append(re.compile("(.*?)\((\d*)\).*?warning (.*?): (.*)"))
regexes.append(re.compile("(.*?)\((\d*),\d*\).*?warning (.*?): (.*)"))

for line in open(input):
    # match regular expressions
    for regex in regexes:
        parse = re.match(regex, line)
        if parse != None:
            break
    else:
        continue
    fileLocation = parse.group(1).strip()
    lineNumber = parse.group(2).strip()
    errorNumber = parse.group(3).strip()
    diagonostic = parse.group(4).strip().replace("|", " ")

    # print table
    tableEntry = " | ".join(
        ["", errorNumber, fileLocation, lineNumber, diagonostic, ""])
    print tableEntry
