#!/usr/bin/env python

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

import os, sys, subprocess, sqlite3, argparse

import bootstrap
import init_shared_tables

from bootstrap import VERBOSE

def create_project_db(database, json=False, force=False):
    if os.path.exists(database):
        if force:
            os.unlink(database)
        else:
            print("database already exists: %s" % database)
            return
    if VERBOSE:
        print("creating project db:", database)
    create_db_sql_file = \
            os.path.join(bootstrap.scripts_dir, "create_scale_db.sql")
    subprocess.check_call(
        "sqlite3 '%s' < %s" % (database, create_db_sql_file), shell=True)
    # insert tools and languages into the database
    with sqlite3.connect(database) as con:
        cur = con.cursor()
        init_shared_tables.populate_tables(cur, external=True)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Initialize project database with tools")
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    parser.add_argument("database", help="Project database.")
    parser.add_argument("-f", "--force", action="store_true",
        help="Overwrite DB if it already exists")
    args = parser.parse_args()
    if args.database:
        database = args.database
    force = args.force
    if os.path.exists(database):
        if args.force:
            os.unlink(database)
        else:
            print("database already exists (use -f to overwrite): %s" % database)
            sys.exit()
    create_project_db(database, force=args.force)
