# Automated testing for match_paths.py

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


import json
import os
import re

import scripts.bootstrap as bootstrap
import util

KEEP_OUTPUT = False

class TestMatchPath:

    def test_match_paths(self):
        data_dir = bootstrap.python_test_data_dir
        tmp_dir = bootstrap.get_tmp_dir(ephemeral = not KEEP_OUTPUT,
                suffix="test_match_paths")
        tmp_out = os.path.join(tmp_dir, "match_test_output.dat")

        # Read test cases from input file
        cases_file = os.path.join(data_dir, "test_match_path_cases.json")
        with open(cases_file) as test_in:
            testcases = json.load(test_in)["testcases"]
        script = os.path.join(bootstrap.scripts_dir, "match_paths.py")
        for testcase in testcases:
            # Run match_paths.py on each testcase
            src_path = os.path.join(data_dir, testcase["src"])
            cmd = [script, src_path, testcase["input"], tmp_out]
            util.callproc(cmd)
            with open(tmp_out) as out_fd:
               printed_line = out_fd.readline()
               # Test case not found in directory
               if testcase["answer"] == None:
                   assert printed_line == "[Warning] Path not found in the provided source: " + testcase["input"] + "\n"
               else:
                   assert printed_line == "Path " + testcase["input"] + " updated to " + testcase["answer"] + "\n"


if __name__ == '__main__':
    import pytest
    pytest.main()
