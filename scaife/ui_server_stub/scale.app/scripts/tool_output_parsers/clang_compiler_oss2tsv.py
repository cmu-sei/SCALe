#!/usr/bin/env python

# Script takes a Clang compiler text output file and extracts its
# alert information
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

def canonicalize_path(dirstack, filename):
    separator = "" if filename.startswith("/") else "/" # Avoid adding extra separator
    path = "/".join(dirstack) + separator + filename
    while (True):
        newpath = re.sub(r"([^/]*)/\.\./", r"", path)
        if (len(newpath) == len(path)):
            break
        path = newpath
    while (True):
        newpath = re.sub(r"$./", r"", path)
        if (len(newpath) == len(path)):
            break
        path = newpath
    while (True):
        newpath = re.sub(r"/./", r"/", path)
        if (len(newpath) == len(path)):
            break
        path = newpath
    return path


def process_file(input_file, output_file):

    inCtrFlag = 0
    message = ""
    links = ""
    dirstack = []

    for line in input_file:
        line = line.strip()

        parse = re.match(r"pushd *(.*)$", line)
        if (None != parse):
            dirstack.append(parse.group(1))
            continue
        if (line == "popd") and len(dirstack) > 0:
            del dirstack[len(dirstack) - 1]

        # Handle multi-line G++ alerts
        if (None != re.match(r"^(.*?): In constructor ", line)):
            inCtrFlag = 1
            message = ""
            links = ""
        if (None != re.match(r"^(.*?): At global scope:$", line)):
            inCtrFlag = 0
        if (None != re.match(r"^[^:]*$", line)):
            inCtrFlag = 0

        parse = re.match(r"^(.*?):([0-9]*): *(\S.*?) *$", line)
        if (inCtrFlag == 1 and parse != None):
            file_name = parse.group(1)
            line_number = parse.group(2)
            line_message = parse.group(3)
            message = message + " " + line_message
            if (None != re.match(r"warning: *when initialized here", line_message)):
                message = re.sub(r" *warning: *", " ", message)
                file_path = canonicalize_path(dirstack, file_name)
                message_with_links = message + "  LINKS:" + links
                message_with_links = message_with_links.strip().replace("\t", " ")

                column_values = "\t".join(["", file_path, line_number, message_with_links])
                output_file.write(column_values + "\n")
                message = ""
                links = ""
            else:
                if (line_number != ""):
                    links = links + " " + file_name + ":" + line_number
            continue

        # 1-line alerts
        parse = re.match(r"^([^ :]*?\.(c|C|cpp|cxx|h|H)):([0-9]*):([0-9]*:)? *(\S.*?) *$", line)
        if (parse != None and parse.group(2) != ""):
            file_path = canonicalize_path( dirstack, parse.group(1))
            line_number = parse.group(3)
            message = parse.group(5)
            message = message.strip().replace("\t", " ")

            column_values = "\t".join(["", file_path, line_number, message])
            output_file.write(column_values + "\n")


if __name__ == "__main__":
    args = tool_parser_args()

    input_fh = open(args.input_file, "r")
    output_fh = open(args.output_file, "w")

    process_file(input_fh, output_fh)
