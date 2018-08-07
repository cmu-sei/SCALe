#!/usr/bin/env python

# Python script that scrubs cppcheck diagnostics.
#
# The only argument indicates the file containing the input.
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import xml.etree.ElementTree as ET


def sanitize(s):
    if s is None:
        return ""
    # Remove new lines and pipes, as they'll mess up the org format
    return s.replace("\n", " ").replace("|", " ")


if len(sys.argv) != 2:
    exit("Usage: " + sys.argv[0] + " <cppcheck-xml-file>")
input = sys.argv[1]


try:
    tree = ET.parse(input)
except:
    sys.stderr.write(
        "An error occured while parsing the input file.  " +
        "Ensure it's a cppcheck xml file.\n")
    raise
root = tree.getroot()


# SCALe-style input consists of diagnostics, one per line, each of the form:
# | <checker> | <path> | <line> | <msg> | <path> | <line> | <msg> | ...
# cppcheck diagnostics map to a single source file line, so we just have
# 4 elements per line.
# {0} = checker id
# {1} = source file path
# {2} = line number
# {3} = diagnostic message
entry = "| {0} | {1} | {2} | {3} |"
attribs = ["id", "file", "line", "msg"]

for node in root.iter("error"):
    values = [sanitize(node.get(attrib)) for attrib in attribs]

    if node.get("file") is not None:
        print entry.format(*values)

    path = values[1]
    if path is None or path.strip() == "":
        continue
    print entry.format(*values)
