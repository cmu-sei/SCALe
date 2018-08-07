# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

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
    diags = []
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
        diag = Diagnostic(tool=Tool.GCC)
        if "will be initialized after" in warning.message:
            warning.message += "..."
            for sub_msg in warnings_raw[i + 1:i + 3]:
                message = Diagnostic(tool=Tool.GCC)
                message.add_feature(FilePathFeature(sub_msg.path))
                message.add_feature(LineStartFeature(int(sub_msg.line)))
                message.add_feature(MessageFeature(sub_msg.message))
                diag.add_sub_measurement(message)
            i = i + 2

        diag.add_feature(FilePathFeature(warning.path))
        diag.add_feature(LineStartFeature(int(warning.line)))
        diag.add_feature(MessageFeature(warning.message))
        diags.append(diag)
        i = i + 1
    return diags
