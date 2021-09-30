#!/usr/bin/env python

# Script takes a FindBugs 3.0 XML output file and extracts its alert
# information.
#
# The first argument indicates the file containing the input.
# The input should be produced by a command like this:
#   findbugs -textui -low -progress -xml:withMessages -output findbugs.xml ...
#
# The second argument specifies the output file.
#
# This script never produces more than one message per alert
#
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

import sys
import re
from xml.sax import make_parser
from xml.sax.handler import ContentHandler

from toolparser import tool_parser_args

class FindbugsExtractor(ContentHandler):

    def __init__(self, output_file):
        self.output_file = output_file
        self.checker = ""
        self.file_path = ""
        self.line_number = ""
        self.message = ""
        self.chars = ""

    def startElement(self, name, attributes):
        self.chars = ""
        if name == "BugInstance":
            self.checker = attributes.getValue("type")

        elif name == "SourceLine":
            if "sourcepath" in attributes.getNames():
                self.file_path = attributes.getValue("sourcepath")
            if "start" in attributes.getNames():
                self.line_number = attributes.getValue("start")

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
            self.message = self.chars.strip()

        elif name == "BugInstance":
            self.message = self.message.strip().replace("\t", " ")
            column_values = "\t".join([self.checker, self.file_path, self.line_number, self.message])
            self.output_file.write(column_values + "\n")

        self.chars = ""


if __name__ == "__main__":
    args = tool_parser_args()

    input_fh = open(args.input_file, "r")
    output_fh = open(args.output_file, "w")

    parser = make_parser()
    parser.setContentHandler(FindbugsExtractor(output_fh))
    parser.parse(input_fh)
