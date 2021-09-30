#!/usr/bin/env python

# The following automation module will create a basic package/project
# on SCAIFE for demonstrating CI integration with a git repository.
# technique only replicates the relevant HTTP queries rather than
# interacting with the SCALe user interface.
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

import sys, os, random, argparse

import bootstrap, automate
from automate import ScaleSession, FetchError

from bootstrap import VERBOSE

dos2unix_dir = os.path.join(bootstrap.junit_test_data_dir, "dos2unix")
analysis_dir = os.path.join(dos2unix_dir, "analysis")

def tool_file(basename):
    return os.path.join(analysis_dir, basename)

# These are default values for creating a basic project with
# dos2unix/rosecheckers. note: these hard-coded IDs are invariant across
# SCALe initializations; these are the internal DB IDs in both the
# internal and external DBs..

default_lang_ids = [1, 6]
default_taxo_ids = [1, 6]
default_tool_ids = [2]

def main(name=None, description=None, git_url=None, git_user=None,
        git_access_token=None, lang_ids=None, taxo_ids=None, tool_ids=None):
    if not name:
        seed = random.randint(0, 10000)
        name = "dos2unix/rosecheckers:SCAIFE/CI:test:%05d" % seed
    if not description:
        description = "test project SCAIFE/CI automation"
    if not git_url:
        git_url = "https://github.com/tizenorg/platform.upstream.dos2unix.git"
    # make sure SCAIFE services are up, including SCALe, start a session
    try:
        bootstrap.assert_services_are_up()
    except AssertionError as e:
        print(str(e), file=sys.stderr)
        sys.exit(1)
    sess = ScaleSession()
    sess.event_scale_session_establish()
    sess.event_scaife_session_establish()

    # upload languages (C89, C++98)
    if not lang_ids:
        lang_ids = default_lang_ids
    sess.query_scaife_langs_upload_submit(lang_ids, primed=True)
    # upload taxonomies (CERT C Rules, CWEs)
    if not taxo_ids:
        taxo_ids = default_taxo_ids
    sess.query_scaife_taxos_upload_submit(taxo_ids, primed=True)
    # upload tools (rosecheckers_oss)
    if not tool_ids:
        tool_ids = default_tool_ids
    sess.query_scaife_tools_upload_submit(tool_ids, primed=True)

    sess.event_scaife_ci_project_create(
        name=name, description=description,
        git_url=git_url, git_user=git_user, git_access_token=git_access_token,
        lang_ids=lang_ids, taxo_ids=taxo_ids, tool_ids=tool_ids
    )

    # all done, return newly created project ID
    if VERBOSE:
        print("automation complete: %s %s" % (name, sess.project_id))
    return sess.project_id

# this has to happen below the definition of main(). Register this
# recipe/scenario with the automation suite
import automation
automation.register_scenario_function(main, "scaife/ci", script=__file__)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""
        Create project scaife/ci: Default: dos2unix/cppcheck_oss
        """)
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    parser.add_argument("-u", "--url", help="git URL of source code")
    parser.add_argument("--langs", help="""
    comma-separated list of language IDs from the SCALe DB. Default: %s
    """.strip() % ','.join(str(x) for x in default_lang_ids))
    parser.add_argument("--taxos", help="""
    comma-separated list of taxonomy IDs from the SCALe DB. Default: %s
    """.strip() % ','.join(str(x) for x in default_taxo_ids))
    parser.add_argument("--tools", help="""
    comma-separated list of tool IDs from the SCALe DB. Default: %s
    """.strip() % ','.join(str(x) for x in default_tool_ids))
    args = parser.parse_args()
    langs = taxos = tools = None
    if args.langs:
        langs = tuple(set(int(x) for x in args.langs.split(',')))
    if args.taxos:
        taxos = tuple(set(int(x) for x in args.taxos.split(',')))
    if args.tools:
        tools = tuple(set(int(x) for x in args.tools.split(',')))
    main(git_url=args.url, lang_ids=langs, taxo_ids=taxos, tool_ids=tools)
