#!/usr/bin/env python

# Script takes a Perl::Critic text output file and extracts its diagnostic
# information
#
# The only argument indicates the file containing the input.  The data
# should be produced from a build process using Perl:Critic using the
# following line:
#
# perlcritic "^^ %p ^^ %f ^^ %l ^^ %m / %e / %s ^^\n" *.pl
#
# This script never produces more than one message per diagnostic
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import re

if len(sys.argv) != 2:
    raise TypeError("Usage: " + sys.argv[0] + " <raw-input> > <org-output>")
input = sys.argv[1]

for line in open(input):
    print line.strip().replace("^^", "|").replace("::", "_")
