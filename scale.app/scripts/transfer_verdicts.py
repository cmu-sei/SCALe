#!/usr/bin/env python

# Script takes two SCALe databases, an old and a new one.  Updates the
# 'previous' field in the new db with verdict values from the old db.
# For an update, the file, line, checker, tool must all match.
#
# Usage: ./transfer_verdicts.py <old-db> <new-db>
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import os
import re
import sqlite3 as sqlite

if len(sys.argv) != 3:
    print "usage: ", sys.argv[0], " <old-db> <new-db>"
    exit(1)
old_db = sys.argv[1]
new_db = sys.argv[2]

# Build map from old db file
old_con = None
if not os.path.exists(old_db):
    raise Exception("Databse does not exist")
old_con = sqlite.connect(old_db)
with old_con:
    new_con = None
    if not os.path.exists(new_db):
        raise Exception("Databse does not exist")
    new_con = sqlite.connect(new_db)
    old_cur = old_con.cursor()
    with new_con:
        new_cur = new_con.cursor()
        new_cur.execute('SELECT path, line, checker, tool, Diagnostics.id FROM Messages, Diagnostics ' +
                        'WHERE Messages.id = Diagnostics.primary_msg')
        rows = new_cur.fetchall()
        for row in rows:
#            print "NEW_ROW: ",
#            print row
            old_cur.execute('SELECT verdict FROM Messages, Diagnostics ' +
                            'WHERE Messages.id = Diagnostics.primary_msg ' +
                            'AND Messages.path=? AND Messages.line=? ' +
                            'AND Diagnostics.checker=? AND Diagnostics.tool=?',
                            row[:4])
            old_rows = old_cur.fetchall()
            for old_row in old_rows:
#                print "OLD_ROW: ",
#                print old_row
                if old_row[0] != 0:
                    new_cur.execute(
                        "UPDATE Diagnostics SET previous=? WHERE id=?",
                                    [old_row[0], row[4]])

        new_con.commit()
