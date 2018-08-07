#!/usr/bin/env python

# Script takes a GCC or G++ text output file and extracts its
# diagnostic information
#
# The only argument indicates the file containing the input.
# The data should be produced from a build process using make and
# gcc/g++.  A suitable command to generate the text data is:
#
# make 2>&! > makelog
#
# This script currently produces only one message per diagnostic
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import re

if len(sys.argv) != 2:
    raise TypeError("Usage: " + sys.argv[0] + " <raw-input> > <org-output>")
input = sys.argv[1]

inCtrFlag = 0
message = ""
links = ""
dirstack = []


def canonicalize_path(dirstack, filename):
    path = "/".join(dirstack) + "/" + filename
    while (True):
        newpath = re.sub(r"([^/]*)/\.\./", r"", path)
        if (len(newpath) == len(path)):
            break
        path = newpath
    while (True):
        newpath = re.sub(r"$./", r"", path)
        if (len(newpath) == len(path)):
            break
        path = newpath
    while (True):
        newpath = re.sub(r"/./", r"/", path)
        if (len(newpath) == len(path)):
            break
        path = newpath
    return path


for line in open(input):
    line = line.strip().replace("|", " ")

    parse = re.match(r"pushd *(.*)$", line)
    if (None != parse):
        dirstack.append(parse.group(1))
        continue
    if (line == "popd") and len(dirstack) > 0:
        del dirstack[len(dirstack) - 1]

    # Handle multi-line G++ diagnostics
    if (None != re.match(r"^(.*?): In constructor ", line)):
        inCtrFlag = 1
        message = ""
        links = ""
    if (None != re.match(r"^(.*?): At global scope:$", line)):
        inCtrFlag = 0
    if (None != re.match(r"^[^:]*$", line)):
        inCtrFlag = 0

    parse = re.match(r"^(.*?):([0-9]*): *(\S.*?) *$", line)
    if (inCtrFlag == 1 and parse != None):
        line_file = parse.group(1)
        line_line = parse.group(2)
        line_message = parse.group(3)
        message = message + " " + line_message
        if (None != re.match(r"warning: *when initialized here", line_message)):
            message = re.sub(r" *warning: *", " ", message)
            print "|| " + canonicalize_path( dirstack, line_file) + " | " + line_line \
                + " | " + message + "  LINKS:" + links + " |"
            message = ""
            links = ""
        else:
            if (line_line != ""):
                links = links + " " + line_file + ":" + line_line
        continue

    # 1-line diagnostics
    parse = re.match(
        r"^([^ :]*?\.(c|C|cpp|cxx|h|H)):([0-9]*):([0-9]*:)? *(\S.*?) *$", line)
    if (parse != None and parse.group(2) != ""):
        print "|| " + canonicalize_path( dirstack, parse.group(1)) \
            + " | " + parse.group(3) + " | " + parse.group(5) + " | "
