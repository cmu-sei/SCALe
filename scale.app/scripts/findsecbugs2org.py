#!/bin/sh

# Script takes a find-security-bugs text output file and extracts its
# diagnostic information
# This merely delegates its args to findbugs2org.py
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


./findbugs2org.py $*
