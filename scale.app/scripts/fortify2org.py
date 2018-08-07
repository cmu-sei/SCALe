#!/usr/bin/env python

# Script takes a Fortify XML output file and extracts its diagnostic
# information
#
# The XML file name should be this script's sole argument. It should
# be produced from Fortify's Report->Fortify Developer's Workbook
# option, using XML as the file format.
#
# This script can produce one or two messages per diagnostic
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


class FortifyExtractor(ContentHandler):

    def __init__(self):
        self.path, self.line, self.category = '', '', ''
        self.abstract, self.chars = '', ''

    def startElement(self, name, attributes):
        self.chars = ""

    def characters(self, ch):
        self.chars = self.chars + ch
        return

    def endElement(self, name):
        if name == "Primary":
            sys.stdout.write("\n| " + self.category + " | " +
                             self.path + " | " + self.line +
                             " | " + self.abstract + " | ")
        elif name == "FilePath":
            self.path = self.chars
        elif name == "LineStart":
            self.line = self.chars
        elif name == "Category":
            p = re.compile(r"[^A-Za-z0-9_]")
            self.category = p.sub("_", self.chars)
        elif name == "Abstract":
            # The stored text should not contain newlines.
            # We remove trailing/leading whitespace,
            # then replace all inline newlines with a space. Also, we
            # remove "|" symbols from the text, since that symbol has special
            # meaning.
            self.abstract = self.chars.strip()
            self.abstract = self.abstract.replace("|", " ").replace("\n", " ")
        elif name == "Source":
            sys.stdout.write(self.path + " | " + self.line + " | | ")
        self.chars = ""


parser = make_parser()
parser.setContentHandler(FortifyExtractor())
parser.parse(open(input))
