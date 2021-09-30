# Python unit tests
#
# Does not depend on SCALE_HOME, sets it based on pwd, which should be
# scale.app
#
# Launch an experiment SCALe server, and run some automated tests on it.

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

import os
import subprocess
from subprocess import Popen
import time

import scripts.bootstrap as bootstrap
from scripts.automation.automate import ScaleSession, FetchError
import util
import pytest


KEEP_OUTPUT = False

class TestExperiment:

    def setup(self):
        os.environ["SCALE_EXPERIMENT"] = "1"
        # 8093 in case we are on SCALe container (which uses 8083
        self.scale = Popen(["bundle", "exec", "thin", "start", "--port", "8093"])
        self.svc = bootstrap.scale_service()
        self.sess = ScaleSession(port="8093")
        # Make sure SCALe is ready
        for i in range(5):
            try:
                self.sess.get(self.sess.route())
                self.sess.event_scale_session_establish()
                return
            except FetchError as e:
                time.sleep(5)
        raise e # SCALe is too slow to start!

    def teardown(self):
        self.scale.terminate()

    def test_audit_log(self):
        dos2unix_dir = os.path.join(bootstrap.junit_test_data_dir, "dos2unix")
        analysis_dir = os.path.join(dos2unix_dir, "analysis")
        src_file = os.path.join(dos2unix_dir, "dos2unix-7.2.2.tar.gz")
        tools = { "rosecheckers_oss-c-cpp": (os.path.join(analysis_dir, "rosecheckers_oss.txt"), "")   }
        # pytest.set_trace()
        self.sess.event_project_create("foo", "foo desc", src_file=src_file,
                                       tools=tools, languages=[1, 2, 3])
        # project_id=project_id )
        project_id = self.sess.project_id

        # first few fused meta_alerts with checker FIO30-C set to False
        self.sess.query_mass_update([186, 149], verdict=2, primed=True)
        # first few fused meta_alerts set to True
        self.sess.query_mass_update([160], verdict=4, primed=True)

        canonicalize_script = os.path.join(bootstrap.scripts_dir, "canonicalize_project.py")
        answer_data = os.path.join(os.path.join(bootstrap.python_test_data_dir, "good"), "good.experiment.audit.txt")
        cmd = canonicalize_script + " --user " + str(project_id) + " | grep -A3 audit | sed -e 's/ROW: [0-9]*|/ROW: /;  s/|[0-9]*$//' | diff - " + answer_data
        result = subprocess.call( cmd, shell=True)
        assert result == 0, "Audit log differs"

        # This assumes the userid is 1!
        det_data = os.path.join(os.path.join(bootstrap.python_test_data_dir, "good"), "good.experiment.dets.txt")
        cmd = canonicalize_script + " " + str(project_id) + " | grep determinations | diff - " + det_data
        result = subprocess.call( cmd, shell=True)
        assert result == 0, "Determination data differs"


if __name__ == '__main__':
    pytest.main()
