#!/usr/bin/env python

# Python script that scrubs pclint diagnostics.
#
# The only argument indicates the file containing the input.
#
# This script can produce lots of messages per diagnostic
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import re

if len(sys.argv) != 2:
    raise TypeError("Usage: " + sys.argv[0] + " <raw-input> > <org-output>")
input = sys.argv[1]

# Regexes used for entire pclint errors.
regexes = []
regexes.append(re.compile("(.*?)\((\d+)\): error (\d+): (.*)"))
# regexes.append(re.compile(".*File (.*?)line (.*?): (.*?)(.*)"))
regexes.append(re.compile("(.*?)(\d+)error (\d+): (.*)"))

# Regexes used for diagonostics with file names and line numbers.
multiLineRegexes = []
multiLineRegexes.append(re.compile("(.*?)line (\d+), file (.*?)([,)].*)"))
multiLineRegexes.append(
    re.compile("(.*?Reference: )file (.*?): line (\d+)(].*)"))
multiLineRegexes.append(
    re.compile("(.*?Reference: )file (.*?): lines (.*?)(].*)"))

for line in open(input):
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

    # If the diagonostic contains a second set of file/line numbers, place
    # this information in a second column.
    multiLineLocation = ""

    # Apply multi line regexes
    for multiLineRegex in multiLineRegexes:
        multiLineParse = re.match(multiLineRegex, diagonostic)
        while multiLineParse != None:
            # Replace file location and line number with the word link.
            originalDiagonosticFront = multiLineParse.group(1).strip()
            originalDiagonosticBack = multiLineParse.group(4).strip()
            diagonostic = originalDiagonosticFront + \
                " link " + originalDiagonosticBack

            # Extract file location and line number.
            multiLineLineNumber = multiLineParse.group(2).strip()
            multiLineFile = multiLineParse.group(3).strip()
            if multiLineFile.split(",")[0].isdigit():
                # Case in which the file appears before the line number in the
                # regular expression.
                fileName = multiLineLineNumber
                for lineNum in multiLineFile.split(","):
                    parse = re.search("(\d+)", lineNum)
                    if parse != None:
                        lineNum = parse.group(1)
                    multiLineLocation += fileName + \
                        " | " + lineNum.strip() + " | | "
            else:
                multiLineLocation += multiLineFile + \
                    " | " + multiLineLineNumber + " | | "

            multiLineParse = re.match(multiLineRegex, diagonostic)

    if not errorNumber.isdigit():
        continue

    tableEntry = " | ".join(
        ["", errorNumber, fileLocation, lineNumber, diagonostic, multiLineLocation])
    print tableEntry
