#!/usr/bin/env python

# This is a simple script that uses the automation utilities to do
# nothing but delete a given project (ID or name) from the database.

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

import sys, os, argparse

import bootstrap
from automate import ScaleSession, FetchError

from bootstrap import VERBOSE

def main(project):
    if os.path.exists(bootstrap.development_db()):
        # only resolve project name if db is hosted locally
        project_id, project_name = bootstrap.project_id_and_name(project)
        if not project_id:
            raise ValueError("project not found: %s" % project)
    else:
        project_id, project_name = project, None
    
    sess = ScaleSession()
    sess.set_project_id(project_id)
    try:
        sess.query_project_destroy()
        if VERBOSE:
            if project_name:
                print "project deleted: %d - %s" % (project_id, project_name)
            else:
                print "project deleted: %d" % project_id
    except FetchError, e:
        print("error: %d %s" % (e.message[0:2]))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""
        Delete a SCALe project from the database along with all
        of its associated data.
        """)
    parser.add_argument("project", help="Project name or id")
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    args = parser.parse_args()
    main(args.project)
