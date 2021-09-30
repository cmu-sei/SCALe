#!/usr/bin/env python
#
# Unit tests for jshint_oss2tsv.py script
# JSHint is an open-source static analysis tool for JavaScript
#
# The only argument indicates the file containing the input.
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

import unittest
import sys, os

import scripts.bootstrap as bootstrap
sys.path.insert(0, os.path.join(bootstrap.scripts_dir, "tool_output_parsers"))

import jshint_oss2tsv as t

class Test_jshint2org(unittest.TestCase):

    #Note: With the move from org to tsv files, the sanitize function was no longer needed and removed
    #def test_sanitize(self):
    #    self.assertEqual(t.sanitize(""), "")
    #    self.assertEqual(t.sanitize("\n"), "NEWLINE")
    #    self.assertEqual(t.sanitize("\n\n"), "NEWLINENEWLINE")
    #    self.assertEqual(t.sanitize("|"), "PIPE")
    #    self.assertEqual(t.sanitize("||"), "PIPEPIPE")
    #    self.assertEqual(t.sanitize("|\n|\n"), "PIPENEWLINEPIPENEWLINE")

    def test_convert_matches(self):
        self.assertEqual(t.convert_matches("","","",""), "\t/\t\t")
        self.assertEqual(t.convert_matches("one","two","three","four"), "one\t/two\tthree\tfour")
        self.assertEqual(t.convert_matches("one","abcd/efghid//two","three","four"), "one\t/abcd/efghid//two\tthree\tfour")

    def test_handle_line(self):
        matcher = t.load_checkers()
        self.assertEqual(t.handle_line("app/assets/javascripts/modals.js: line 542, col 28, 'validateTabFormula' was used before it was defined.", matcher), \
                        "JS-8\t/app/assets/javascripts/modals.js\t542\t'validateTabFormula' was used before it was defined.")
        self.assertEqual(t.handle_line("app/assets/javascripts/modals.js: line 549, col 9, Expected '{' and instead saw 'operators'.", matcher), \
                        "JS-2\t/app/assets/javascripts/modals.js\t549\tExpected '{' and instead saw 'operators'.")
        self.assertEqual(t.handle_line("app/assets/javascripts/modals.js: line 48, col 28, 'status' is defined but never used.", matcher), \
                        "JS-1\t/app/assets/javascripts/modals.js\t48\t'status' is defined but never used.")
        self.assertEqual(t.handle_line("app/assets/javascripts/onload.js: line 45, col 5, 'setFilters' is not defined.", matcher), \
                        "JS-9\t/app/assets/javascripts/onload.js\t45\t'setFilters' is not defined.")
        self.assertEqual(t.handle_line("app/assets/javascripts/modals.js: line 100, col 9, 'destructuring expression' is available in ES6 (use esnext option) or Mozilla JS extensions (use moz).", matcher), \
                        "JS-3\t/app/assets/javascripts/modals.js\t100\t'destructuring expression' is available in ES6 (use esnext option) or Mozilla JS extensions (use moz).")
        self.assertEqual(t.handle_line("app/assets/javascripts/modals.js: line 393, col 20, Missing semicolon.", matcher), \
                        "JS-5\t/app/assets/javascripts/modals.js\t393\tMissing semicolon.")
        self.assertEqual(t.handle_line("app/assets/javascripts/modals.js: line 521, col 26, 'validateGrouping' was used before it was defined.", matcher), \
                        "JS-8\t/app/assets/javascripts/modals.js\t521\t'validateGrouping' was used before it was defined.")
        self.assertEqual(t.handle_line("I like apples", matcher), \
                        None)



if __name__ == "__main__":
    unittest.main()
