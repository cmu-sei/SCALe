# Python unit tests
#
# Does not depend on SCALE_HOME, sets it based on pwd, which should be
# scale.app
#
# These tests are to be run in a SCALe container, when all of SCAIFE
# has been launched in experiment mode.

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
import pytest


class TestEndExperiment:

    def setup(self):
        self.svc = bootstrap.scale_service()
        self.sess = ScaleSession(port="8093")
        # Make sure SCALe is ready
        for i in range(5):
            try:
                self.sess.get(self.sess.route())
                self.sess.event_scale_session_establish()
                self.sess.event_scaife_session_establish()
                return
            except FetchError as e:
                time.sleep(5)
        raise e # SCALe is too slow to start!


    def test_max_adjudication_experiment(self):
        html = self.sess.get(self.sess.route("experiments"))
        params = self.sess.default_params()
        params.update({"experiment_name": "max adjudication test"})
        html = self.sess.post(self.sess.route("/experiments/create"), params)
        project_id = self.sess.project_id

        html = self.sess.event_view_project()
        # first few meta_alerts with checker FIO30-C set to False
        self.sess.query_mass_update([186, 149], verdict=2, primed=True)
        self.sess.event_view_project()
        # first few meta_alerts set to True
        self.sess.query_mass_update([160], verdict=4, primed=True)
        html = self.sess.event_view_project()
        # Should cause experiment to complete

        # TODO export experiment data and verify it is good.
        # Test will be completed (or alternatevly abandoned) in (RC-1798)
        pytest.set_trace()


if __name__ == '__main__':
    pytest.main()
