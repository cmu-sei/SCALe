#!/usr/bin/env python

# This script ```convert_lizard_metrics.py``` is used to convert an old type of Lizard code metrics tool output into a format that the current version of SCALe can use as input.
# SCALe produces some errors when importing the ORIGINAL Lizard output file that was produced.
# The ORIGINAL Lizard output file has 16 columns, but the current version of SCALe requires 15.
#
# This problem may occur in much of the previously-created Lizard output from other projects as well (due to a previous version of Lizard and/or a different way of running Lizard).
# To enable current SCALe to import those old Lizard output files with 16 columns, a developer must remove the final NULL from last line, using a text editor.
#
# Detail for importing the Lizard (or any) metrics into SCALe: it must be accompanied by an upload of static analysis tool output. Even an empty GCC.txt file uploaded for gcc_oss tool output (if for C code), or similar file for other languages, will suffice so that the metrics file can be uploaded to a project by SCALe.
#
# The old-format Lizard output is parsed by SCALe when input, with conversion done by the script convert_lizard_metrics.py

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

import csv
import sys


def convert_lizard_metrics():
    function_map = ["path", None, "nloc", None, "n_functions",
                    None, "avg_cyc_comp_per_function", None,
                    "avg_nloc_per_function", "avg_n_fun_params_per_function",
                    None, None, "avg_n_tokens_per_function", None, None]
    file_map = ["name", "length", "nloc", "path", None,
                "cyc_comp", None, "params", None, None,
                None, "n_tokens", None, None, None]
    # last two are really start_line, end_line, must be computed separately

    reader = csv.reader(sys.stdin)
    writer = csv.writer(sys.stdout)

    headers = dict((v, k) for k, v in enumerate(reader.next()))
    length = headers["length"]

    for data in reader:
        keymap = file_map if (data[headers["kind"]]
                              == "source_function") else function_map
        out_data = []
        for counter in range(len(keymap)):
            out_data.append("" if keymap[counter] is None else
                            data[headers[keymap[counter]]])

        # handle start_line and end_line
        if keymap == file_map:
            out_data[-2] = 1
            out_data[-1] = float(data[length])+1

        writer.writerow(out_data)


if __name__ == "__main__":
    convert_lizard_metrics()
