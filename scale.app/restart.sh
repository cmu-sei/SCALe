#!/bin/sh
# -*- coding: undecided -*-
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.


# Location for istallation of SCALe web app
APP=$SCALE_HOME/scale.app
# Port for app to use
PORT=8080

SERVERPID=$APP/tmp/pids/server.pid
PID=$(cat $SERVERPID)
echo "Killing existing server with pid=$PID"
kill -9 $PID
echo "Starting server on port $PORT"
bundle exec thin start --port $PORT --daemonize --pid $SERVERPID
# To use SSH:
#nohup bundle exec thin start --ssl --port $PORT --ssl-cert-file $APP/server.crt --ssl-key-file $APP/server.key --daemonize --pid $SERVERPID 2>/dev/null 1>/dev/null &
