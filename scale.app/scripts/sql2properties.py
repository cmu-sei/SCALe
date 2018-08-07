#!/usr/bin/env python

# Python script that converts a SQL select output to a properties file.
# Inverse of properties2sql.py
#
# usage: sqlite3 <db> "SELECT ..." | sql2properties.py > <properties-file>
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import re

for line in sys.stdin:
    fields = line.strip().split("|")
    print fields[0] + ": " + "|".join(fields[1:])
