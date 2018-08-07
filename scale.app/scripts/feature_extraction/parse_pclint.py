# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

from features import *
import re


def pclint_custom_parser(input_file):
    diags = []
    diag_prefix = "DIAGNOSTIC:"
    continuations = set(
        ["Reference cited in prior message", "Location cited in prior message"])
    cur_diag = None
    embedded_path = re.compile("\(line ([0-9]+), file (.*)\)")

    for line in input_file:
        if line.startswith(diag_prefix):
            line = line.strip().strip(diag_prefix)
            path, func, line, msg_id, msg = line.split("~~", 4)

            diag = Diagnostic(tool=Tool.PCLint)
            diag.add_feature(CheckerFeature(msg_id))
            diag.add_feature(FunctionOrMethodFeature(func))
            diag.add_feature(MessageFeature(msg))

            result = embedded_path.search(msg)
            if result:
                path = result.group(2)
                line = result.group(1)
            diag.add_feature(FilePathFeature(path))
            diag.add_feature(LineStartFeature(line))

            if msg in continuations:
                cur_diag.add_feature(FilePathFeature(path))
                cur_diag.add_feature(LineStartFeature(line))
            else:
                cur_diag = diag
                diags.append(diag)
    return diags
