# Automated testing for bugfix/SCALE-244
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

# It would be nice if this test left the output file so can compare
# with answer.

import json
import os
import re
import subprocess


class TestMethods:
    @classmethod
    def setUp(cls):
        # Why does os.getcwd() return a different path from $PWD???
        os.chdir(os.getenv("PWD"))   # scale.app
        return "test/python/data"


class TestCreateDatabase:

    def clean_up(self):
        try:
            os.remove("out")
        except Exception:
            pass

    def test_fix_path(self):
        try:
            data_dir = TestMethods.setUp()
        except Exception:
            pass

        # Read test cases from input file
        with open(data_dir + "/test_fix_path_cases.json") as test_in:
            testcases = json.load(test_in)["testcases"]
        try:
            for testcase in testcases:
                # Run fix-path.py on each testcase
                subprocess.call(
                    ["scripts/fix_path.py",
                     data_dir + "/" + testcase["src"], testcase["input"],
                     "out"])
                with open("out") as out_fd:
                    parse = re.match("^Path .* updated to (.*)",
                                     out_fd.readline())
                assert parse is not None
                # Verify that fix-path produces the right output
                match = parse.group(1)
                assert match == testcase["answer"]
        finally:
            self.clean_up()




if __name__ == '__main__':
    import pytest
    pytest.main()
