#!/usr/bin/env python

# Script takes two SCALe databases, an old and a new one.  Adds
# determinations to the new db storing verdict values from the old db.
# For an update, the file, line, checker, tool must all match.
# Typically the old db should have lines updated using patch_links.py,
# so their line match.
#
# Usage: ./transfer_verdicts.py <old-db> <new-db>
#
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

import os, sys, argparse, sqlite3

import bootstrap
from bootstrap import VERBOSE

def transfer_old_to_new(old_db, new_db, note=None):
    if not note:
        note = ""
    if not os.path.exists(old_db):
        raise Exception("Old database does not exist: %s" % old_db)
    if not os.path.exists(new_db):
        raise Exception("New database does not exist: %s" % new_db)
    imported_dets = set()
    with sqlite3.connect(new_db) as con:
        cur = con.cursor()
        cur.execute("ATTACH DATABASE '%s' as old" % old_db)
        sql = """
  SELECT DISTINCT main.MetaAlerts.id,
    old.Determinations.verdict, old.Determinations.flag,
    old.Determinations.notes, old.Determinations.ignored,
    old.Determinations.dead, old.Determinations.inapplicable_environment,
    old.Determinations.dangerous_construct
  FROM main.MetaAlerts
  JOIN main.MetaAlertLinks
    ON main.MetaAlertLinks.meta_alert_id = main.MetaAlerts.id
  JOIN main.Alerts ON main.Alerts.id = main.MetaAlertLinks.alert_id
  JOIN main.Messages ON main.Messages.id = main.Alerts.primary_msg
  JOIN main.Conditions ON main.Conditions.id = main.MetaAlerts.condition_id
  -- the twain shall meet
  JOIN old.Conditions ON old.Conditions.name = main.Conditions.name
  JOIN old.Messages ON old.Messages.path = main.Messages.path
    AND old.Messages.line = main.Messages.line
  --
  JOIN old.Alerts ON old.Alerts.primary_msg = old.Messages.id
  JOIN old.MetaAlertLinks ON old.MetaAlertLinks.alert_id = old.Alerts.id
  JOIN old.MetaAlerts ON old.MetaAlerts.id = old.MetaAlertLinks.meta_alert_id
  JOIN old.Determinations
    ON old.Determinations.meta_alert_id = old.MetaAlerts.id
  --
  ORDER BY main.MetaAlerts.id, old.Determinations.time DESC, old.Determinations.id DESC;
        """.strip()
        rows = cur.execute(sql).fetchall()
        try:
            # needs to be a list vs tuple or comp will fail
            trivial_det = [0, 0, "0", 0, 0, 0, 0]
            for row in (list(x) for x in rows):
                meta_alert = row[0]
                if meta_alert in imported_dets:
                    continue
                if row[1:] == trivial_det:
                    continue
                if row[3] and str(row[3]) != '0':
                    row[3] = "\n".join([row[3], note])
                else:
                    row[3] = note
                cur.execute("""
                    INSERT INTO main.Determinations
                    VALUES (NULL, 0, ?, DATETIME('now'), ?, ?, ?, ?, ?, ?, ?)
                """.strip(), row)
                imported_dets.add(meta_alert)
        except con.Error as err:
            print(err)
            print("would have imported %d determinations" % len(imported_dets))
            print("rolling back transaction")
    if VERBOSE:
        print("imported %d determinations" % len(imported_dets))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""
    Cascade/Propagate determinations from an older project into a new project.
    """)
    parser.add_argument('-v', '--verbose', action=bootstrap.Verbosity)
    parser.add_argument("old_db", help="DB file of old project")
    parser.add_argument("new_db", help="DB file of new project")
    parser.add_argument('-n', '--note', required=False, default="",
            help="Note to add with determinations")
    args = parser.parse_args()
    transfer_old_to_new(args.old_db, args.new_db, note=args.note)
