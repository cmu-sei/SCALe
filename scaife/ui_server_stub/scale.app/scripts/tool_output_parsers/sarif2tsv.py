#!/usr/bin/env python

# Script takes a SARIF output file and extracts its alert
# information
#
# This script should be called for parsing SARIF-format output,
# for all SARIF-format output. This script is intended to be called
# for parsing output from many tools.
# 
# The first argument indicates the file containing the input.
# The second argument specifies the output file.
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
import json

from toolparser import tool_parser_args

def processFile(input_data, output_file):
    for alert in input_data["runs"][0]["results"]:
        checker = alert["ruleId"]
        message = alert["message"]["text"]
        loc = alert["locations"][0]
        
        file_path_index = loc["physicalLocation"]["artifactLocation"]["index"]
        file_path = input_data["runs"][0]["artifacts"][file_path_index]["location"]["uri"]
        line_number = str(loc["physicalLocation"]["region"]["startLine"])
        column_values = [checker, file_path, line_number, message]

        # Secondary messages
        for flow in alert["codeFlows"]:
            for tflow in flow["threadFlows"]:
                for loc in tflow["locations"]:
                    msg = loc["location"]["message"]["text"]
                    loc_loc = loc["location"]["physicalLocation"]
                    file_path_index = loc["location"]["physicalLocation"]["artifactLocation"]["index"]
                    file_path = input_data["runs"][0]["artifacts"][file_path_index]["location"]["uri"]
                    line_number = str(loc_loc["region"]["startLine"])
                    column_values = column_values + [file_path, line_number, msg]

        output_file.write("\t".join(column_values) + "\n")


if __name__ == "__main__":
    args = tool_parser_args()

    input_fh = open(args.input_file, "r")
    output_fh = open(args.output_file, "w")

    input_data = json.load(input_fh)

    processFile(input_data, output_fh)
