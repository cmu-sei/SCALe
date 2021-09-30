#!/usr/bin/env python

# Script takes a Clang 'plist' output file and extracts its alert
# information
#
# The PList file name should be this script's first argument. It should
# be produced from Clang's 'scan-build -plist' analysis tool.
#
# This script's second argument specifies the output file.
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

import sys
from zipfile import ZipFile
from plistlib import readPlistFromString

from toolparser import tool_parser_args

def process_plist(input_file, output):
    plist = readPlistFromString(input_file.read())
    files = plist.files
    for d in plist.diagnostics:
        # Primary alert
        output.write("\t".join([d.check_name,
                                files[d.location.file],
                                str(d.location.line),
                                d.path[-1].message]))

        # Secondary alerts
        paths = d.path
        del paths[-1]
        for p in paths:
            if hasattr(p, "message"):
                output.write("\t"+"\t".join([files[p.location.file],
                                             str(p.location.line),
                                             p.message])),

        output.write("\n")


if __name__ == "__main__":
    args = tool_parser_args()

    with open(args.output_file, "w") as output_file:
        with ZipFile(args.input_file, "r") as archive:
            for filename in archive.namelist():
                if filename.endswith(".plist"):
                    with archive.open(filename) as input_file:
                        process_plist(input_file, output_file)
