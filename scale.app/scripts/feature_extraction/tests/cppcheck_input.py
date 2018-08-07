#!/usr/bin/env python

# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

'''
Created on Dec 7, 2015

@author: wsnavely
'''
from xml.etree import ElementTree

from feature_extraction.tests.test_util import indent


base_template = """
<results>
{errors}
</results>
"""


class CppCheckXmlV2(object):

    def __init__(self):
        self.data = {}
        self.errors = []
        self.data["errors"] = ""

    def __str__(self):
        self.data["errors"] = ""
        for error in self.errors:
            self.data["errors"] += str(error)
        root = ElementTree.fromstring(base_template.format(**self.data))
        indent(root)
        return ElementTree.tostring(root)

error_template = """
<error file="{file}" line="{line}" id="{id}" severity="{sev}" msg="{msg}"/>
"""


class CppCheckXmlV2Error(object):

    def __init__(self):
        self.data = {}
        self.data["file"] = "File"
        self.data["line"] = 1
        self.data["id"] = "Checker"
        self.data["sev"] = "Severity"
        self.data["msg"] = "Message"

    def __str__(self):
        return error_template.format(**self.data)
