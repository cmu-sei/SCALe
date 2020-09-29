#!/usr/bin/env python

# Python script that converts a properties file to a series of SQL
# 'insert' commands. Inverse of sql2properties.py.  Extra args are
# translated into fields, added to every table entry.
#
# This usage adds the contents of the properties file to the specified
# database table usage: properties2sql.py <table> < <properties-file>
# <arg> <arg> ... | sqlite3 <db>
#
# <legal>
# SCALe version r.6.2.2.2.A
# 
# Copyright 2020 Carnegie Mellon University.
# 
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING
# INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON
# UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR
# IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF
# FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS
# OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT
# MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT,
# TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# 
# Released under a MIT (SEI)-style license, please see COPYRIGHT file or
# contact permission@sei.cmu.edu for full terms.
# 
# [DISTRIBUTION STATEMENT A] This material has been approved for public
# release and unlimited distribution.  Please see Copyright notice for
# non-US Government use and distribution.
# 
# DM19-1274
# </legal>

import sys
import scale
import subprocess

if len(sys.argv) < 3:
    raise TypeError("Usage: " + sys.argv[
                    0] + " <checker_id start value> <table> < <properties-file> ")
table = sys.argv[2]
checker_id = int(sys.argv[1])
fields = []
duplicates = set()
for arg in sys.argv[3:]:
    fields.append(scale.CSV_Quote(arg))
suffix = ", ".join(fields)
if len(suffix) > 0:
    suffix = ", " + suffix

print(scale.SQL_Begin)
for line in sys.stdin:
    line = line.strip()
    if line.startswith("#"):
        continue
    if line == "":
        continue

    items = line.split(":")
    key = items[0]
    value = ":".join(items[1:]).strip()
    split = value.split(",")
    if len(split) > 1:
        for cwe in split:
            cwe = cwe.strip()

            if key not in duplicates:
                duplicates.add(key)

                # print("INSERT INTO \"", table, "\" VALUES(" ,
                # str(checker_id), ",", scale.CSV_Quote(key), suffix, ");")

                subprocess.check_call("INSERT INTO \"" + table + "\" VALUES(" + str(
                    checker_id) + "," + scale.CSV_Quote(key) + suffix + "); | sqlite3 out.sqlite3", shell=True)

            checker_id += 1
            subprocess.check_call(
                "INSERT INTO ConditionCheckerLinks VALUES(" + scale.CSV_Quote(cwe) + "," + str(checker_id) + "); | sqlite3 out.sqlite3")

    else:
        if key not in duplicates:
            subprocess.check_call("INSERT INTO \"" + table + "\" VALUES(" + str(
                checker_id) + "," + scale.CSV_Quote(key) + suffix + "); | sqlite3 out.sqlite3")
            duplicates.add(key)
        subprocess.check_call(
            "INSERT INTO ConditionCheckerLinks VALUES(" + scale.CSV_Quote(value) + "," + str(checker_id) + "); | sqlite3 out.sqlite3")

        checker_id += 1
print(scale.SQL_End)
