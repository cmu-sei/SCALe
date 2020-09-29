#!/usr/bin/env python

# Script constructs HTML.zip file suitable for uploading to web app.
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
    description='''Constructs HTML file from a source code archive.
    All intermediate files go in 'temp_scale' subdir in pwd.
''')
parser.add_argument("src", help="Source code archive (tar.gz, tgz, zip, tar.bz2)")
parser.add_argument('-v', '--verbose', action="store_true", default=False,
                    help="Verbose output")
args = parser.parse_args()

if args.verbose:
    print("Args are: ", args)
    os.environ["VERBOSE"] = "TRUE"
else:
    os.environ["VERBOSE"] = "FALSE"

if not args.src.startswith("/"):
    args.src = os.getcwd() + "/" + args.src

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
    print("Constructing HTML")
if args.verbose:
    subprocess.call(["htags", "--suggest"])
else:  # --suggest w/o -v
    subprocess.call(["htags", "-aghInosT", "--show-position", "--fixed-guide"])


if args.verbose:
    print("Creating HTML.zip")
if args.verbose:
    subprocess.call(["zip", "../html.zip", "-rv", "HTML"])
else:
    subprocess.call(["zip", "../html.zip", "-rq", "HTML"])

os.chdir("..")
shutil.rmtree("temp_scale")
if args.verbose:
    print("Done")
