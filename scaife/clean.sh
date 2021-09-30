#!/bin/sh

# Script to clean up extraneous files created by a docker
# container. Does not rely on container running.

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

# The mongo and redis containers are independent,
# Removing them deletes their data.
# So no cleanup necessary

echo "datahub-specific files"
rm -rf datahub_server_stub/swagger_server/uploaded_files/*
cp datahub_server_stub/swagger_server/test/test_output/README.md ./README.md.backup
rm -rf datahub_server_stub/swagger_server/test/test_output/*
mv ./README.md.backup datahub_server_stub/swagger_server/test/test_output/README.md

echo "Python-specific files"
rm -rf *_server_stub/.tox
find . -name *.pyc -exec rm -rf {} \;

echo "scale cleanup"
cd ./ui_server_stub/scale.app
sh -f ./clean.sh
cd ../..

echo "Cleanup done"
# Must run ./init.sh in scale container after cleanup
