#!/usr/bin/env python

# <legal>
# SCALe version r.6.5.5.1.A
# 
# Copyright 2021 Carnegie Mellon University.
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

import sqlite3
import argparse
import os
import re


def main():
    parser = argparse.ArgumentParser(
        description="Filters out duplicate entries and recommendations")
    parser.add_argument("db", help="Database to filter")
    parser.add_argument(
        "--dupes",  help="Remove duplicate entries", action="store_true", default=False)
    parser.add_argument(
        "--recs", help="Remove recommendation entries", action="store_true", default=False)
    args = parser.parse_args()

    if args.dupes == False and args.recs == False:
        print("No actions selected")
        sys.exit(0)
    if not os.path.exists(args.db):
        raise Exception("Target database does not exist")

    conn = sqlite3.connect(args.db)
    conn.create_function("REGEXP", 2, rulexp)
    co = conn.cursor()  # Outer loop cursor
    ci = conn.cursor()  # Inner loop cursor
    cd = conn.cursor()  # Delete cursor
    changecount = 0
    if args.dupes:
        print("Entering duplicate removal stage")
        for dupes in co.execute('SELECT path,line,message FROM Messages GROUP BY path,line,message HAVING count(*) > 1'):
            ci.execute(
                'SELECT id FROM Messages WHERE path=? AND line=? AND message=?', (dupes[0], dupes[1], dupes[2]))
            ci.fetchone()
            for entry in ci.fetchall():
                cd.execute(
                    'DELETE FROM Alerts WHERE primary_msg=?', [entry[0]])
                cd.execute('DELETE FROM Messages WHERE id=?', [entry[0]])
        changecount = conn.total_changes
        print("Duplicate removal stage complete. " + str(changecount) + " changes made.")

    if args.recs:
        print("Entering recommendation removal stage")
        for recs in co.execute('SELECT name FROM Checkers WHERE rule REGEXP ?', ['[A-Z]*([0-9]*)-[A-Z]*']):
            for msgid in ci.execute('SELECT primary_msg FROM Alerts WHERE checker_id=?', [recs[0]]):
                cd.execute('DELETE FROM Messages WHERE id=?', [msgid[0]])
            cd.execute('DELETE FROM Alerts WHERE checker_id=?', [recs[0]])

        print("Recommendation removal stage complete. " + str(conn.total_changes - changecount) + " changes made.")

    co.close()
    ci.close()
    cd.close()
    conn.commit()
    conn.close()


def rulexp(expr, item):
    val = re.match(expr, item)
    if val is not None:
        if int(val.group(1)) <= 29:
            return True
    return False

if __name__ == "__main__":
    main()
