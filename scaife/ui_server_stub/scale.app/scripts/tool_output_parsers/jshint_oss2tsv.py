#!/usr/bin/env python

# Python script that converts https://github.com/damian/jshint tool output to ORG format.
# JSHint is an open-source static analysis tool for JavaScript
#
# The first argument indicates the file containing the input.
# The second argument specifies the output file.
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
import re

from toolparser import tool_parser_args

def canonicalize_path(dirstack, file_name):
    path = "/".join(dirstack) + "/" + file_name
    while (True):
        new_path = re.sub(r"([^/]*)/\.\./", r"", path)
        if (len(new_path) == len(path)):
            break
        path = new_path
    while (True):
        new_path = re.sub(r"$./", r"", path)
        if (len(new_path) == len(path)):
            break
        path = new_path
    while (True):
        new_path = re.sub(r"/./", r"/", path)
        if (len(new_path) == len(path)):
            break
        path = new_path
    return path


# For each unique expression a checker line should be added here.
def load_checkers():
    id_matcher = {
        # unused variable
        "JS-1":"^(.*): line ([0-9]+), col ([0-9]+), (.*is defined but never used.*)",
        # Unexpected Operator
        "JS-2":"^(.*): line ([0-9]+), col ([0-9]+), (.*and instead saw.*)",
        # Extention use
        "JS-3":"^(.*): line ([0-9]+), col ([0-9]+), (.*is available in ES6.*)",
        # Variable overwrite
        "JS-4":"^(.*): line ([0-9]+), col ([0-9]+), (.*already defined.*)",
        # Missing semicolon
        "JS-5":"^(.*): line ([0-9]+), col ([0-9]+), (.*Missing semicolon.*)",
        # Out of scope
        "JS-6":"^(.*): line ([0-9]+), col ([0-9]+), (.*used out of scope.*)",
        # Ambigious use of varaible
        "JS-7":"^(.*): line ([0-9]+), col ([0-9]+), (.*Confusing use.*)",
        # Variable used before defined
        "JS-8":"^(.*): line ([0-9]+), col ([0-9]+), (.*used before it was defined.*)",
        # Variable not defined
        "JS-9":"^(.*): line ([0-9]+), col ([0-9]+), (.*is not defined.*)",
    }
    return id_matcher

# Convert a re matches object into an org format string
def convert_matches(checker_id, file_name, line_number, message):
    dirstack = []
    message = message.strip().replace("\t", " ")
    file_path = canonicalize_path(dirstack, file_name)
    return "\t".join([checker_id, file_path, line_number, message])

def handle_line(line, matcher):
    #line = sanitize(line)
    for checker_id, checker in matcher.items():
        values = re.match(checker, line)
        if values is not None:
            return convert_matches(checker_id, values.group(1), values.group(2), values.group(4))
    return None

def process_file(in_file, out_file):
    matcher = load_checkers()
    for line in in_file:
        result = handle_line(line.strip(), matcher)
        if result is not None:
            out_file.write(result + "\n")
        else:
            sys.stderr.write("Line was not in expected format: " + line + "\n")


if __name__ == "__main__":
    args = tool_parser_args()

    input_fh = open(args.input_file, "r")
    output_fh = open(args.output_file, "w")

    process_file(input_fh, output_fh)
