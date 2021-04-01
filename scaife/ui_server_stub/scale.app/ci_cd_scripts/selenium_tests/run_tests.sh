#!/bin/sh
# Script to run tests (except Selenium) on SCALe
# Takes one argument: bamboo_planRepository_branch, a Docker image tag
# Fills test-output directory with test results
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

bamboo_planRepository_branch=$1
TAG_NAME=docker.cc.cert.org/scale/scale.app:${bamboo_planRepository_branch//\//_}
# Docker complains if there's any slashes after the ":", so replace them all with underscores

TAG_NAME=docker.cc.cert.org/scale/scale.app:${bamboo_planRepository_branch//\//_} # Docker complains if there's any slashes after the ":", so replace them all with underscores

mkdir test-output cidfiles
#mkdir -p ~/.m2/repository/
docker run \
  --cidfile=cidfiles/selenium \
  --volume $(echo ~/.m2/):/root/.m2/:z \
  --shm-size=2g \
  --hostname=scale \
  $TAG_NAME \
  ./bin/test-selenium

docker cp $(cat cidfiles/selenium):/scale/test-output/. test-output
