#!/usr/bin/env python

# Script to verify that classifiers ran correctly on all projects
#
# This should not be run as part of normal testing, it is to be run
# after generating confidences in SCAIFE. That is why this is not
# inside the test/python directory

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

import sqlite3

import bootstrap

class TestConfidence:
    def test_confidence(self):
        with sqlite3.connect(bootstrap.internal_db) as con:
            self.inspect_db(con)

    def inspect_db(self, con):
        cur = con.cursor()
        cur.execute("SELECT id, name FROM projects")
        for (project_id, project_name) in cur.fetchall():
            cur2 = con.cursor()
            cur2.execute("SELECT min(confidence), max(confidence)" +
                         "FROM displays WHERE project_id=?",
                         str(project_id))
            (minimum, maximum) = cur2.fetchone()
            assert minimum != -1, "Missing confidence value in %s" % \
                project_name
            assert minimum != maximum, "Confidence values all identical in %s" % \
                project_name
