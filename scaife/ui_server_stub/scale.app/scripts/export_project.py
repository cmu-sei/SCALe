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

import os, sys, shutil, subprocess, argparse
from subprocess import CalledProcessError

import bootstrap
from bootstrap import VERBOSE

def export_project_db(project_id, output_file=None, force=False):
    cwd = os.getcwd()
    dbf = None
    if not force and output_file and os.path.exists(output_file) \
            and output_file != bootstrap.external_db():
        raise ValueError("db already exists: %s" % database)
    try:
        os.chdir(bootstrap.base_dir)
        cmd = ["bin/rails",
            "-r", "./config/environment",
            "-r", "alert_conditions_controller",
           "-e", "print AlertConditionsController.archiveDB(%d)" % project_id]
        dbf = subprocess.check_output(cmd).strip()
        if dbf and not os.path.exists(dbf):
            print("errant ruby result: [%s]" % dbf)
            cmd[-1] = '"%s"' % cmd[-1]
            print("cmd: %s" % ' '.join(cmd))
    except CalledProcessError as e:
        msg = "ruby command failed:\n%s" % e.output
        raise RuntimeError(msg)
    finally:
        os.chdir(cwd)
    if not dbf:
        print("Unable to export project: %d" % project_id)
    if output_file and output_file != dbf:
        # this will clobber output_file
        shutil.copy(dbf, output_file)
        dbf = output_file
    return dbf


if __name__== "__main__":
    parser = argparse.ArgumentParser(
        description="Export project to external DB")
    parser.add_argument("project_id_or_name", help="Name or ID of project")
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    parser.add_argument("-d", "--database", default=bootstrap.external_db(),
            help="Output DB file")
    parser.add_argument("-f", "--force", action="store_true",
        help="Overwrite DB if it already exists and is not the default output")
    args = parser.parse_args()
    if args.database:
        database = args.database
    project_id = bootstrap.get_project_id(args.project_id_or_name)[0]
    export_project_db(project_id, output_file=database, force=args.force)
