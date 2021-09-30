#!/usr/bin/env python

# Script creates (or extends) an external SCALe database suitable for uploading to web app.
# Requires SCALE_HOME to be set correctly, but can be called from any dir.
#
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

import argparse
import os
import subprocess
import shutil
from subprocess import CalledProcessError

import bootstrap
from bootstrap import VERBOSE

KEEP_OUTPUT=False

parser = argparse.ArgumentParser(
    description="""
    Constructs an external SCALe database from a source code archive and
    tool output All intermediate files go in 'temp_scale' subdir in pwd.

    This script requires SCALE_HOME to be set correctly, but can be
    called from any directory
    """)
parser.add_argument("db", help="""
        SCALe external database to use. If file does not exist,
        it will be created
        """)
parser.add_argument("sa", help="SA tool output")
parser.add_argument("src", help="Source code archive")
parser.add_argument("-i", "--tool-id", type=int, required=False, default=None,
                    help="Tool ID (if known)")
parser.add_argument("-t", "--tool-name", required=False, default=None,
                    help="Tool name")
parser.add_argument("-p", "--tool-platform", required=False, default=None,
                    help="Tool platform (target language)")
parser.add_argument("-V", "--tool-version", required=False, default=None,
                    help="Tool version (if applicable)")
parser.add_argument("-k", "--swamp-tool-id", required=False, default=None,
                    help="Tool ID (if available) of SWAMP tool")
parser.add_argument("--tmp-dir", required=False, help="Temp dir, persists")
parser.add_argument('-v', '--verbose', action=bootstrap.Verbosity)
args = parser.parse_args()

tmp_dir = args.tmp_dir or \
        bootstrap.get_tmp_dir(ephemeral = not KEEP_OUTPUT,
                suffix="create_db", purge=True)
src_dir = os.path.join(tmp_dir, "create_db_src")
if not os.path.exists(src_dir):
    os.makedirs(src_dir)

if not args.db.startswith("/"):
    args.db = os.path.join(tmp_dir, args.db)
    if not os.path.exists(os.path.dirname(args.db)):
        os.makedirs(os.path.dirname(args.db))
    if os.path.exists(args.db):
        os.unlink(args.db)
if not args.sa.startswith("/"):
    args.sa = os.path.join(bootstrap.scale_dir, args.sa)
if not args.src.startswith("/"):
    args.src = os.path.join(bootstrap.scale_dir, args.src)

if VERBOSE:
    print("Extracting source")

bootstrap.unpack(args.src, tgt_dir=src_dir, verbose=VERBOSE)

if VERBOSE:
    print("Constructing database")

# Inherits VERBOSE env var
script = os.path.join(bootstrap.scripts_dir, "digest_alerts.py")
cmd = [script, "-s", tmp_dir, args.db, args.sa]
if VERBOSE:
    cmd.append("-v")
if args.tool_id is not None:
    cmd.extend(["--tool-id", str(args.tool_id)])
if args.tool_name is not None:
    cmd.extend(["--tool-name", args.tool_name])
if args.tool_platform is not None:
    cmd.extend(["--tool-platform", args.tool_platform])
if args.tool_version is not None:
    cmd.extend(["--tool-version", args.tool_version])
if args.swamp_tool_id is not None:
    cmd.extend(["--swamp-tool-id", str(args.swamp_tool_id)])
try:
    subprocess.check_output(cmd, stderr=subprocess.STDOUT)
except CalledProcessError, e:
    msg = str(e)
    if e.output:
        msg += "\nOUTPUT:\n%s" % e.output
    raise Exception(msg)

if VERBOSE:
    print("Done")
