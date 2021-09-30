#!/usr/bin/env python

# This is a very basic example of how to create a testsuite project
# using the automation suite.

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

import sys, os, argparse

import bootstrap
from automate import ScaleSession, FetchError

from bootstrap import VERBOSE

analysis_dir = os.path.join(bootstrap.base_dir,
        "demo/micro_juliet_v1.2_cppcheck_b")

def test_file(basename):
    return os.path.join(analysis_dir, basename)

def main():
    svc = bootstrap.scale_service()
    if not svc:
        print("SCALe does not appear to be running: %s" % svc)
        sys.exit(1)
    sess = ScaleSession()
    sess.event_scale_session_establish()

    tools = {
        # by tool_group key
        "cppcheck_oss-c-cpp":
            (test_file("micro_juliet_cppcheck_tool_output.xml") , "1.86"),
    }
    lang_ids = []
    try:
        sess.event_project_create(
            name="microjuliet/cppcheck project",
            description="test project automation",
            src_file = test_file("micro_juliet_cpp.zip"),
            is_test_suite = True,
            test_suite_name = "MicroJuliet",
            test_suite_version = "1.2",
            test_suite_type = "juliet",
            test_suite_sard_id = "86",
            author_source = "someAuthor",
            license_string = "someLicense",
            manifest_file = test_file("micro_juliet_cpp_manifest.xml"),
            file_info_file = test_file("micro_juliet_cpp_files.csv"),
            func_info_file = test_file("micro_juliet_cpp_functions.csv"),
            tools = tools,
            languages = lang_ids,
        )
        sess.query_project_export_db()
        sess.query_scaife_logout()
    except FetchError, e:
        print("error: %d %s" % (e.message[0:2]))

# this has to happen below the definition of main(). Register this
# recipe/scenario with the automation suite
import automation
automation.register_scenario_function(main, "basic", script=__file__)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""
        Create a basic project, microjuliet/cppcheck
        """)
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    args = parser.parse_args()
    main()
