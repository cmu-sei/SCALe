# This module is for useful shared methods specific to the python tests.

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

from __future__ import print_function

import os, sys
import subprocess
from subprocess import CalledProcessError

import bootstrap

def callproc(cmd, capture_stderr=True, shell=None):
    if shell is None:
        shell = False if bootstrap.is_listish(cmd) else True
    try:
        if capture_stderr:
            res = subprocess.check_output(
                    cmd, stderr=subprocess.STDOUT, shell=shell)
        else:
            res = subprocess.check_output(cmd, shell=shell)
        return res
    except CalledProcessError as e:
        # bamboo unfortunately doesn't report regular stderr outside of
        # the stack trace, so we do it here instead
        msg = str(e)
        if e.output:
            msg += "\nOUTPUT:\n%s" % e.output
        raise Exception(msg)
