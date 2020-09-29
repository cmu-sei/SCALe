#!/bin/sh

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

SERVERPID=./tmp/server.pid
PID=$(cat $SERVERPID)
echo "Killing existing server with pid=$PID"
kill $PID

sh -f ./clean.sh

bundle exec rake db:schema:load
bundle exec rake db:seed
bundle exec thin start --port 8083
# To use SSH:
# nohup bundle exec thin start --ssl --port $PORT --ssl-cert-file $APP/server.crt --ssl-key-file $APP/server.key --daemonize --pid $SERVERPID &