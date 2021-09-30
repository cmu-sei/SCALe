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

import StringIO
import unittest

import feature_extraction as fe
from feature_extraction.features import FeatureName
from feature_extraction.tests.fortify_input import *


class TestFortifyXmlParser(unittest.TestCase):

    def test_fortify_xml_parser_one_alert(self):
        fort_data = FortifyDeveloperXml()
        fort_group = FortifyDeveloperXmlGrouping()
        fort_issue = FortifyDeveloperXmlIssue()
        fort_issue.primary_source = FortifyDeveloperXmlSource()
        fort_group.issues.append(fort_issue)
        fort_data.groups.append(fort_group)

        alerts = fe.extractors[fe.Tool.Fortify][
            "dev_xml"](StringIO.StringIO(str(fort_data)))
        self.assertEqual(len(alerts), 1)
        actual_alert = alerts[0]
        features = actual_alert.feature_dict()

        self.assertEqual(features[FeatureName.Checker].value,
                         fort_issue.data["category"])
        self.assertEqual(features[FeatureName.FilePath].value,
                         fort_issue.primary_source.data["filepath"])
        self.assertEqual(features[FeatureName.LineStart].value,
                         fort_issue.primary_source.data["linestart"])
        self.assertEqual(features[FeatureName.Message].value,
                         fort_issue.data["abstract"])

    def test_fortify_xml_parser_multi_alert(self):
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

        alerts = fe.extractors[fe.Tool.Fortify][
            "dev_xml"](StringIO.StringIO(str(fort_data)))
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
