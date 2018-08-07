#!/usr/bin/env python

# These instructions are obsolete...this has been integrated
# into SCALe's database structure
#
# Python script that converts org table (created by an SA tool)
# to a series of SQL 'insert' commands, and inserts contents into a database
#
# usage: saorg2sql.py <tool> <database> < <org-file> | sqlite3 <db>
#
# Copyright (c) 2007-2018 Carnegie Mellon University.
# All Rights Reserved. See COPYRIGHT file for details.

from collections import OrderedDict
import re
import sys
import scale
import sqlite3 as sqlite


if len(sys.argv) != 3:
    raise TypeError("Usage: " + sys.argv[
                    0] + " <tool> <database> < <org-file>")
tool = int(sys.argv[1])
msg_id = tool
diag_id = tool
meta_id = 0
incr = 100
database = sys.argv[2]


def find_new_id(con, id, table):
    while con.execute("SELECT * FROM " + table + " WHERE id=" +
                      str(id)).fetchone() is not None:
        id += 1
    return id


# print scale.SQL_Begin
con = None
con = sqlite.connect(database)
con.text_factory = str
orphans = dict()
with con:
    cur = con.cursor()
# Unsafe; this does not prevent id collision
#    diag_id = cur.execute(
#        "SELECT count(*) FROM Diagnostics").fetchone()[0] + diag_id

    cur.execute("SELECT * FROM Checkers where tool=?;", [str(tool)])
    
    """
      OrderedDict is needed here in order to match the regexes in the correct
      order they appear in the *.re.properties files. Python's dict() does not 
      guarantee the order of the keys.
    """
    checkDict = OrderedDict()
    for entry in cur.fetchall():
        chk_id = entry[0]
        chk_name = entry[1]
        checkDict[chk_name] = chk_id

    for line in sys.stdin:
        line = line.strip()
        if line.startswith("|-") or not line.startswith("|"):
            continue

        fields = line.split("|")[1:-1]
        checker = fields[0].strip()

        if checker != "":
            try:
                checker = str(checkDict[checker])
            except:
                orphans[checker] = 1
                continue
        else:
            msg = fields[3].strip()
            flag = 1
            for key in checkDict.keys():
                try:
                    if re.match(key, msg):
                        checker = str(checkDict[key])
                        flag = 0
                        break
                except re.error:
                    pass
            if flag:
                orphans[checker] = 1

        diag_id = find_new_id(cur, diag_id, "Diagnostics")
        msg_id = find_new_id(cur, msg_id, "Messages")
        cur.execute("INSERT INTO \"Diagnostics\" VALUES(?,?,?,?,?);",
                    [str(diag_id),               # diagnostic id
                     checker,                    # checker
                     unicode(msg_id),            # 'primary' message
                     "0",                        # confidence
                     "0"])                       # alert priority

        msg_index = 1
        while msg_index < len(fields) - 1:
            msg_fields = [str(msg_id),
                          str(diag_id),
                          scale.CSV_Quote(
                              fields[msg_index]),   # path
                          fields[msg_index + 1],    # line number
                          scale.CSV_Quote(fields[msg_index + 2])]  # msg

            cur.execute(
                "INSERT INTO \"Messages\" VALUES(" +
                ",".join(msg_fields) + ");")
            msg_id += incr
            msg_index += 3
        diag_id += incr

# print scale.SQL_End

if len(orphans) > 0:
    print("[Warning] These checkers have no mappings associated with them: " +
          str(orphans.keys()))
