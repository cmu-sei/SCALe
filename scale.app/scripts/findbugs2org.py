#!/usr/bin/env python

# Script takes a FindBugs 3.0 XML output file and extracts its diagnostic
# information
#
# The only argument indicates the file containing the input.
# The input should be produced by a command like this:
#   findbugs -textui -low -progress -xml:withMessages -output findbugs.xml ...
#
# This script never produces more than one message per diagnostic
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import re
from xml.sax import make_parser
from xml.sax.handler import ContentHandler

if len(sys.argv) != 2:
    raise TypeError("Usage: " + sys.argv[0] + " <raw-input> > <org-output>")
input = sys.argv[1]


class FindbugsExtractor(ContentHandler):

    def __init__(self):
        self.path, self.line, self.msg = '', '', ''
        self.checker, self.chars = '', ''

    def startElement(self, name, attributes):
        self.chars = ""
        if name == "BugInstance":
            self.checker = attributes.getValue("type")

        elif name == "SourceLine":
            if "sourcepath" in attributes.getNames():
                self.path = attributes.getValue("sourcepath")
            if "start" in attributes.getNames():
                self.line = attributes.getValue("start")

    def characters(self, ch):
        self.chars = self.chars + ch
        return

    def endElement(self, name):
        if name == "LongMessage":
            # The stored text should not contain newlines.
            # We remove trailing/leading whitespace,
            # then replace all inline newlines with a space. Also, we
            # remove "|" symbols from the text, since that symbol has special
            # meaning.
            self.msg = self.chars.strip()
            self.msg = self.msg.replace("|", " ").replace("\n", " ")

        elif name == "BugInstance":
            sys.stdout.write("| " + self.checker + " | " + self.path +
                             " | " + self.line + " | " + self.msg + " |\n")

        self.chars = ""


parser = make_parser()
parser.setContentHandler(FindbugsExtractor())
parser.parse(open(input))
