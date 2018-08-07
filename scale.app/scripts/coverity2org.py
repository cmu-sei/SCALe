#!/usr/bin/env python

# Python script that scrubs coverity diagnostics.
#
# The only argument indicates the file containing the input.
#
# This script can produce lots of messages per diagnostic
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import json


def sanitize(s):
    if s == None:
        return ""
    # Remove new lines and pipes, as they'll mess up the org format
    result = s.replace("\n", " ").replace("|", " ")
    return result

if len(sys.argv) != 2:
    exit("Usage: " + sys.argv[0] + " <json_path>")
json_file = sys.argv[1]

# Fields we care about in the event json object
eventFields = ["filePathname", "lineNumber", "eventDescription"]
with open(json_file) as data_file:
    data = json.load(data_file)
    for issue in data["issues"]:
        checker = sanitize(str(issue["checkerName"]))
        events = []
        for event in issue["events"]:
            fields = [sanitize(str(event[f])) for f in eventFields]
            if event["eventTag"] == "caretline":
                # Event is just a ^, not very useful
                continue
            if event["main"]:
                # The main event goes first
                events = fields + events
            else:
                # Otherwise, arrange sequentially
                events = events + fields
        items = [checker] + events
        print "|" + "|".join(items) + "|"
