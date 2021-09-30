#!/usr/bin/env python

# Script converts from SCALe v1 db to SCALe v2 db.
#
# The target database should have been created with
# digest_diagnostics.py when given empty input for the correct
# language. This way it gets the correct tool/checker/rule info.
#
# This script gives the target database the appropriate diagnostics,
# messages, meta-alerts, and determinations.
#
# <legal>
# SCALe version r.6.7.0.0.A
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

import argparse
import scale
import sqlite3 as sqlite

parser = argparse.ArgumentParser(
    description="Converts SCALe v1 data to a SCALe v2 db")
parser.add_argument(
    "database1", help="Database version 1.")
parser.add_argument(
    "database2", help="Database version 2.")

args = parser.parse_args()


# Returns tuple of determinations to insert, based on old verdict
# New verdicts: Unknown, Complex, False, Dependent, True
Verdict_Translation_Map = {      # Old Verdicts:
    0: [0, 0, "0", 0, 0, 0, 0],  # Unknown
    1: [0, 0, "0", 1, 0, 0, 0],  # Ignored = unknown + Ignored-flag
    2: [2, 0, "0", 0, 0, 0, 0],  # False
    3: [0, 0, "0", 0, 0, 0, 1],  # Suspicious = unknown + Dangerous:Low
    4: [4, 0, "0", 0, 0, 0, 0],  # True
}


con1 = sqlite.connect(args.database1)
con1.row_factory = sqlite.Row
with con1:
    con2 = sqlite.connect(args.database2)
    con2.row_factory = sqlite.Row
    with con2:
        # First, copy messages over
        # con1.execute("SELECT * FROM Messages")
        # for message in con1.fetchall():
        #     print("INSERT INTO Messages VALUES(" + ",".join(message) + ")")

        # Now diagnostics (which go into several tables)
        # con1.execute("SELECT * FROM Diagnostics")
        # diag_id = 0
        # meta_alert_id = 0
        # det_id = 0
        # for d in con1.fetchall():
        #     checker = con2.execute("SELECT id FROM Checkers WHERE name=?",
        # d[4]).fetchone()  # checker id
        #     print("INSERT INTO Diagnostics VALUES(" +
        # d[0] + "," +        # id
        #           scale.CSV_Quote(checker[0]) + "," +
        # d[6] + ")")          # primary_msg

        msg_id = scale.find_new_id(con2, 99, "Messages")
        diag_id = scale.find_new_id(con2, 99, "Diagnostics")
        meta_id = scale.find_new_id(con2, 1, "MetaAlerts")
        det_id = scale.find_new_id(con2, 1, "Determinations")
        # First, copy manual diagnostics over.
        # We assume each manual diagnostic constitutes its own
        # meta-alert (eg they do not share alerts with each other or
        # other diagnostics)
        matches = con1.execute('''
SELECT Messages.path, Messages.line, Messages.message
 FROM Diagnostics JOIN Messages ON Diagnostics.primary_msg=Messages.id
 WHERE Diagnostics.checker='manual' AND Diagnostics.tool='manual'
;''').fetchall()
        if len(matches) > 0:
            manual_checker_id = scale.find_new_id(con2, 1, "Checkers")
            con2.execute("INSERT INTO Checkers VALUES(?,?,?,?)",
                         [manual_checker_id, "manual", "manual", 0])

        for diagnostic in matches:
            con2.execute("INSERT INTO Messages VALUES(?,?,?,?,?)",
                         [msg_id, diag_id,
                          diagnostic["path"],
                          diagnostic["line"],
                          diagnostic["message"]])
            con2.execute("INSERT INTO Diagnostics VALUES(?,?,?,?,?)",
                         [diag_id, manual_checker_id,
                          msg_id, 0, 0])
            con2.execute("INSERT INTO MetaAlerts VALUES(?,?)",
                         [meta_id, 0])  # 0 = manual tool
            con2.execute("INSERT INTO DiagnosticMetaAlertLinks VALUES(?,?)",
                         [diag_id, meta_id])
            con2.execute(
                "INSERT INTO Determinations VALUES(" +
                "?,?,DATETIME('now'),?,?,?,?,?,?,?)",
                [det_id, meta_id, 0, 0, "0", 0, 0, 0, 0])
            msg_id = scale.find_new_id(con2, msg_id, "Messages")
            diag_id = scale.find_new_id(con2, diag_id, "Diagnostics")
            meta_id = scale.find_new_id(con2, meta_id, "MetaAlerts")
            det_id = scale.find_new_id(con2, det_id, "Determinations")

        # Now look for verdicts to add
        for diagnostic in con1.execute('''
SELECT Diagnostics.flag, Diagnostics.verdict, Diagnostics.previous,
    Diagnostics.checker, Diagnostics.tool,
    Messages.path, Messages.line
 FROM Diagnostics JOIN Messages ON Diagnostics.primary_msg=Messages.id
 WHERE Diagnostics.flag!=0 OR Diagnostics.verdict!=0
    OR Diagnostics.previous!=0;
'''):
            meta_ids = con2.execute(
                '''
SELECT DISTINCT DiagnosticMetaAlertLinks.meta_alert_id
  FROM DiagnosticMetaAlertLinks
  JOIN Diagnostics ON Diagnostics.id=DiagnosticMetaAlertLinks.diagnostic
  JOIN Checkers ON Diagnostics.checker = Checkers.id
  JOIN Messages ON Diagnostics.primary_msg = Messages.id
 WHERE Checkers.name=? AND Checkers.tool_id=?
   AND Messages.path=? AND Messages.line=?
;''',
                [diagnostic["checker"], diagnostic["tool"],
                 diagnostic["path"], diagnostic["line"]]).fetchall()

            if len(meta_ids) == 0:
                print("WARNING: Not in the SCALe2 database:")
                print(diagnostic)
            for meta_id in meta_ids:
                current_verdict = Verdict_Translation_Map[0]  # unknown
                # First add previous verdict (if not unknown)
                if diagnostic["previous"] != 0:
                    current_verdict = Verdict_Translation_Map[
                        diagnostic["previous"]]
                    con2.execute(
                        "INSERT INTO Determinations VALUES(" +
                        "?,?,DATETIME('now'),?,?,?,?,?,?,?)",
                        [det_id, meta_id[0]] + current_verdict)
                    det_id = scale.find_new_id(con2, det_id, "Determinations")

                # Now add current verdict (if not unknown)
                if diagnostic["verdict"] != 0:
                    current_verdict = Verdict_Translation_Map[
                        diagnostic["verdict"]]
                    con2.execute(
                        "INSERT INTO Determinations VALUES(" +
                        "?,?,DATETIME('now'),?,?,?,?,?,?,?)",
                        [det_id, meta_id[0]] + current_verdict)
                    det_id = scale.find_new_id(con2, det_id, "Determinations")

                # Finally, add flag, if set
                if diagnostic["flag"] != 0:
                    new_verdict = list(current_verdict)
                    new_verdict[1] = 1  # flag = true
                    con2.execute(
                        "INSERT INTO Determinations VALUES(" +
                        "?,?,DATETIME('now'),?,?,?,?,?,?,?)",
                        [det_id, meta_id[0]] + new_verdict)
                    det_id = scale.find_new_id(con2, det_id, "Determinations")
