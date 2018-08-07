#!/usr/bin/env python

# Script takes an output file from a make command and removes make's footprints
#
# Its sole argument (optional) is a directory prefix, which gets
# pruned out of all directory commands.
#
# * Prunes out make error messages
# * Converts 'entering/leaving directory' into pushd/popd commands
# * Consequently, strips out cd-make commands
# * Collapses multiple lines with \ into one line
#
# The script should take the text data via standard input. The data
# should be produced from a build process using make. A suitable
# command to generate the text data is:
#
# make 2>&! > makelog
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import re

for line in sys.stdin:
    line = line.rstrip()

    # ignore cd && make commands
    parse = re.match(r"^cd (.*) \&\& make (.*)$", line)
    if (None != parse):
        continue

    parse = re.match(r"^make\[[0-9]*\]: Entering directory `(.*)'$", line)
    if (None != parse):
        print "popd"
        directory = parse.group(1)
        print "pushd " + directory
        continue

    if (None != re.match(r"^make\[[0-9]*\]: Leaving directory `(.*)'$", line)):
#        print "popd"
        continue

    # ignore other make messages
    if (None != re.match(r"^make(\[[0-9]*\])?: .*[Ee]rror(.*)$", line)):
        continue

    # collapse \ lines
    line, times = re.subn(r"\\$", r"", line)
    if (times == 1):
        print line,
        continue

    print line
