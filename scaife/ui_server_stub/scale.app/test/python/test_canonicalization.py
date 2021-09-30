# Automated testing for feature/RC-1468
#
# Tests that the 'canonicalize_project.py' script works correctly.

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

import pytest

import os, sys
import subprocess

import scripts.bootstrap as bootstrap
import util

KEEP_OUTPUT = False

class TestCanonicalization:

    @pytest.fixture(scope="class", autouse=True)
    def setup_all(self, request):
        bootstrap.set_env(scale_home_val=bootstrap.tmp_dir)

    def test_canonicalization(self):
        tmp_dir = bootstrap.get_tmp_dir(ephemeral = not KEEP_OUTPUT,
                suffix="test_canonicalization")

        # store these; change them back later. 'development' is hard
        # coded into the zip file, so use that even if we're in
        # test mode.
        old_scale_home = bootstrap.scale_home
        old_rails_env = bootstrap.rails_env
        bootstrap.set_env(
                scale_home_val=bootstrap.tmp_dir,
                rails_env_val="development",
        )

        input_dir = os.path.join(bootstrap.python_test_data_dir, "input")
        input_zip = os.path.join(input_dir, "canonicalization_test.zip")

        bootstrap.unpack(input_zip, tgt_dir=tmp_dir, verbose=True)

        # In the test input data, projects 1 and 3 are almost identical.
        # They were created manually using the same parameters, and so
        # they differ only in timestamps and performance times (and
        # project ids, obviously). So the canonicalize_project.py should
        # output identical information for them.
        #
        # Project 2 has a different name, description, a meta-alert
        # verdict set to "True", and a meta-alert verdict set it
        # "False". Therefore canonicalize_project.py should output
        # different information between projects 1 and 2, even though
        # they share the same codebase and analysis tool output.
        #
        # To recreate the test data in canonicalization_test.zip:
        # Note: The micro-Juliet ZIP file, tool_output, and C99 code
        # language should be used to create all three projects
        #
        # 1.  Create Project 1 (project names and descriptions
        #     are ignored by the canonicalization process)
        # 2.  Create Project 2 and set one meta-alert verdict to
        #     "True" and one meta-alert to "False"
        # 3.  Create Project 3 by following exactly the same steps used
        #     to create Project 1
        # 4.  From the parent directory of scale.app, run the following
        #     command: zip -r canonicalization_test scale.app/archive
        #     scale.app/db scale.app/public
        #
        # Replace the ZIP file located at:
        #   scale.app/test/python/data/input/canonicalization_test.zip
        # From the scale.app directory, run the following test to verify the
        # data was updated correctly:
        #  pytest ./test/python/test_canonicalization.py

        try:
            script = os.path.join(bootstrap.scripts_dir,
                    "canonicalize_project.py")
            for project_id in ["1", "2", "3"]:
                out_file = os.path.join(tmp_dir, "%s.txt" % project_id)
                cmd = ' '.join(["SCALE_HOME=%s" % tmp_dir,
                    "python", script, str(project_id), ">", out_file])
                util.callproc(cmd)
            cmd = "cmp %s/1.txt %s/3.txt" % (tmp_dir, tmp_dir)
            res = subprocess.call(cmd, shell=True)
            assert res == 0, "files differ, cmd: %s" % cmd
            cmd = "cmp %s/1.txt %s/2.txt" % (tmp_dir, tmp_dir)
            res = subprocess.call(cmd, shell=True)
            assert res != 0, "files unexpectedly match: %s" % cmd
        finally:
            # don't want to impact the assumptions of other tests
            bootstrap.set_env(
                scale_home_val=old_scale_home,
                rails_env_val=old_rails_env
            )


if __name__ == '__main__':
    import pytest
    pytest.main()
