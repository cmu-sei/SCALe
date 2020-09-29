#!/bin/env python

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

import pytest

import os, sys, json, subprocess
import atexit, shutil, tempfile, zipfile
import sqlite3

from subprocess import CalledProcessError

VERBOSE = (os.environ.get("VERBOSE") or "").lower()
if VERBOSE in ("", "no", "false", "0", "none"):
    VERBOSE = False
else:
    VERBOSE = True

test_dir = os.path.dirname(os.path.abspath(__file__))
dat_dir = os.path.join(test_dir, "data/digestalerts")
analysis_dir = os.path.join(dat_dir, "analysis")
scale_dir = os.path.dirname(os.path.dirname(test_dir))
scripts_dir = os.path.join(scale_dir, "scripts")
da_script = os.path.join(scripts_dir, "digest_alerts.py")

class TestDigestAlerts(object):

    def test_fortify(self, capsys):
        tmp_dir = make_tmp_dir()
        tool_name = "fortify"
        tool_output = os.path.join(analysis_dir, "%s.xml" % tool_name)
        src_dir = os.path.join(tmp_dir, "src")
        src_archive = os.path.join(dat_dir, "jasper-1.900.zip")
        unzip_to_dir(src_archive, src_dir)
        db = os.path.join(tmp_dir, "db.sqlite")
        db = os.path.join(scale_dir, 'tmp/x.sqlite3')
        if os.path.exists(db):
            os.unlink(db)
        platform = "c/cpp"
        version = "18.10.0187"
        cmd = [da_script, db, tool_output,
                "--tool-name", tool_name,
                "--tool-platform", platform,
                "--tool-version", version,
               '--src-dirs', src_dir]
        with capsys.disabled():
            res = subprocess.check_output(cmd)
            if VERBOSE and len(res):
                print(' '.join(cmd))
                print(res)
        with sqlite3.connect(db) as con:
            cur = con.cursor()
            tool_id = self._tool_id(cur, tool_name, platform, version=version)
            cur.execute("SELECT COUNT(*) FROM Alerts")
            cnt = cur.fetchone()[0]
            assert cnt == 32, "32 Alerts"
            cur.execute("SELECT COUNT(*) FROM MetaAlerts")
            cnt = cur.fetchone()[0]
            assert cnt == 22, "22 MetaAlerts"
            cnt = self._count_checkers(cur, tool_id)
            assert cnt == 57, "57 Checkers"
            cnt = self._count_conditions(cur, tool_id)
            assert cnt == 54, "54 Conditions"
        os.unlink(db)
        tool_output = os.path.join(analysis_dir, "%s.xml" % tool_name)
        version = "6.10.0120"
        cmd = [da_script, db, tool_output,
                "--tool-name", tool_name,
                "--tool-platform", platform,
                "--tool-version", version,
               '--src-dirs', src_dir]
        with capsys.disabled():
            res = subprocess.check_output(cmd)
            if VERBOSE and len(res):
                print(' '.join(cmd))
                print(res)
        with sqlite3.connect(db) as con:
            cur = con.cursor()
            tool_id = self._tool_id(cur, tool_name, platform, version=version)
            cur.execute("SELECT COUNT(*) FROM Alerts")
            cnt = cur.fetchone()[0]
            assert cnt == 32, "32 Alerts"
            cur.execute("SELECT COUNT(*) FROM MetaAlerts")
            cnt = cur.fetchone()[0]
            assert cnt == 22, "22 MetaAlerts"
            cnt = self._count_checkers(cur, tool_id)
            assert cnt == 51, "51 Checkers"
            cnt = self._count_conditions(cur, tool_id)
            assert cnt == 48, "48 Conditions"

    def test_cppcheck(self, capsys):
        tmp_dir = make_tmp_dir()
        tool_name = "cppcheck_oss"
        tool_output = os.path.join(analysis_dir, "%s_v100.xml" % tool_name)
        src_dir = os.path.join(tmp_dir, "src")
        src_archive = os.path.join(dat_dir, "dos2unix-7.2.2.zip")
        unzip_to_dir(src_archive, src_dir)
        db = os.path.join(tmp_dir, "db.sqlite")
        platform = "c/cpp"
        version = "1.00"
        cmd = [da_script, db, tool_output,
                "--tool-name", tool_name,
                "--tool-platform", platform,
                "--tool-version", version,
               '--src-dirs', src_dir]
        with capsys.disabled():
            res = subprocess.check_output(cmd)
            if VERBOSE and len(res):
                print(' '.join(cmd))
                print(res)
        with sqlite3.connect(db) as con:
            cur = con.cursor()
            tool_id = self._tool_id(cur, tool_name, platform, version=version)
            cur.execute("SELECT COUNT(*) FROM Alerts")
            cnt = cur.fetchone()[0]
            assert cnt == 576, "576 Alerts"
            cur.execute("SELECT COUNT(*) FROM MetaAlerts")
            cnt = cur.fetchone()[0]
            assert cnt == 521, "521 MetaAlerts"
            cnt = self._count_checkers(cur, tool_id)
            assert cnt == 314, "314 Checkers"
            cnt = self._count_conditions(cur, tool_id)
            assert cnt == 432, "432 Conditions"
        os.unlink(db)
        tool_output = os.path.join(analysis_dir, "%s_v183.xml" % tool_name)
        version = "1.86"
        cmd = [da_script, db, tool_output,
                "--tool-name", tool_name,
                "--tool-platform", platform,
                "--tool-version", version,
                "--src-dirs", src_dir]
        with capsys.disabled():
            res = subprocess.check_output(cmd)
            if VERBOSE and len(res):
                print(' '.join(cmd))
                print(res)
        with sqlite3.connect(db) as con:
            cur = con.cursor()
            tool_id = self._tool_id(cur, tool_name, platform, version=version)
            cur.execute("SELECT COUNT(*) FROM Alerts")
            cnt = cur.fetchone()[0]
            assert cnt == 24, "24 Alerts"
            cur.execute("SELECT COUNT(*) FROM MetaAlerts")
            cnt = cur.fetchone()[0]
            assert cnt == 21, "21 MetaAlerts"
            cnt = self._count_checkers(cur, tool_id)
            assert cnt == 315, "315 Checkers"
            cnt = self._count_conditions(cur, tool_id)
            assert cnt == 432, "432 Conditions"

    def test_gcc(self, capsys):
        # this is primarily to test regex digestion
        tmp_dir = make_tmp_dir()
        tool_name = "gcc_oss"
        tool_output = os.path.join(analysis_dir, "%s_jasper.txt" % tool_name)
        src_dir = os.path.join(tmp_dir, "src")
        src_archive = os.path.join(dat_dir, "jasper-1.900.zip")
        unzip_to_dir(src_archive, src_dir)
        db = os.path.join(tmp_dir, "db.sqlite")
        platform = "c/cpp"
        cmd = [da_script, db, tool_output,
                "--tool-name", tool_name,
                "--tool-platform", platform,
               '--src-dirs', src_dir]
        with capsys.disabled():
            res = subprocess.check_output(cmd)
            if VERBOSE and len(res):
                print(' '.join(cmd))
                print(res)
        with sqlite3.connect(db) as con:
            cur = con.cursor()
            tool_id = self._tool_id(cur, tool_name, platform)
            cur.execute("SELECT COUNT(*) FROM Alerts")
            cnt = cur.fetchone()[0]
            assert cnt == 78, "78 Alerts"
            cur.execute("SELECT COUNT(*) FROM MetaAlerts")
            cnt = cur.fetchone()[0]
            assert cnt == 45, "45 MetaAlerts"
            cnt = self._count_checkers(cur, tool_id)
            assert cnt == 85, "85 Checkers"
            cnt = self._count_conditions(cur, tool_id)
            assert cnt == 76, "76 Conditions"
        os.unlink(db)

    def _count_checkers(self, cur, tool_id):
        cur.execute(
            "SELECT COUNT(*) FROM Checkers WHERE tool_id = ?", [tool_id])
        cnt = cur.fetchone()[0]
        return cnt

    def _count_conditions(self, cur, tool_id):
        cur.execute("""
SELECT COUNT(Conditions.id)
FROM Conditions
INNER JOIN ConditionCheckerLinks ON ConditionCheckerLinks.condition_id = Conditions.id
INNER JOIN Checkers ON Checkers.tool_id = ? AND Checkers.id = ConditionCheckerLinks.checker_id
        """.strip(), [tool_id])
        cnt = cur.fetchone()[0]
        return cnt

    def _tool_id(self, cur, name, platform, version=None):
        platform = json.dumps(platform.split('/'))
        sql = "SELECT id FROM Tools WHERE name = ? AND platform = ?"
        if version:
            sql += " AND version = ?"
            cur.execute(sql, [name, platform, version])
        else:
            cur.execute(sql, [name, platform])
        row = cur.fetchone()
        return row[0]

def unzip_to_dir(archive, tgt_dir):
    zippy = zipfile.ZipFile(archive, 'r')
    if not os.path.exists(tgt_dir):
        os.makedirs(tgt_dir)
    zippy.extractall(tgt_dir)
    zippy.close()

def make_tmp_dir():
    tmp_dir = tempfile.mkdtemp()
    def _temp_cleanup():
        shutil.rmtree(tmp_dir, True)
    atexit.register(_temp_cleanup)
    return tmp_dir


if __name__ == '__main__':
    pytest.main()
