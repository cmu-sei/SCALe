# Automated testing for feature/RC-1468
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

# Tests that the 'canonicalize_project.py' script works correctly.

# It would be nice if this test left the output data

import os
import subprocess
import shutil


class TestMethods:
    @classmethod
    def setUp(cls):
        # Why does os.getcwd() return a different path from $PWD???
        os.chdir(os.getenv("PWD"))   # scale.app
        return "test/python/data"


class TestCreateDatabase:

    def clean_up(self):
        try:
            shutil.rmtree("/tmp/scale.app")
        except Exception:
            pass

    def test_canonicalization(self):
        try:
            data_dir = TestMethods.setUp()

            subprocess.call(
                "unzip -d /tmp -q " + data_dir +
                "/input/canonicalization_test.zip",
                shell=True)

            # In the test input data, projects 57 and 59 are almost
            # identical. They were created manually using the same
            # parameters, and so they differ only in timestamps and
            # performance times (and project ids, obviously). So the
            # canonicalize_project.py should output identical
            # information for them.
            #
            # Project 58 has a different name and description, and was
            # created using a different process. Therefore
            # canonicalize_project.py should output different
            # information between projects 58 and 57, even though
            # they share the same codebase and analysis tool output.
            for project_id in ["57", "58", "59"]:
                err = subprocess.call(
                    "env SCALE_HOME=/tmp " +
                    "./scripts/canonicalize_project.py " + project_id +
                    " > /tmp/scale.app/" + project_id + ".txt",
                    shell=True)
                assert err == 0
            err = subprocess.call(
                "cmp /tmp/scale.app/57.txt /tmp/scale.app/59.txt",
                shell=True)
            assert err == 0
            err = subprocess.call(
                "cmp /tmp/scale.app/57.txt /tmp/scale.app/58.txt",
                shell=True)
            assert err != 0

        finally:
            self.clean_up()


if __name__ == '__main__':
    import pytest
    pytest.main()
