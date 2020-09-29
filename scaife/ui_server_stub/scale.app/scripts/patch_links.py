#!/usr/bin/env python

# Script takes a patch file, and digests it. Patch files are created
# with a diff. The diff should be normal (eg not context / unified,
# etc).  It should be created by diffing an old codebase with a new
# one, in the old codebases's directory
#
# Then it takes a SCALe database, which should have been created with
# the old codebase. It applies the patch diffs to each link, updating
# line numbers. If link refers to code deleted in the patch, the line
# number is set to -1 (invalid value, should not match any valid line)
#
# The paths in the SCALe database should start with "/", not "./".
#
# Changes nothing in the database except line numbers.
#
# Usage: patch_links.py <patch-file> <db>
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
import os
import re
import bisect
import sqlite3 as sqlite


class diff:

    @staticmethod
    def create(value):
        return diff(value, value, value, value)

    def __init__(self, old_min, old_max, new_min, new_max):
        self.old_min = old_min
        self.old_max = old_max
        self.new_min = new_min
        self.new_max = new_max

    def __cmp__(self, that):
        return self.old_min.__cmp__(that.old_min)

    def __str__(self):
        return str(self.old_min) + "," + str(self.old_max) + "c" \
            + str(self.new_min) + "," + str(self.new_max)


def binary_search(a, x, lo=0, hi=None):
    if hi is None:
        hi = len(a)
    while lo < hi:
        mid = (lo + hi) // 2
        midval = a[mid]
        if midval < x:
            lo = mid + 1
        elif midval > x:
            hi = mid
        else:
            return mid
    return lo


patch = dict()

if len(sys.argv) < 3:
    print("usage: ", sys.argv[0], " <patch-file> <db>")
    exit(1)
db = sys.argv[2]


with open(sys.argv[1]) as f:
    for line in f:
        parse = re.match(r"^diff .*? ([^ ]*?) ([^ ]*?)$", line)
        if parse is not None:
            path = parse.group(1).strip()
            if path.startswith("./"):
                path = path[1:]
            patch[path] = list()

        parse = re.match(r"^([0-9,]*)([acd])([0-9,]*)$", line)
        if parse is not None:
            old_range = parse.group(1)
            action = parse.group(2)
            new_range = parse.group(3)

            # The max values represent inclusive intervals, a 0-size interval
            # has max > min
            parse = re.match(r"^([0-9]*),([0-9]*)$", old_range)
            if parse is not None:
                old_min = int(parse.group(1))
                old_max = int(parse.group(2))
            else:
                old_min = int(old_range)
                old_max = old_min
            parse = re.match(r"^([0-9]*),([0-9]*)$", new_range)
            if parse is not None:
                new_min = int(parse.group(1))
                new_max = int(parse.group(2))
            else:
                new_min = int(new_range)
                new_max = new_min

            if (action == "a"):
                old_max = old_min
            if (action == "d"):
                new_max = new_min

            patch[path].append(diff(old_min, old_max, new_min, new_max))
    
con = None
if not os.path.exists(db):
    raise Exception("Database does not exist")
con = sqlite.connect(db)
# Now go through database, updating line numbers
with con:
    cur = con.cursor()
    cur.execute('SELECT id, path, line FROM Messages')
 
    rows = cur.fetchall()
    for row in rows:
        msg_id = row[0]
        path = row[1]
        line = int(row[2])
 
        # apply offsets
        if (path not in patch):  # file not modified, no update necessary
            continue
 
        index = bisect.bisect_right(patch[path], diff.create(line)) - 1
        if (index == -1):  # at beginning of file, no update necessary
            continue
 
        #print("Relevant index is ", str(patch[path][index]))
 
        if (line <= patch[path][index].old_max):  # modified; delete
            new_line = -1
            # print("line deleted")
        else:
            offset = patch[path][index].new_max - patch[path][index].old_max
            new_line = line + offset
            # print("New line is " + str(new_line))
 
        cur.execute(
            "UPDATE Messages SET line=? WHERE id=?", (new_line, msg_id))
        # print("UPDATE Messages SET line=? WHERE id=?", (new_line, msg_id))
        # print("line was ", str(line))
    con.commit()
