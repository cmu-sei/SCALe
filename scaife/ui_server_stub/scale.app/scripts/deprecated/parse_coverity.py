# <legal>
# SCALe version r.6.2.2.2.A
# 
# Copyright 2020 Carnegie Mellon University.
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

from features import *
import os


def coverity_json_v2_parser(input_file):
    data = json.load(input_file)
    alerts = []
    for issue in data["issues"]:
        checker = issue["checkerName"]
        function = issue["functionDisplayName"]

        alert = Alert(tool=Tool.Coverity)
        alert.add_feature(CheckerFeature(checker))
        alert.add_feature(FunctionOrMethodFeature(function))

        for event in issue["events"]:
            if event["eventTag"] == "caretline":
                continue
            if event["main"]:
                alert.add_feature(FilePathFeature(event["filePathname"]))
                alert.add_feature(LineStartFeature(int(event["lineNumber"])))
                alert.add_feature(MessageFeature(event["eventDescription"]))
            else:
                message = Alert(tool=Tool.Coverity)
                message.add_feature(FilePathFeature(event["filePathname"]))
                message.add_feature(LineStartFeature(int(event["lineNumber"])))
                message.add_feature(MessageFeature(event["eventDescription"]))
                alert.add_sub_measurement(message)
        alerts.append(alert)
    return alerts
