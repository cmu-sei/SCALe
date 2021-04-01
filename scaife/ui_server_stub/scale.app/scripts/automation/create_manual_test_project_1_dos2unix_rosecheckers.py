#!/usr/bin/env python

# The following automation module will create the second project
# described in the "Manual test #1" section of the "Manual Tests for
# SCALe-SCAIFE Interaction" found here for SEI internal folks:
#
# https://wiki-int.sei.cmu.edu/confluence/pages/viewpage.action?pageId=3218809  39#ManualtestsforSCALe-SCAIFEAPIinteraction-Manualtest#3(Developers-only)
#
# This part of Manual test #1 is described with a bit less detail below
# for external (not SEI) folks:
#
# The script checks if services are up, then creates a SCALe project by
# selecting dos2unix codebase, specifying C89 language, and one tool
# output rosecheckers.
#
# It sets 10 meta-alerts with checker EXP12-C to 'True' and 10
# meta-alerts with checker FIO30-C to 'False', then uploads the SCALe
# project to SCAIFE (which requires uploading the language, taxonomy,
# and tool.
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
# as hard-coded below.

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

dos2unix_dir = os.path.join(bootstrap.junit_test_data_dir, "dos2unix")
analysis_dir = os.path.join(dos2unix_dir, "analysis")

def tool_file(basename):
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
    # create a basic project with dos2unix/rosecheckers and language C89
    project_name = "dos2unix/rosecheckers"
    src_file = os.path.join(dos2unix_dir, "dos2unix-7.2.2.tar.gz")
    tools = {
        "rosecheckers_oss-c-cpp": (tool_file("rosecheckers_oss.txt"), ""),
    }
    sess.event_project_create(
        name="%s project" % project_name,
        description="test project automation",
        src_file=src_file,
        tools=tools,
        languages=[1]
    )
    # first ten fused alert_conditions with checker EXP12-C set to True
    alert_conditions_verdict_true = \
            [100, 81, 46, 229, 211, 188, 201, 64, 237, 50]
    # first ten fused alert_conditions with checker FIO30-C set to False
    alert_conditions_verdict_false = \
            [186, 149, 109, 98, 9, 36, 63, 40, 236, 225]
    sess.query_mass_update(alert_conditions_verdict_true, verdict=4,
            primed=True)
    sess.query_mass_update(alert_conditions_verdict_false, verdict=2,
            primed=True)

    # could select taxonomies here, but it's not necessary due to
    # auto-select during import
    #
    # sess.query_taxos_select_submit([1], primed=True)

    # upload languages (C89)
    lang_ids = sess.project_lang_upload_ids()
    sess.query_scaife_langs_upload_submit(lang_ids, primed=True)
    # upload taxonomies (CERT C Rules)
    taxo_ids = sess.project_taxo_ids()
    sess.query_scaife_taxos_upload_submit(taxo_ids, primed=True)
    # upload tools (rosecheckers)
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
automation.register_scenario_function(main, "1a", script=__file__)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""
        Create project 1a: dos2unix/rosecheckers. Set some
        determinations, create a classifier, and run it, as described
        for the first project in the Manual Test #1 section of the
        SCALe-SCAIFE interaction page.
        """)
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    args = parser.parse_args()
    main()
