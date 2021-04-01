#!/usr/bin/env python

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
import os

from toolparser import tool_parser_args

def process_file(input_file, output_file):

    parseRE = re.compile(r"\|(.*?)\|(.*?)\|(.*?)\|(.*?)\|(.*?)\|")

    #No try-except since we just want to die on error anyway
    for line in input_file:
        parse = parseRE.match(line)
        if parse is not None:
            checker = (parse.group(1)).strip()
            file_path = os.path.join((parse.group(2)).strip(), (parse.group(3)).strip())
            line_number = (parse.group(4)).strip()
            message = parse.group(5)
            message = message.strip().replace("\t", " ")
            column_values = "\t".join([checker, file_path, line_number, message])
            output_file.write(column_values + "\n")


if __name__ == "__main__":
    args = tool_parser_args()

    input_fh = open(args.input_file, "r")
    output_fh = open(args.output_file, "w")

    process_file(input_fh, output_fh)
