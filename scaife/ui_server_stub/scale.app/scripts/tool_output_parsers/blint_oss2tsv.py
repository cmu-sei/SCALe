#!/usr/bin/env python

# Script takes a B::lint text output file and extracts its alert
# information.
#
# The first argument indicates the file containing the input.
# The data should be produced from a build process using B::Lint.
#
# The second argument specifies the output file.
#
# This script never produces more than one message per alert
#
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

import sys
import re

from toolparser import tool_parser_args

def process_file(input_fh, output_file):

    for line in input_fh:
        line = line.strip()

        parse = re.match(r"^(.*) at (.*) line (\d*)(|\.|, (near|at) (.*))?$", line)
        if (None == parse):
            continue

        message = parse.group(1)
        message = re.sub(r" *\(@INC contains: .*?\)", "", message)
        message = message.strip().replace("\t", " ")
        file_path = parse.group(2)
        line_number = parse.group(3)

        column_values = "\t".join(["", file_path, line_number, message])
        output_file.write(column_values + "\n")


if __name__ == "__main__":
    args = tool_parser_args()

    input_fh = open(args.input_file, "r")
    output_fh = open(args.output_file, "w")

    process_file(input_fh, output_fh)
