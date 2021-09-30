#!/bin/bash

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

BIN_LOC=$(readlink -f "${BASH_SOURCE[0]}")
BASE_DIR=$(dirname "$BIN_LOC")

. $BASE_DIR/env.sh

rm -rf $SCALE_DIR/public/GNU/*
rm -rf $SCALE_DIR/archive
rm -f $SCALE_DIR/db/external.sqlite3
rm -f $SCALE_DIR/db/development.sqlite3
rm -rf $SCALE_DIR/db/development
rm -f $SCALE_DIR/log/development.log
rm -f $SCALE_DIR/db/test.sqlite3
rm -rf $SCALE_DIR/db/test
rm -f $SCALE_DIR/log/test.log
