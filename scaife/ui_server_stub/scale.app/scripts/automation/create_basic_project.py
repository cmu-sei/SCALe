#!/usr/bin/env python

# This is a very basic example of how to create a simple project using
# the automation suite.

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

dos2unix_dir = os.path.join(bootstrap.junit_test_data_dir, "dos2unix")
analysis_dir = os.path.join(dos2unix_dir, "analysis")

def tool_file(basename):
    return os.path.join(analysis_dir, basename)

def main():
    src_file = os.path.join(dos2unix_dir, "dos2unix-7.2.2.tar.gz")
    tools = {
        "rosecheckers_oss-c-cpp": (tool_file("rosecheckers_oss.txt"), ""),
    }
    svc = bootstrap.Service(name="scale")
    if not svc:
        print("SCALe does not appear to be running: %s" % svc)
        sys.exit(1)
    sess = ScaleSession()
    try:
        sess.event_project_create(
            name="dos2unix/rosecheckers project",
            description="test project automation",
            src_file=src_file,
            tools=tools,
            languages=[1, 2, 3]
        )
    except FetchError, e:
        print("error: %d %s" % (e.message[0:2]))

# this has to happen below the definition of main(). Register this
# recipe/scenario with the automation suite
import automation
automation.register_scenario_function(main, "basic", script=__file__)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""
        Create a basic project, dos2unix/rosecheckers with C89, C90, and
        C95 code languages selected.
        """)
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    args = parser.parse_args()
    main()
