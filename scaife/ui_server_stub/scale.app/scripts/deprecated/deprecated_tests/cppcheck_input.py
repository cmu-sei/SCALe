#!/usr/bin/env python

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
