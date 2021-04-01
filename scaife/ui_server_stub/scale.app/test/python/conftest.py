# <legal>
# SCALe version r.6.5.5.1.A
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

import pytest

def pytest_addoption(parser):
    parser.addoption("--sanitizer-project", action="store", default=None,
        help="""
            project name to sanitize and test (optional). Overrides
            --sanitizer-tgtdb. Default: None
            """.strip()
    )
    parser.addoption('--sanitizer-tgtdb', default=None,
        help="""
            source DB to sanitize (unless --sanitizer-no-sanitize is
            specified) and compare to reference DB (optional) Default:
            data/sanitizer/dos2unix.sanitizer.sqlite3
            """.strip()
    )
    parser.addoption('--sanitizer-refdb', default=None,
        help="""
            reference DB to be compared against (optional). Default:
            data/sanitizer/dos2unix.sanitizer.sanitized.sqlite3
            unless --sanitizer-no-sanitize is specified, in which case
            data/sanitizer/dos2unix.sanitizer.sqlite3
            """.strip()
    )
    parser.addoption('--sanitizer-salt', default=None,
        help="""
            salt file to be used for sanitizing (optional). Default:
            data/sanitizer/dos2unix.sanitizer.salt
        """.strip()
    )
    parser.addoption('--sanitizer-no-sanitize',
        action="store_true", default=False,
        help="do not sanitize target DB (compares to unsanitized reference DB)")
    parser.addoption('--sanitizer-keep', action="store_true", default=False,
        help="retain sanitized results in output directory")
