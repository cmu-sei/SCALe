# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

from features import *
import os


def coverity_json_v2_parser(input_file):
    data = json.load(input_file)
    diags = []
    for issue in data["issues"]:
        checker = issue["checkerName"]
        function = issue["functionDisplayName"]

        diag = Diagnostic(tool=Tool.Coverity)
        diag.add_feature(CheckerFeature(checker))
        diag.add_feature(FunctionOrMethodFeature(function))

        for event in issue["events"]:
            if event["eventTag"] == "caretline":
                continue
            if event["main"]:
                diag.add_feature(FilePathFeature(event["filePathname"]))
                diag.add_feature(LineStartFeature(int(event["lineNumber"])))
                diag.add_feature(MessageFeature(event["eventDescription"]))
            else:
                message = Diagnostic(tool=Tool.Coverity)
                message.add_feature(FilePathFeature(event["filePathname"]))
                message.add_feature(LineStartFeature(int(event["lineNumber"])))
                message.add_feature(MessageFeature(event["eventDescription"]))
                diag.add_sub_measurement(message)
        diags.append(diag)
    return diags
