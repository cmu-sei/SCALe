#!/usr/bin/env python

# Scrubs the output of msvc and prints out the alerts.
#
# The first argument indicates the file containing the input.
# The second argument specifies the output file.
#
# Example input line (from MSVC tool output on Jasper):
#
# juliet_test_suite_v1.2_for_c_cpp/testcases/cwe114_process_control/cwe114_process_control__w32_char_connect_socket_03.c(50) : warning C6326: Potential comparison of a constant with another constant.
#
# This script extracts the alert's primary message and any associated secondary messages.
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
import os

from toolparser import tool_parser_args

def getSecondaryMessageFields(parse):
    """Concatenate secondary message fields into a tab-separated string that can be joined with the current_table_entry. The resulting string will have the following format:
    "file_path|line_number|secondary_message"
    """
    file_path = parse.group(1).strip()
    line_number = parse.group(2).strip()
    secondary_message = parse.group(3).strip()
    secondary_message = secondary_message.replace("\t", " ")
    fields = "\t".join([file_path, line_number, secondary_message])
    return fields


def getAlertFields(parse):
    """Concatenate alert fields into a tab-separated string. The resulting string will have the following format:
    "checker|file_path|line_number|primary_message"
    """
    file_path = parse.group(1).strip()
    line_number = parse.group(2).strip()
    checker = parse.group(3).strip()
    primary_message = parse.group(4).strip()
    primary_message = primary_message.replace("\t", " ")
    fields = "\t".join([checker, file_path, line_number, primary_message])
    return fields


def process_file(input_file, output_file):
    """The final table entry will have fields in the following order:
    checker, path, line_number, primary_message, [path, line_number, secondary_message]*
    """
    alert_regex = re.compile("(.*?)\((\d*(?:,\d*)*)\).*?(?:error|warning) (.*?): (.*)")
    secondary_message_regex = re.compile("\s{8}(.*?)\((\d*(?:,\d*)*)\)\s*:\s*(.*)")

    current_table_entry = ""

    for line in input_file:
        # attempt to match line to alert regular expression
        alert_parse = re.match(alert_regex, line)

        if(alert_parse != None):
            # the line contains an alert
            if(current_table_entry != ""):
                output_file.write(current_table_entry + "\n")
                #print(current_table_entry)

            alert_fields = getAlertFields(alert_parse)
            current_table_entry = alert_fields
        else:
            # the line doesn't contain an alert. check if it's a secondary message
            secondary_message_parse = re.match(secondary_message_regex, line)

            if(secondary_message_parse != None):
                # the line contains a secondary message
                secondary_message_fields = getSecondaryMessageFields(secondary_message_parse)
                current_table_entry += "\t" + secondary_message_fields

    # reached end of input file. output any remaining alerts
    if(current_table_entry != ""):
        #print(current_table_entry)
        output_file.write(current_table_entry + "\n")


if __name__ == "__main__":
    args = tool_parser_args()

    input_fh = open(args.input_file, "r")
    output_fh = open(args.output_file, "w")

    process_file(input_fh, output_fh)
