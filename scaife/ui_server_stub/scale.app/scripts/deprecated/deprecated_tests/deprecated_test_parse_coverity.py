#!/usr/bin/env python

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

import unittest
import StringIO
import feature_extraction as fe
from feature_extraction.tests.coverity_input import CoverityJsonV2, CoverityJsonV2Event, CoverityJsonV2Issue
from feature_extraction.features import FeatureName


class TestCoverityJsonParser(unittest.TestCase):

    def test_coverity_json_parser_one_alert(self):
        covdata = CoverityJsonV2()
        issue = CoverityJsonV2Issue()
        event = CoverityJsonV2Event()
        issue.add_event(event)
        covdata.add_issue(issue)
        alerts = fe.extractors[fe.Tool.Coverity][
            "json_v2"](StringIO.StringIO(str(covdata)))
        self.assertEqual(len(alerts), 1)

        actual_alert = alerts[0]
        features = actual_alert.feature_dict()

        self.assertEqual(
            features[FeatureName.Checker].value, issue.data["checkerName"])
        self.assertEqual(
            features[FeatureName.FilePath].value, event.data["filePathname"])
        self.assertEqual(
            features[FeatureName.LineStart].value, event.data["lineNumber"])
        self.assertEqual(
            features[FeatureName.Message].value, event.data["eventDescription"])

    def test_coverity_json_parser_multi_alert(self):
        return
        covdata = CoverityJsonV2()
        for i in range(10):
            issue = CoverityJsonV2Issue()
            issue.data["checkerName"] = "SomeChecker" + str(i)
            event = CoverityJsonV2Event()
            event.data["eventDescription"] = "Message" + str(i)
            event.data["filePathname"] = "Path" + str(i)
            event.data["lineNumber"] = i
            event.data["main"] = True
            issue.add_event(event)
            covdata.add_issue(issue)

        alerts = fe.extractors[fe.Tool.Coverity][
            "json_v2"](StringIO.StringIO(str(covdata)))
        self.assertEqual(len(alerts), 10)
        counter = 0
        for alert in alerts:
            features = alert.feature_dict()
            self.assertEqual(
                features[FeatureName.Checker].value, ("SomeChecker" + str(counter)))
            self.assertEqual(
                features[FeatureName.FilePath].value, ("Path" + str(counter)))
            self.assertEqual(features[FeatureName.LineStart].value, counter)
            self.assertEqual(
                features[FeatureName.Message].value, ("Message" + str(counter)))
            counter += 1

if __name__ == '__main__':
    unittest.main()
