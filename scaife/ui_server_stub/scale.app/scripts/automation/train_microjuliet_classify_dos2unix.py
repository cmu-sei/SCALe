#!/usr/bin/env python

# The following automation module will create dos2unix & microjuliet
# It then creates a classifier using both projects, and tries to use it to classify dos2unix
# This is to address RC-1852
#
# This is a dedicated implementation that has not been generalized with
# parameters or command line options -- the project created is exactly
# as hard-coded below.

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

import bootstrap, automate
from automate import ScaleSession, FetchError

from bootstrap import VERBOSE


def tool_file(basename):
    return

def main(skip_classifier=False):
    if VERBOSE:
        print("automation: %s" % __file__)
    # make sure SCAIFE services are up, including SCALe, start a session
    try:
        bootstrap.assert_services_are_up()
    except AssertionError as e:
        print(str(e), file=sys.stderr)
        sys.exit(1)
    sess = ScaleSession()
    sess.event_scale_session_establish()
    sess.event_scaife_session_establish()

    try:
        dos2unix_dir = os.path.join(bootstrap.junit_test_data_dir, "dos2unix")
        d2u_analysis_dir = os.path.join(dos2unix_dir, "analysis")
        sess.event_project_create(
            name="dos2unix/rosecheckers",
            description="test project automation",
            src_file=os.path.join(dos2unix_dir, "dos2unix-7.2.2.tar.gz"),
            tools={
                "rosecheckers_oss-c-cpp": (os.path.join(d2u_analysis_dir,"rosecheckers_oss.txt"), ""),
            },
            languages=[1]
        )
        d2u_project = sess.project_id
        print("dos2unix project created", d2u_project)

        mj_analysis_dir = os.path.join(bootstrap.base_dir,
                                       "demo/micro_juliet_v1.2_cppcheck_b")
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
            name="microjuliet/cppcheck",
            description="test project automation",
            src_file = os.path.join(mj_analysis_dir, "micro_juliet_cpp.zip"),
            is_test_suite = True,
            test_suite_name = "MicroJuliet",
            test_suite_version = "1.2",
            test_suite_type = "juliet",
            test_suite_sard_id = "86",
            author_source = "someAuthor",
            license_string = "someLicense",
            manifest_file = os.path.join(mj_analysis_dir, "micro_juliet_cpp_manifest.xml"),
            file_info_file = os.path.join(mj_analysis_dir, "micro_juliet_cpp_files.csv"),
            func_info_file = os.path.join(mj_analysis_dir, "micro_juliet_cpp_functions.csv"),
            tools = {
                # by tool_group key
                "cppcheck_oss-c-cpp":
                (os.path.join(mj_analysis_dir,"micro_juliet_cppcheck_tool_output.xml"),
                "1.86")
            },
            languages = lang_ids,
        )
        mj_project = sess.project_id
        print("microjuliet project created", mj_project)

        # could select taxonomies here, but it's not necessary due to
        # auto-select during import
        #
        # sess.query_taxos_select_submit([1], primed=True)

    except FetchError, e:
        print("error: %d %s" % (e.message[0:2]))

    # Upload necessary languages, taxonomies, and tools
    lang_ids = set()
    taxo_ids = set()
    tool_ids = set()
    for pid in [d2u_project, mj_project]:
        sess.set_project_id(pid)
        lang_ids.update(sess.project_lang_upload_ids())
        taxo_ids.update(sess.project_taxo_ids())
        tool_ids.update(sess.project_tool_ids())
    print("langs ", str(lang_ids))
    print("taxo ", str(taxo_ids))
    print("tool ", str(tool_ids))
    sess.query_scaife_langs_upload_submit(list(lang_ids), primed=True)
    sess.query_scaife_taxos_upload_submit(list(taxo_ids), primed=True)
    sess.query_scaife_tools_upload_submit(list(tool_ids), primed=True)

    for pid in [d2u_project, mj_project]:
        sess.set_project_id(pid)
        sess.query_scaife_project_upload(primed=True)
        print("project uploaded")

    if not skip_classifier:
        sess.set_project_id(d2u_project)
        source_domain = ",".join([sess.project_name(d2u_project),
                                  sess.project_name(mj_project)])
        print("source domain " + source_domain)
        # create classifier (Random Forest, no AHPO or Adaptive Heuristic)
        classifier_name = \
            sess.event_scaife_classifier_create(classifier_type="Random Forest", source_domain=source_domain)
        # run classifier
        sess.set_project_id(d2u_project)
        print('Classifier Name: ' + classifier_name)
        sess.query_scaife_classifier_run(classifier_name, primed=True)

    # all done, return newly created project ID
    if VERBOSE:
        print("automation complete: classifier trained/run for dos2unix and microjuliet")
    return sess.project_id

# this has to happen below the definition of main(). Register this
# recipe/scenario with the automation suite
import automation
automation.register_scenario_function(main, "1a", script=__file__)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""
        Create project 1a: dos2unix/rosecheckers. Set some
        determinations, create a classifier, and run it, as described
        for the first project in the Manual Test #1 section of the
        SCALe-SCAIFE interaction page.
        """)
    parser.add_argument("--no-classifier", action="store_true",
            help="Skip creating/running classifier")
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    args = parser.parse_args()
    main(skip_classifier=args.no_classifier)
