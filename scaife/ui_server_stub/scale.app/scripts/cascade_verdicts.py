#!/usr/bin/env python

# Script updates database given earlier database and source files.
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

import argparse
import os
import subprocess
import tempfile
import shutil

import bootstrap
from bootstrap import VERBOSE
from transfer_verdicts import transfer_old_to_new

def cascade(old_db, new_db, old_src, new_src, note=None):
    if not note:
        note = ""
    owd = os.getcwd()
    # Give all files absolute paths
    if not old_db.startswith("/"):
        old_db = os.path.join(owd, old_db)
    if not new_db.startswith("/"):
        new_db = os.path.join(owd, new_db)
    if not old_src.startswith("/"):
        old_src = os.path.join(owd, old_src)
    if not new_src.startswith("/"):
        new_src = os.path.join(owd, new_src)
    tmpdir = bootstrap.get_tmp_dir()
    old_db_copy = os.path.join(tmpdir, "old_db.sqlite3")
    try:
        shutil.copyfile(old_db, old_db_copy)
        os.chdir(old_src)
        subprocess.call("diff -r  .  " + new_src +
                " > " + tmpdir + "/patch", shell=True)
        script = os.path.join(bootstrap.scripts_dir, "patch_links.py")
        patch_file = os.path.join(tmpdir, "patch")
        subprocess.check_call(
            "%s %s %s" % (script, patch_file, old_db_copy), shell=True)
        transfer_old_to_new(old_db_copy, new_db, note=note)
    finally:
        os.chdir(owd)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Cascades verdicts from an old scale database to a new one",
        epilog='''
            Old database is NOT modified (a clone is modified, then removed)
            New database is modified, to contain verdicts.
        ''')
    parser.add_argument('-v', '--verbose', action=bootstrap.Verbosity)
    parser.add_argument("old_db", help="Database with verdicts")
    parser.add_argument("new_db", help="Database for verdicts to be cascaded to")
    parser.add_argument("old_src", help="Path of audited (old) source code")
    parser.add_argument("new_src", help="Path of un-audited (new) source code")
    parser.add_argument("-n", "--note", default="",
            help="Note to be added to cascaded verdicts")
    args = parser.parse_args()
    cascade(args.old_db, args.new_db, args.old_src, args.new_src, note=args.note)
