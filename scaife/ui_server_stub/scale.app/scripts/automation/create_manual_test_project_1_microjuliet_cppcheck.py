#!/usr/bin/env python

# The following automation module will create the second project
# described in the "Manual test #1" section of the "Manual Tests for
# SCALe-SCAIFE Interaction" found here for SEI internal folks:
#
# https://wiki-int.sei.cmu.edu/confluence/pages/viewpage.action?pageId=321880939#ManualtestsforSCALe-SCAIFEAPIinteraction-Manualtest#3(Developers-only)
#
# This part of Manual test #1 is described with a bit less detail below
# for external (not SEI) folks:
#
# The script checks if services are up, then creates a SCALe project by
# selecting the microjuliet codebase, specifying C89 and C++98
# languages, and the tool output cppcheck.
#
# It also fills some test suite fields (e.g., Test suite name:
# Microjuliet, specifies the manifest file, and specifies file and
# function information files and the location of the source code,
# and more.
#
# It then uploads the SCALe test suite project to SCAIFE (which requires
# uploading the languages, taxonomies, and tool first).
#
# Next, it creates a classifier with Random Forest and no AH and no
# AHPO, then runs the classifier. Finally, it verifies that the
# 'confidence' column of the table containing meta-alerts is populated
# and contains at least 2 different values.
#
# Note that unlike manual interaction or with Selenium automation, this
# technique only replicates the relevant HTTP queries rather than
# interacting with the SCALe user interface.
#
# This is a dedicated implementation that has not been generalized with
# parameters or command line options -- the project created is exactly
# as described in the testing document.

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

import sys, os, argparse

import bootstrap, automate
from automate import ScaleSession, FetchError

from bootstrap import VERBOSE

analysis_dir = os.path.join(bootstrap.base_dir,
        "demo/micro_juliet_v1.2_cppcheck_b")

def test_file(basename):
    return os.path.join(analysis_dir, basename)

def main():
    # make sure SCAIFE services are up, including SCALe, start a session
    try:
        bootstrap.assert_services_are_up()
    except AssertionError as e:
        print >> sys.stderr, str(e)
        sys.exit(1)
    sess = ScaleSession()
    sess.event_scaife_session_establish()
    # create a test suite project with microjuliet/cppcheck with C 89
    # and C++ 98
    project_name="microjuliet/cppcheck"
    tools = {
        # by tool_group key
        "cppcheck_oss-c-cpp":
            (test_file("micro_juliet_cppcheck_tool_output.xml") , "1.86"),
    }
    langs = [
        ("C" , 'c', "89"),
        ("C++", 'cpp', "98"),
    ]
    lang_ids = []
    for name, plat, ver in langs:
        lang = bootstrap.lang_by_name(bootstrap.internal_db,
                name, plat, version=ver)
        lang_ids.append(lang.id_)
    sess.event_project_create(
        name="%s project" % project_name,
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

    # could select taxonomies, but not necessary due to auto-select
    # during import
    #
    # sess.query_taxos_select_submit([1, 2], primed=True)

    # upload languages (C 89, C++ 98)
    lang_ids = sess.project_lang_upload_ids()
    sess.query_scaife_langs_upload_submit(lang_ids, primed=True)
    # upload taxonomies (CERT C Rules, CERT C++ Rules, CWEs)
    taxo_ids = sess.project_taxo_ids()
    sess.query_scaife_taxos_upload_submit(taxo_ids, primed=True)
    # upload tools (cppcheck)
    tool_ids = sess.project_tool_ids()
    sess.query_scaife_tools_upload_submit(tool_ids, primed=True)
    # upload project
    sess.query_scaife_project_upload(primed=True)
    # create classifier (Random Forest, no AHPO or Adaptive Heuristic)
    classifier_name = \
        sess.event_scaife_classifier_create(classifier_type="Random Forest")
    # run classifier
    sess.query_scaife_classifier_run(classifier_name, primed=True)
    # all done, return newly created project ID
    if VERBOSE:
        print("automation complete: %s %s" % (project_name, sess.project_id))
    return sess.project_id

# this has to happen below the definition of main(). Register this
# recipe/scenario with the automation suite
import automation
automation.register_scenario_function(main, "1b", script=__file__)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""
        Create project 1b: microjuliet/cppcheck. Set some
        determinations, create a classifier, and run it, as described
        for the first project in the Manual Test #1 section of the
        SCALe-SCAIFE interaction page.
        """)
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    args = parser.parse_args()
    main()
