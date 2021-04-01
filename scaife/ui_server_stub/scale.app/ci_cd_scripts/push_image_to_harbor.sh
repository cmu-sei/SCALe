#!/bin/sh
# Script to push to Harbor this current Docker image
# Takes two arguments:
#   bamboo_planRepository_branch, a Docker image tag
#   bamboo_pme_svc, a username
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
bamboo_pme_svc=$2
TAG_NAME=docker.cc.cert.org/scale/scale.app:${bamboo_planRepository_branch//\//_}
# Docker complains if there's any slashes after the ":", so replace them all with underscores
docker login -u ${bamboo_pme_svc} --password-stdin docker.cc.cert.org < ~/.bamboo_harbor.txt
docker push $TAG_NAME
docker logout docker.cc.cert.org
