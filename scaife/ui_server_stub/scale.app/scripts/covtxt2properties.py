#!/usr/bin/env python

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

import os
import sys
import re
import bootstrap

PROPERTIES_DIR = bootstrap.properties_dir

inFile = sys.argv[1]
property_file_path = os.path.join(PROPERTIES_DIR, "cwes/c.coverity.properties")
with open(property_file_path, 'w') as w:
    w.write(
        "# Mappings from Coverity error identifiers (aka categories) to CWE IDs\n")

    with open(inFile, 'r') as f:
        contents = f.read()
        count = 0
        for line in contents.split("\n"):
            start = True
            if line.split() != []:
                if line.split()[0] == "#" or "http" in line:
                    w.write("#" + line + "\n")
                elif count < 2:
                    count += 1
                else:
                    w.write(
                        line.split()[1] + " : CWE-" + line.split()[3] + "\n")
