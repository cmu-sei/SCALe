#!/usr/bin/env python

# Script creates (or extends) an external SCALe database suitable for uploading to web app.
# Requires SCALE_HOME to be set correctly, but can be called from any dir.
#
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

import argparse
import os
import subprocess
import shutil


parser = argparse.ArgumentParser(
    description='''Constructs an external SCALe database from a source code archive
    and tool output All intermediate files go in 'temp_scale' subdir in pwd.

    This script requires SCALE_HOME to be set correctly,
    but can be called from any directory
    ''')
parser.add_argument("db",
                    help="SCALe external database to use. If file does not exist, it will be created")
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
parser.add_argument('-v', '--verbose', action="store_true", default=False,
                    help="Verbose output")
args = parser.parse_args()

pwd = os.getcwd()
if not args.db.startswith("/"):
    args.db = pwd + "/" + args.db
if not args.sa.startswith("/"):
    args.sa = pwd + "/" + args.sa
if not args.src.startswith("/"):
    args.src = pwd + "/" + args.src

if args.verbose:
    print("Args are: ", args)
    os.environ["VERBOSE"] = "TRUE"
else:
    os.environ["VERBOSE"] = "FALSE"

if os.path.exists("temp_scale"):
    raise Exception("Will not work in folder with preexisting temp_scale dir")
os.mkdir("temp_scale")
os.chdir("temp_scale")

if args.verbose:
    print("Extracting source")

Unarchive_Map = {".zip": ["unzip", "--", "-q"],
                 ".tar.gz": ["tar", "xfv", "xf"],
                 ".tgz": ["tar", "xfv", "xf"],
                 ".tar.bz2": ["tar", "xjfv", "xjf"]}
for key in Unarchive_Map.keys():
    if args.src.endswith(key):
        (cmd, verbose, quiet) = Unarchive_Map[key]
system_cmd = [cmd, (verbose if args.verbose else quiet), args.src]
subprocess.call(system_cmd)


if args.verbose:
    print("Constructing database")
os.chdir(os.getenv("SCALE_HOME") + "/scale.app/scripts")
# Inherits VERBOSE env var
system_cmd = ["./digest_alerts.py",  "-s", pwd + "/temp_scale",
              args.db, args.sa]
if args.verbose:
    system_cmd.append("-v")
if args.tool_id is not None:
    system_cmd.extend(["--tool-id", str(args.tool_id)])
if args.tool_name is not None:
    system_cmd.extend(["--tool-name", args.tool_name])
if args.tool_platform is not None:
    system_cmd.extend(["--tool-platform", args.tool_platform])
if args.tool_version is not None:
    system_cmd.extend(["--tool-version", args.tool_version])
if args.swamp_tool_id is not None:
    system_cmd.extend(["--swamp-tool-id", str(args.swamp_tool_id)])
subprocess.call(system_cmd)


os.chdir(pwd)
shutil.rmtree("temp_scale")
if args.verbose:
    print("Done")
