#!/usr/bin/env python

# Script constructs HTML.zip file suitable for uploading to web app.
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
import shutil
import subprocess
from subprocess import CalledProcessError

import bootstrap
from bootstrap import VERBOSE

KEEP_OUTPUT = False

parser = argparse.ArgumentParser(
    description='''Constructs HTML file from a source code archive.
    All intermediate files go in 'temp_scale' subdir in pwd.
''')
parser.add_argument("src", help="Source code archive (tar.gz, tgz, zip, tar.bz2)")
parser.add_argument("-o", "--out", default="html.zip", help="output html zip")
parser.add_argument("--tmp-dir", help="optional scratch dir, persists")
parser.add_argument('-v', '--verbose', action=bootstrap.Verbosity)
args = parser.parse_args()

tmp_dir = args.tmp_dir or bootstrap.get_tmp_dir(ephemeral = not KEEP_OUTPUT,
        suffix="gen_src_html", purge=True)
if not args.src.startswith("/"):
    args.src = os.path.join(tmp_dir, args.src)
if not args.out.startswith("/"):
    args.out = os.path.join(tmp_dir, args.out)
src_dir = os.path.join(tmp_dir, "create_html_src")

pwd = os.getcwd()
try:
    if not os.path.exists(src_dir):
        os.makedirs(src_dir)
    os.chdir(src_dir)
    if args.verbose:
        print("Extracting source")
    bootstrap.unpack(args.src, verbose=args.verbose)
    if args.verbose:
        print("Constructing HTML")
        subprocess.call(["htags", "--suggest"])
    else:  # --suggest w/o -v
        cmd = ["htags", "-aghInosT", "--show-position", "--fixed-guide"]
        subprocess.call(cmd)
    if args.verbose:
        print("Creating %s" % args.out)
        subprocess.call(["zip", args.out, "-rv", "HTML"])
    else:
        subprocess.call(["zip", args.out, "-rq", "HTML"])
finally:
    os.chdir(pwd)

if args.verbose:
    print("Done")
