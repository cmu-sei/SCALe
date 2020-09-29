#!/bin/sh

# http://pulsar.apache.org/docs/en/io-quickstart/
# Based on this doc, we assume that Pulsar is ready when the cmd
# returns the expected output.

# <legal>
# SCALe version r.6.2.2.2.A
# 
# Copyright 2020 Carnegie Mellon University.
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

# Takes a single argument: the host that Pulsar runs on.
HOST=$1

# Preserve our own PID for easy shutdown
PID=$$
echo $PID > $SCALE_HOME/scale.app/tmp/connect_to_pulsar.pid

url="http://${HOST}:8080/admin/v2/worker/cluster"
cmd="wget -q -O - ${url}"
expected='[{"workerId":"c-standalone-fw-localhost-8080","workerHostname":"localhost","port":8080}]'

while [ "`$cmd`" != "$expected" ]; do
    echo waiting for Pulsar
    sleep 2
done
echo Pulsar is available

# Launch subscriber and stash its PID for remote shutdown
python scripts/stats_subscriber.py > $SCALE_HOME/scale.app/log/subscription.stats.log &
echo $! > $SCALE_HOME/scale.app/tmp/stats_subscriber.pid
