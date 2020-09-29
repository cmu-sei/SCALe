#!/usr/bin/env python

# This will use one of the automation modules, as specified by a
# "scenario" label, to create a project (the 'target' project) and then
# compare its canonical representation to an already existing project
# (the 'source' project) -- the existing source project can be
# explicitly selected or it will default to the most recent project in
# the SCALe database.

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

from __future__ import print_function

import os, sys, shutil, subprocess, argparse
from subprocess import CalledProcessError

import bootstrap
import automate, automation
from export_project import export_project_db
from canonicalize_project import output_canonicalized_project

from bootstrap import VERBOSE

# Scenarios are just shorthand labels for the more lengthy
# script/module names
scenario_scripts = {
    "1a": "create_manual_test_project_1_dos2unix_rosecheckers.py",
    "1b": "create_manual_test_project_1_microjuliet_cppcheck.py",
}

def generate_and_compare(scenario, src_project=None, keep=False):
    # Given a source project (defaults to whatever the last created
    # project in the database is):
    # 1. Generate a new project (target) using the automation scripts
    #    and the given scenario (a scenario shorthand for one fo the
    #    automation scripts/recipies
    # 2. Canonicalize both source and target projects.
    # 3. Compare the results -- if they're different, return the
    #    diff output.
    if not scenario:
        raise RuntimeError("automation scenario required")
    if src_project is None:
        src_project_id = bootstrap.get_latest_project_id()
    else:
        src_project_id, _ = \
                bootstrap.get_project_id_and_name(src_project)
    if not src_project_id:
        raise RuntimeError("no existing project_id found")
    tgt_project_id = None
    diff = None
    try:
        if VERBOSE:
            print("running automation scenario: %s" % scenario)
        func = automation.scenario_function(scenario)
        tgt_project_id = func()

        print("src_project_id: %s" % src_project_id)
        print("tgt_project_id: %s" % tgt_project_id)

        # canonicalize them both
        if keep:
            # retain in scale.app/tmp/src.sqlite3
            src_canon_file = bootstrap.get_tmp_file(
                    basename="src.dat", ephemeral=False)
        else:
            src_canon_file = bootstrap.get_tmp_file()
        if keep:
            # retain in scale.app/tmp/tgt.sqlite3
            tgt_canon_file = bootstrap.get_tmp_file(
                    basename="tgt.dat", ephemeral=False)
        else:
            tgt_canon_file = bootstrap.get_tmp_file()

        output_canonicalized_project(src_project_id,
                out=open(src_canon_file, 'w'))
        output_canonicalized_project(tgt_project_id,
                out=open(tgt_canon_file, 'w'))

        # compare
        err = subprocess.call(["cmp", src_canon_file, tgt_canon_file])
        if err != 0:
            print("oops, cmp non-zero exit: %s" % err)
            try:
                diff = subprocess.check_output(
                    ["diff", src_canon_file, tgt_canon_file],
                    stderr=subprocess.STDOUT)
            except CalledProcessError, e:
                diff = e.output
                print("diff non-zip exit code")
    finally:
        # delete the automation/target project by default
        if tgt_project_id:
            if keep:
                if VERBOSE:
                    print("retaining automation project: %s" % tgt_project_id)
            else:
                if VERBOSE:
                    print("destroying automation project: %s" % tgt_project_id)
                sess = automate.ScaleSession()
                sess.set_project_id(tgt_project_id)
                sess.query_project_destroy()
        else:
            msg = "no automation project id was returned"
            print(msg)
            if diff:
                diff += "\n%s" % msg
            else:
                diff = msg
    return diff

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""
        Automatically create and compare a new project (target) to an
        existing project (source). The source project defaults to the
        most recent project in the SCALe DB.
        """)
    parser.add_argument("scenario", help="""
        Automation scenario, either the script name or one of: %s
        """ % (", ".join(sorted(scenario_scripts))))
    parser.add_argument("-p", "--project", help="""
        Project ID or name to export prior to comparing. Default: latest
        """)
    parser.add_argument("-k", "--keep", action="store_true", help="""
        Keep, do not delete, the project created by the automation
        utilities. Additionally, keep the canonicalized outputs in
        tmp//src.dat and tmp/tgt.dat
        """)
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    args = parser.parse_args()
    res = generate_and_compare(
            args.scenario, src_project=args.project, keep=args.keep)
    # exit with non-zero exit code if projects don't match
    if res:
        print(res)
        if VERBOSE:
            print("\nprojects do not match")
        sys.exit(1)
    else:
        if VERBOSE:
            print("projects match")
        sys.exit(0)
