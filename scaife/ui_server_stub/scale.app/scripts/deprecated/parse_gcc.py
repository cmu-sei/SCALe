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

import re
import sys
from features import *

warning_re = re.compile("^(.*):(\\d+):\\d+: warning: (.*)\\[(.*)\\]$")


class GCCWarning(object):

    def __init__(self):
        self.path = None
        self.line = None
        self.message = None
        self.category = None


def gcc_warning_parser(input_file):
    warnings_raw = []
    alerts = []
    for line in input_file:
        match = warning_re.match(line.strip())
        if match:
            warning = GCCWarning()
            warning.path = match.group(1)
            warning.line = match.group(2)
            warning.message = match.group(3).strip()
            warning.category = match.group(4)
            warnings_raw.append(warning)

    warnings_processed = []
    i = 0
    while i < len(warnings_raw):
        warning = warnings_raw[i]
        alert = Alert(tool=Tool.GCC)
        if "will be initialized after" in warning.message:
            warning.message += "..."
            for sub_msg in warnings_raw[i + 1:i + 3]:
                message = Alert(tool=Tool.GCC)
                message.add_feature(FilePathFeature(sub_msg.path))
                message.add_feature(LineStartFeature(int(sub_msg.line)))
                message.add_feature(MessageFeature(sub_msg.message))
                alert.add_sub_measurement(message)
            i = i + 2

        alert.add_feature(FilePathFeature(warning.path))
        alert.add_feature(LineStartFeature(int(warning.line)))
        alert.add_feature(MessageFeature(warning.message))
        alerts.append(alert)
        i = i + 1
    return alerts
