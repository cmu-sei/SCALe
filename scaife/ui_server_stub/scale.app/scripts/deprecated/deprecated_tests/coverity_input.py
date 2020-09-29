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

import hashlib
import json


class CoverityJsonV2Event(object):

    def __init__(self):
        self.data = {}
        self.data["covLStrEventDescription"] = "CovLStrEventDescription"
        self.data["eventDescription"] = "EventDescription"
        self.data["eventNumber"] = 1
        self.data["eventTreePosition"] = "1"
        self.data["eventSet"] = 0
        self.data["eventTag"] = "path"
        self.data["filePathname"] = "/some/path/name"
        self.data["strippedFilePathname"] = "/stripped/path/name"
        self.data["lineNumber"] = 1
        self.data["main"] = True
        self.data["moreInformationId"] = None
        self.data["remediation"] = False
        self.data["events"] = []

    def add_event(self, event):
        self.data["events"].append(event.data)

    def __str__(self):
        return json.dumps(self.data)


class CoverityJsonV2Issue(object):

    def __init__(self):
        self.data = {}
        self.data["checkerName"] = "CheckerName"
        self.data["mainEventFilePathname"] = "PathName"
        self.data["strippedMainEventFilePathname"] = "StrippedPathName"
        self.data["mainEventLineNumber"] = 1
        self.data["functionDisplayName"] = "FunctionName"
        self.data["functionMangledName"] = "MangledFunctionName"
        self.data["domain"] = "STATIC_C"
        self.data["subcategory"] = "none"
        self.data["mergeKey"] = hashlib.md5("MergeKey").hexdigest()
        self.data["occurrenceCountForMK"] = 1
        self.data["occurrenceNumberInMK"] = 1
        self.data["extra"] = ""
        self.data["properties"] = {}
        self.data["ordered"] = True
        self.data["stateOnServer"] = None
        self.data["checkerProperties"] = None
        self.data["events"] = []

    def add_event(self, event):
        self.data["events"].append(event.data)

    def __str__(self):
        return json.dumps(self.data)


class CoverityJsonV2(object):

    def __init__(self):
        self.data = {}
        self.data["type"] = "Coverity Issues"
        self.data["formatVersion"] = 2
        self.data["suppressedIssueCount"] = 0
        self.data["desktopAnalysisSettings"] = None
        self.data["error"] = None
        self.data["issues"] = []

    def add_issue(self, issue):
        self.data["issues"].append(issue.data)

    def __str__(self):
        return json.dumps(self.data)
