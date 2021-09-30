#!/usr/bin/env python

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

import sys
import argparse
import re

parser = argparse.ArgumentParser(description="Converts program code into 'significant' code, sans comments & whitespace", epilog='''
Takes program code via standard input, outputs 'significant' code via standard output
''')
parser.add_argument('-l', '--language', nargs="?", choices=[
                    "c", "sh"], default=["c"], help="Language for source code")
args = parser.parse_args()

in_comment = False
for line in sys.stdin:
    if args.language == ['c']:  # also c++, java, ObjC ...
        if in_comment:
            line, times = re.subn(r"^.*?\*/", r"", line)
            if times > 0:
                in_comment = False
            else:
                continue

        line, times = re.subn(r"//.*$", r"", line)
        times = 1
        while times > 0:
            line, times = re.subn(r"/\*.*?\*/", r" ", line)

        line, times = re.subn(r"/\*.*$", r"", line)
        if times > 0:
            in_comment = True

    else:  # sh, perl, python, ruby, tcl...
        line, times = re.subn(r"#.*$", r"", line)

    line = line.strip()
    if line != "":
        print(line)
