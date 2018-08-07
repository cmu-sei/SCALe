#!/usr/bin/env python

# Converts ldra output into an org table
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

import sys
import os

inFile = sys.argv[1]

with open(inFile, 'r') as f:
    duplicates = []
    contents = f.read()
    filepath = ""
    began = False
    skip = 0
    dictionaryLine = 0
    dictionary = dict()
    for line in contents.split("\n"):
        if "STANDARDS" in line:
            dictionaryLine = 1
            continue
        if dictionaryLine == 1:
            dictionaryLine = 2
            continue
        if dictionaryLine == 2:
            if line.split() == []:
                dictionaryLine = 0
                continue
            if ' *' in line:
                split = line.split()
                code = ("_").join(split[1:3])
                violation = (" ").join(split[4:])
                if "CWE" in violation:
                    cwe = violation.split("CWE")[1].strip()
                    violation = violation.split("CWE")[0].strip()
                dictionary[violation] = code

        if ".c)" in line or ".cpp)" in line:
            try:
                filepath = line.strip().split()[4].strip(")")
                began = True
                continue
            except:
                continue

        if began:
            if "==" in line and skip == 0:
                skip = 1
                continue
            if "==" in line and skip == 1:
                skip = 2
                continue
            if skip == 2:
                splitline = line.split()
                if splitline == []:
                    began = False
                    skip = 0
                    continue
                if len(splitline) < 3:
                    cwe = splitline[1]
                    continue
                linenum = splitline[1]
                violation = (" ").join(splitline[2:]).strip()
                if [linenum, violation, filepath] in duplicates:

                    continue
                else:
                    duplicates.append([linenum, violation, filepath])

                if ":" in violation:
                    key = violation.split(":")[0].strip()
                    print "|" + dictionary[key] + "|" + filepath + "|" + linenum + "|" + violation + "|"
                    continue
                if "CWE" in violation:
                    cwe = violation.split("CWE")[1].strip()
                    violation = violation.split("CWE")[0].strip()
                    print "|" + dictionary[violation] + "|" + filepath + "|" + linenum + "|" + violation + "|"
                else:
                    print "|" + dictionary[violation] + "|" + filepath + "|" + linenum + "|" + violation + "|"
