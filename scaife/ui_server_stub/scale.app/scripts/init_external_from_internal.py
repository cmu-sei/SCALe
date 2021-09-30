#!/usr/bin/env python
#
# Python script for creating/initializing external project DBs entirely
# from the internal SCALe database (db/development.sqlite3 or
# db/test.sqlite3, depending on $RAILS_ENV).
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

from __future__ import print_function

import os, sys, re, argparse
import subprocess
from subprocess import CalledProcessError

import bootstrap
from bootstrap import VERBOSE

class ExportProblem(Exception):
    pass

def init_external_project(proj_id, force=False):
    pid, _ = bootstrap.get_project_id_and_name(proj_id)
    if not pid:
        raise ExportProblem("project does not exist: %s" % pid)
    dbf = bootstrap.project_backup_db(pid)
    if not force and os.path.exists(dbf):
        raise ExportProblem("project %s db exists (use force=True): %s"
                % (pid, bootstrap.rel2scale_path(dbf)))
    cmd = "print AlertConditionsController.archiveDB(%d, initialize: true, force: true)" % pid
    dbf = bootstrap.run_rails_cmd(cmd)
    dbf = re.split(r"\n+", dbf)[-1]
    if not dbf:
        raise RuntimeError("Unable to archive project: %d" % pid)
    if VERBOSE:
        print("exported project %s to: %s"
                % (proj_id, bootstrap.rel2scale_path(dbf)))
    return dbf

def create_external_from_internal(proj_ids_or_names=None, force=False):
    if not proj_ids_or_names:
        proj_ids_or_names = bootstrap.get_project_ids()
    proj_ids_or_names = set(int(x) for x in proj_ids_or_names)
    proj_ids = set()
    unknowns = set()
    for id_or_name in proj_ids_or_names:
        try:
            pid, _ = bootstrap.get_project_id_and_name(id_or_name)
        except ValueError:
            unknowns.add(id_or_name)
            continue
        dbf = bootstrap.project_backup_db(pid)
        if not force and os.path.exists(dbf):
            raise ExportProblem("project %s db exists (use force=True): %s"
                    % (pid, bootstrap.rel2scale_path(dbf)))
        proj_ids.add(pid)
    if unknowns:
        raise ExportProblem(
            "unknwon projects: %s" % ','.join(
                str(x) for x in sorted(unknowns)))
    if not proj_ids:
        raise ExportProblem("no projects currently exist in SCALe")
        sys.exit(1)
    for pid in sorted(proj_ids):
        init_external_project(pid, force=force)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""
        Initialize (and optionally destroy prior) all external project
        databases and repopulate them using data from the internal
        database (internal DB for RAILS_ENV=%s is currently %s). This
        can be useful for when the DB schemas change with a new release
        of SCALe. The rails migration process will update the internal
        DB schemas and data; this script will effectively migrate the
        external DB schemas and data.
    """ % (bootstrap.rails_env, bootstrap.rel2scale_path(bootstrap.internal_db)))
    parser.add_argument("projects", nargs="*",
        help="Project IDs or names to export. Default: all projects.")
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    parser.add_argument("-f", "--force", action="store_true",
        help="First delete external project databases if they currently exist.")
    args = parser.parse_args()
    try:
        create_external_from_internal(proj_ids_or_names=args.projects,
            force=args.force)
    except ExportProblem as e:
        print("%s" % e, file=sys.stderr)
        sys.exit(1)
