#!/usr/bin/env python

# Canonicalize two projects and compare the results. Projects are
# selected from the DB using their IDs or names. If run from the
# command line, print the difference to STDOUT and exit with a non-zero
# exit code.

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

from __future__ import print_function

import os, sys, shutil, subprocess, argparse
from subprocess import CalledProcessError

import bootstrap
import automate, automation
from export_project import export_project_db
from canonicalize_project import output_canonicalized_project

from bootstrap import VERBOSE

def compare(src_project=None, tgt_project=None, keep=False):
    project_ids = bootstrap.get_project_ids()
    if len(project_ids) < 2:
        raise ValueError("only %d projects present" % len(project_ids))
    if not src_project:
        src_project_id = project_ids[-2]
    else:
        src_project_id, _ = \
                bootstrap.get_project_id_and_name(src_project)
    if not tgt_project:
        tgt_project_id = project_ids[-1]
    else:
        tgt_project_id, _ = \
                bootstrap.get_project_id_and_name(tgt_project)
    if src_project_id == tgt_project_id:
        print("WARNING: project IDs are the same: %d" % src_project_id,
                file=sys.stderr)
    # canonicalize them both
    if keep:
        # retain in scale.app/tmp
        src_canon_file = bootstrap.get_tmp_file(
                basename="src.dat", ephemeral=False)
        tgt_canon_file = bootstrap.get_tmp_file(
                basename="tgt.dat", ephemeral=False)
    else:
        src_canon_file = bootstrap.get_tmp_file()
        tgt_canon_file = bootstrap.get_tmp_file()

    output_canonicalized_project(src_project_id, out=open(src_canon_file, 'w'))
    output_canonicalized_project(tgt_project_id, out=open(tgt_canon_file, 'w'))

    # compare, return the results
    diff = None
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
    return diff

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""
        Compare the canonicalized output of two existing projects
        """)
    parser.add_argument("-a", "--src-project", required=False,
            help="First project ID or name. Default: second to latest")
    parser.add_argument("-b", "--tgt-project", required=False,
            help="Second project ID or name. Default: latest")
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    parser.add_argument("-k", "--keep", action="store_true", help="""
            Keep, do not delete, the project created by the automation
            utilities
            """)
    args = parser.parse_args()
    res = compare(src_project=args.src_project,
            tgt_project=args.tgt_project, keep=args.keep)
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
