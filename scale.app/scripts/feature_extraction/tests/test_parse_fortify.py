#!/usr/bin/env python

# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

import StringIO
import unittest

import feature_extraction as fe
from feature_extraction.features import FeatureName
from feature_extraction.tests.fortify_input import *


class TestFortifyXmlParser(unittest.TestCase):

    def test_fortify_xml_parser_one_diag(self):
        fort_data = FortifyDeveloperXml()
        fort_group = FortifyDeveloperXmlGrouping()
        fort_issue = FortifyDeveloperXmlIssue()
        fort_issue.primary_source = FortifyDeveloperXmlSource()
        fort_group.issues.append(fort_issue)
        fort_data.groups.append(fort_group)

        diagnostics = fe.extractors[fe.Tool.Fortify][
            "dev_xml"](StringIO.StringIO(str(fort_data)))
        self.assertEqual(len(diagnostics), 1)
        actual_diag = diagnostics[0]
        features = actual_diag.feature_dict()

        self.assertEqual(features[FeatureName.Checker].value,
                         fort_issue.data["category"])
        self.assertEqual(features[FeatureName.FilePath].value,
                         fort_issue.primary_source.data["filepath"])
        self.assertEqual(features[FeatureName.LineStart].value,
                         fort_issue.primary_source.data["linestart"])
        self.assertEqual(features[FeatureName.Message].value,
                         fort_issue.data["abstract"])

    def test_fortify_xml_parser_multi_diag(self):
        fort_data = FortifyDeveloperXml()
        fort_group = FortifyDeveloperXmlGrouping()
        for i in range(10):
            fort_issue = FortifyDeveloperXmlIssue()
            fort_issue.data["category"] = "SomeChecker" + str(i)
            fort_issue.data["abstract"] = "Message" + str(i)
            primary = FortifyDeveloperXmlSource()
            primary.data["filepath"] = "Path" + str(i)
            primary.data["linestart"] = i
            fort_issue.primary_source = primary
            fort_group.issues.append(fort_issue)
        fort_data.groups.append(fort_group)

        diagnostics = fe.extractors[fe.Tool.Fortify][
            "dev_xml"](StringIO.StringIO(str(fort_data)))
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
