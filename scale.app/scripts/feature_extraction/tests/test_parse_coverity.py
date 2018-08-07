#!/usr/bin/env python

# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

import unittest
import StringIO
import feature_extraction as fe
from feature_extraction.tests.coverity_input import CoverityJsonV2, CoverityJsonV2Event, CoverityJsonV2Issue
from feature_extraction.features import FeatureName


class TestCoverityJsonParser(unittest.TestCase):

    def test_coverity_json_parser_one_diag(self):
        covdata = CoverityJsonV2()
        issue = CoverityJsonV2Issue()
        event = CoverityJsonV2Event()
        issue.add_event(event)
        covdata.add_issue(issue)
        diagnostics = fe.extractors[fe.Tool.Coverity][
            "json_v2"](StringIO.StringIO(str(covdata)))
        self.assertEqual(len(diagnostics), 1)

        actual_diag = diagnostics[0]
        features = actual_diag.feature_dict()

        self.assertEqual(
            features[FeatureName.Checker].value, issue.data["checkerName"])
        self.assertEqual(
            features[FeatureName.FilePath].value, event.data["filePathname"])
        self.assertEqual(
            features[FeatureName.LineStart].value, event.data["lineNumber"])
        self.assertEqual(
            features[FeatureName.Message].value, event.data["eventDescription"])

    def test_coverity_json_parser_multi_diag(self):
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

        diagnostics = fe.extractors[fe.Tool.Coverity][
            "json_v2"](StringIO.StringIO(str(covdata)))
        self.assertEqual(len(diagnostics), 10)
        counter = 0
        for diag in diagnostics:
            features = diag.feature_dict()
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
