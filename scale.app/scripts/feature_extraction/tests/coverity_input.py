#!/usr/bin/env python

# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

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
