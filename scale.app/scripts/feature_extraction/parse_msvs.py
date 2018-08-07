# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

from features import *


def msvs_text_parser(input_file):
    diags = []
    cur_diag = None
    cur_message = ""

    for line in input_file:
        line = line.strip()
        if line == "":
            continue

        tokens = line.split("\t")
        if tokens[0].startswith("CA"):
            if cur_diag is not None:
                diags.append(cur_diag)

            cur_diag = Diagnostic(tool=Tool.VisualStudioCodeAnalysis)

            if len(tokens) == 3:
                cur_diag.add_feature(CheckerFeature(tokens[0]))
                cur_message = tokens[1] + "\n" + tokens[2]
            else:
                message = tokens[1] + "\n" + tokens[2]
                cur_diag.add_feature(CheckerFeature(tokens[0]))
                cur_diag.add_feature(FilePathFeature(tokens[-2]))
                cur_diag.add_feature(LineStartFeature(int(tokens[-1])))
                cur_diag.add_feature(MessageFeature(message))
        else:
            if len(tokens) == 1:
                cur_message += "\n" + tokens[0]
            else:
                cur_message += "\n" + tokens[0]
                cur_diag.add_feature(FilePathFeature(tokens[-2]))
                cur_diag.add_feature(LineStartFeature(int(tokens[-1])))
                cur_diag.add_feature(MessageFeature(cur_message))
    return diags

if __name__ == "__main__":
    import sys
    import json

    for item in sys.argv[1:]:
        results = {}
        results["diagnostics"] = [d.feature_value_dict()
                                  for d in msvs_text_parser(open(item))]
        print json.dumps(results)
