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

from features import *


def msvs_text_parser(input_file):
    alerts = []
    cur_alert = None
    cur_message = ""

    for line in input_file:
        line = line.strip()
        if line == "":
            continue

        tokens = line.split("\t")
        if tokens[0].startswith("CA"):
            if cur_alert is not None:
                alerts.append(cur_alert)

            cur_alert = Alert(tool=Tool.VisualStudioCodeAnalysis)

            if len(tokens) == 3:
                cur_alert.add_feature(CheckerFeature(tokens[0]))
                cur_message = tokens[1] + "\n" + tokens[2]
            else:
                message = tokens[1] + "\n" + tokens[2]
                cur_alert.add_feature(CheckerFeature(tokens[0]))
                cur_alert.add_feature(FilePathFeature(tokens[-2]))
                cur_alert.add_feature(LineStartFeature(int(tokens[-1])))
                cur_alert.add_feature(MessageFeature(message))
        else:
            if len(tokens) == 1:
                cur_message += "\n" + tokens[0]
            else:
                cur_message += "\n" + tokens[0]
                cur_alert.add_feature(FilePathFeature(tokens[-2]))
                cur_alert.add_feature(LineStartFeature(int(tokens[-1])))
                cur_alert.add_feature(MessageFeature(cur_message))
    return alerts

if __name__ == "__main__":
    import sys
    import json

    for item in sys.argv[1:]:
        results = {}
        results["alerts"] = [d.feature_value_dict()
                                  for d in msvs_text_parser(open(item))]
        print(json.dumps(results))
