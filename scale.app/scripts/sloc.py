#!/usr/bin/env python

# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


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
        print line
