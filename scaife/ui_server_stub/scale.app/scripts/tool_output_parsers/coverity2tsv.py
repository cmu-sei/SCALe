#!/usr/bin/env python

# Python script that scrubs coverity alerts.
#
# The first argument indicates the file containing the input.
# The second argument specifies the output file.
#
# This script can produce lots of messages per alert
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
import sys

from toolparser import tool_parser_args

def process_file(input_fh, output_fh):

    # Fields we care about in the event json object
    #relevant_fields = ["filePathname", "lineNumber", "eventDescription"]

    json_data = json.load(input_fh)

    for issue in json_data["issues"]:
        events = []
        for event in issue["events"]:
            file_path = event["filePathname"]
            line_number = str(event["lineNumber"])
            message = event["eventDescription"]
            message = message.strip().replace("\t", " ")
            event_values = [file_path, line_number, message]

            if event["eventTag"] == "caretline":
                # Event is just a ^, not very useful
                continue
            if event["main"]:
                # The main event goes first
                events = event_values + events
            else:
                # Otherwise, arrange sequentially
                events = events + event_values

        checker = issue["checkerName"]

        column_values = checker + "\t" + "\t".join(events)
        output_fh.write(column_values + "\n")


if __name__ == "__main__":
    args = tool_parser_args()

    input_fh = open(args.input_file, "r")
    output_fh = open(args.output_file, "w")

    process_file(input_fh, output_fh)
