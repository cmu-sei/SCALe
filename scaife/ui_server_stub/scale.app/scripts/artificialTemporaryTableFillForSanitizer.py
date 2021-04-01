#!/usr/bin/env python

# The purpose of this script is to help create a new test database (unsanitized) for testing and updating the SCALe sanitizer.
#
# The developer should first manually create as much as possible of the new test project and export its database for
# use in the automated tests.
#
# IMPORTANT NOTES ABOUT HOW TO DO THIS: We currently use the "dos2unix" code and tool outputs located in
# $SCALE_HOME/scale.app/test/junit/test/scale_input/dos2unix/ to create new test databases. Make sure to assign one or more
# languages to the dos2unix test SCALe project (e.g., C89 and C90), to make some adjudications, use the sample user upload fields,
# and also make sure to create a classification scheme and a prioritization scheme. Every field whose sanitization will be
# tested must be filled.
# Generally, you should not fill the fields in the DB directly or with a script, because then you will not catch changes
# that could cause sensitive data to go unsanitized.

# HOWEVER, until some tables (like ClassifierMetrics) can be filled while connected to SCAIFE, those fields can be filled "manually".
# THIS "MANUAL" FIELD-FILLING SHOULD BE DONE WITH AND SCRIPTED IN ****THIS**** FILE.
# This script ("artificialTemporaryTableFillForSanitizer.py") should be used AND COMMITED INTO THE scale.app/scripts REPOSITORY
# (AND PR'd INTO THE MAIN DEVELOPMENT BRANCH) FOR ALL DEVELOPERS TO USE.
#
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

#import os, sys, re, argparse, subprocess
import os, sys, re, argparse, random, csv, hashlib, subprocess

import bootstrap
from bootstrap import VERBOSE

def artificialTemporaryTableFillForSanitizer(args):
    if VERBOSE:
            print("This function is where code needs to be added to automatically populate tables/fields, as specified in the SCALe manual in the Sanitizer section (at the bottom in the 'Updating the Sanitizer Test' section).  Add one new function per table that will be populated.")

def main():
    # code should be added here to insert artificial ClassifierMetrics into a SCALe DB (a previously-exported DB). This
    # code should insert the data into ANY SCALe DB (whether the user creates a test DB with dos2unix or JasPer, for instance).
    # See the SCALe Manual (Sanitizer section, at the bottom in the "Updating the Sanitizer Test" section).
    # parser = argparse.ArgumentParser(
    #     description="Adds data to a previously-exported SCALe database, when that data currently cannot be added via the GUI. This script is intended to be used to add data to tables/fields in an exported SCALe database, for use testing the SCALe sanitizer. This is necessary since not all tables/fields will always be able to be filled immediately, but the sanitizer should always be updated and tested for those fields when they are added to the exported database format.")

    parser = argparse.ArgumentParser(
        description="This script adds data to a previously-exported SCALe database, when that data currently cannot be added via the GUI. This script is intended to be used to add data to tables/fields in an exported SCALe database, for use testing the SCALe sanitizer. This is necessary since not all tables/fields will always be able to be filled immediately, but the sanitizer should always be updated and tested for those fields when they are added to the exported database format.             The purpose of this script is to help create a new test database (unsanitized) for testing and updating the SCALe sanitizer.		 The developer should first manually create as much as possible of the new test project and export its database for use in the automated tests.		 IMPORTANT NOTES ABOUT HOW TO DO THIS: We currently use the 'dos2unix' code and tool outputs located in $SCALE_HOME/scale.app/test/junit/test/scale_input/dos2unix/ to create new test databases. Make sure to assign one or more languages to the dos2unix test SCALe project (e.g., C89 and C90), to make some adjudications, use the sample user upload fields, and also make sure to create a classification scheme and a prioritization scheme. Every field whose sanitization will be tested must be filled.		 Generally, you should not fill the fields in the DB directly or with a script, because then you will not catch changes that could cause sensitive data to go unsanitized.		HOWEVER, until some tables (like ClassifierMetrics) can be filled while connected to SCAIFE, those fields can be filled 'manually'. THIS 'MANUAL' FIELD-FILLING SHOULD BE DONE WITH AND SCRIPTED IN ****THIS**** FILE. This script ('artificialTemporaryTableFillForSanitizer.py') should be used AND COMMITED INTO THE scale.app/scripts REPOSITORY. (AND PR'd INTO THE MAIN DEVELOPMENT BRANCH) FOR ALL DEVELOPERS TO USE.")

    parser.add_argument("-v", "--verbose", help="Verbose output")
    args = parser.parse_args()

    artificialTemporaryTableFillForSanitizer(args)


if __name__ == "__main__":
    main()
