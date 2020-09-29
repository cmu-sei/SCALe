#!/usr/bin/env python

# Script takes a Fortify XML output file and extracts its alert
# information
#
# The XML file name should be this script's first argument. It should
# be produced from Fortify's Report->Fortify Developer's Workbook
# option, using XML as the file format.
#
# This script's second argument specifies the output file.
#
# This script can produce one or two messages per alert
#
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

import os
import sys
import re
from xml.sax import make_parser
from xml.sax.handler import ContentHandler
from fortify_fvdl2tsv import fortify_fvdl_parse

from toolparser import tool_parser_args

class RootException(Exception):
    def __init__(self):
        pass


class XmlType(ContentHandler):
    def __init__(self):
        self.root = None

    def startElement(self, name, attributes):
        self.root = name
        raise RootException


class FortifyExtractor(ContentHandler):

    def __init__(self, output_file):
        self.output_file = output_file
        self.checker = ""
        self.file_path = ""
        self.line_number = ""
        self.message = ""
        self.chars = ""

    def startElement(self, name, attributes):
        self.chars = ""

    def characters(self, ch):
        self.chars = self.chars + ch
        return

    def endElement(self, name):
        if name == "Primary":
            self.message = self.message.strip().replace('\t', " ")
            column_values = "\t".join([self.checker, self.file_path, self.line_number, self.message])
            self.output_file.write("\n" + column_values)
        elif name == "FilePath":
            self.file_path = self.chars
        elif name == "LineStart":
            self.line_number = self.chars
        elif name == "Category":
            p = re.compile(r"[^A-Za-z0-9_]")
            self.checker = p.sub("_", self.chars)
        elif name == "Abstract":
            # The stored text should not contain newlines.
            # We remove trailing/leading whitespace,
            # then replace all inline newlines with a space. Also, we
            # remove "|" symbols from the text, since that symbol has special
            # meaning.
            self.message = self.chars.strip()
        elif name == "Source":
            secondary_message = " "
            secondary_message = secondary_message.strip().replace("\t", " ")
            column_values = "\t".join([self.file_path, self.line_number, secondary_message])
            self.output_file.write("\t" + column_values)
        self.chars = ""


if __name__ == "__main__":
    args = tool_parser_args()

    # We want to treat FVDL files differently, but we can't trust the
    # filename suffix So we parse the XML using SAX, save the root,
    # and abort the parse with RootException.
    with open(args.input_file, "r") as input_fh:
        parser = make_parser()
        x = XmlType()
        parser.setContentHandler(x)
        try:
            parser.parse(input_fh)
        except RootException:
            pass
        root = x.root

    with open(args.input_file, "r") as input_fh:
        with open(args.output_file, "w") as output_fh:
            if "fvdl" == root.lower():
                fortify_fvdl_parse(input_fh, output_fh)
            else:
                parser = make_parser()
                parser.setContentHandler(FortifyExtractor(output_fh))
                parser.parse(input_fh)
