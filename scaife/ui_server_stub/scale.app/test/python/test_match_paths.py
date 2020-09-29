# Automated testing for match_paths.py
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


import json
import os
import re
import subprocess


class TestMethods:
    @classmethod
    def setUp(cls):
        os.chdir(os.getenv("PWD"))   # scale.app
        return "test/python/data"


class TestCreateDatabase:

    def clean_up(self):
        try:
            os.remove("out")
        except Exception:
            pass

    def test_match_paths(self):
        try:
            data_dir = TestMethods.setUp()
        except Exception:
            pass

        # Read test cases from input file
        with open(data_dir + "/test_match_path_cases.json") as test_in:
            testcases = json.load(test_in)["testcases"]
        try:
            for testcase in testcases:
                # Run match_paths.py on each testcase
                subprocess.call(
                    ["scripts/match_paths.py",
                     data_dir + "/" + testcase["src"], testcase["input"],
                     "out"])
                     
                with open("out") as out_fd:
                   printed_line = out_fd.readline()
                   
                   # Test case not found in directory
                   if testcase["answer"] == None: 
                       assert printed_line == "[Warning] Path not found in the provided source: " + testcase["input"] + "\n"
                   else:                       
                       assert printed_line == "Path " + testcase["input"] + " updated to " + testcase["answer"] + "\n"
                    
        finally:
            self.clean_up()




if __name__ == '__main__':
    import pytest
    pytest.main()
