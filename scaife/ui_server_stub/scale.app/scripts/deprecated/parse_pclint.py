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
import re


def pclint_custom_parser(input_file):
    alerts = []
    alert_prefix = "DIAGNOSTIC:"
    continuations = set(
        ["Reference cited in prior message", "Location cited in prior message"])
    cur_alert = None
    embedded_path = re.compile("\(line ([0-9]+), file (.*)\)")

    for line in input_file:
        if line.startswith(alert_prefix):
            line = line.strip().strip(alert_prefix)
            path, func, line, msg_id, msg = line.split("~~", 4)

            alert = Alert(tool=Tool.PCLint)
            alert.add_feature(CheckerFeature(msg_id))
            alert.add_feature(FunctionOrMethodFeature(func))
            alert.add_feature(MessageFeature(msg))

            result = embedded_path.search(msg)
            if result:
                path = result.group(2)
                line = result.group(1)
            alert.add_feature(FilePathFeature(path))
            alert.add_feature(LineStartFeature(line))

            if msg in continuations:
                cur_alert.add_feature(FilePathFeature(path))
                cur_alert.add_feature(LineStartFeature(line))
            else:
                cur_alert = alert
                alerts.append(alert)
    return alerts
