#!/usr/bin/env python3

# Script takes an output file from a make command and removes make's footprints
#
# Its sole argument (optional) is a directory prefix, which gets
# pruned out of all directory commands.
#
# * Prunes out make error messages
# * Converts 'entering/leaving directory' into pushd/popd commands
# * Consequently, strips out cd-make commands
# * Collapses multiple lines with \ into one line
#
# The script should take the text data via standard input. The data
# should be produced from a build process using make. A suitable
# command to generate the text data is:
#
# make 2>&! > makelog
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

for line in sys.stdin:
    line = line.rstrip()

    # ignore cd && make commands
    parse = re.match(r"^cd (.*) \&\& make (.*)$", line)
    if (None != parse):
        continue

    parse = re.match(r"^make\[[0-9]*\]: Entering directory ['`](.*)[`']$", line)
    if (None != parse):
        directory = parse.group(1)
       # print("pushd " + directory)
        continue

    parse = re.match(r"^make\[[0-9]*\]: Leaving directory [`'](.*)[`']$", line)
    if (None != parse):
        directory = parse.group(1)
      #  print("popd " + directory)
        continue

    # ignore other make messages
    if (None != re.match(r"^make(\[[0-9]*\])?: ", line)):
        continue

    # collapse \ lines
    line, times = re.subn(r"\\$", r"", line)
    if (times == 1):
        print(line,)
        continue

    print(line)
