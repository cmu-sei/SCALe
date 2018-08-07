#!/usr/bin/env python

# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

import sys
import re

inFile = sys.argv[1]
with open("c.coverity.cwe.properties", 'w') as w:
    w.write(
        "# Mappings from Coverity error identifiers (aka categories) to CWE IDs\n")

    with open(inFile, 'r') as f:
        contents = f.read()
        count = 0
        for line in contents.split("\n"):
            start = True
            if line.split() != []:
                if line.split()[0] == "#" or "http" in line:
                    w.write("#" + line + "\n")
                elif count < 2:
                    count += 1
                else:
                    w.write(
                        line.split()[1] + " : CWE-" + line.split()[3] + "\n")
