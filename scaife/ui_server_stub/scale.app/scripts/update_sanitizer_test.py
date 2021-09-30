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

import os, sys, shutil

import bootstrap
from sanitize_db import sanitize_db

sanitizer_script = os.path.join(bootstrap.scripts_dir, "sanitize_db.py")

data_dir = os.path.join(bootstrap.python_test_data_dir, "sanitizer")

# remember to start with a clean DB and export your project DB to this file
reference_db = os.path.join(data_dir, "dos2unix.sanitizer.sqlite3")
salt_file = os.path.join(data_dir, "dos2unix.sanitizer.salt")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        new_db = sys.argv[1]
        print("copy: %s -> %s" % (new_db, os.path.relpath(reference_db, bootstrap.base_dir)))
        shutil.copy(sys.argv[1], reference_db)
    # ./sanitize_db.py -H -C -s salt_file reference_db
    print("sanitize %s" % reference_db)
    sanitize_db(reference_db, hashname=False, salt_file=salt_file, copy=False)
