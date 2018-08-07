#!/usr/bin/env python

# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

import sys
from subprocess import call

inFile = sys.argv[1]
splitdot = inFile.split(".")
lang = splitdot[0].split("_")[1]
with open(lang.lower() + ".codesonar.cwe.properties", 'w') as w:
    w.write(
        "# Mappings data for codesonar error identifiers (checkers) to CWE IDs from https://www.securecoding.cert.org/confluence/display/c/CodeSonar. Used just the 'close mappings'. (Grammatech data has a description of how good the mapping is.)")
    w.write("\n")
    w.write(
        "# Before converting the .csv file to a .properties file, the :%s/^M//g command was used to strip ^M (carriage return)")
    w.write("\n")

    with open(inFile, 'r') as f:
        duplicates = []
        contents = f.read()
        contents = contents.strip("\r")
        firstLine = True
        for line in contents.split("\n"):
            if not firstLine and len(line) > 0:
                words = line.split(",")
                key = words[2].strip('""')
                value = "CWE-" + words[0].split(":")[1]

                # hardcoding rules that have "," in them
                if value == "CWE-837" or value == "CWE-323":
                    key = words[3].strip('""')

                elif value == "CWE-582" or value == "CWE-389" or value == "CWE-150":
                    key = words[4].strip('""')

                if [key, value] in duplicates:
                    continue
                else:
                    duplicates.append([key, value])
                    w.write(key + " : " + value + "\n")

            firstLine = False
