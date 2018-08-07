#!/bin/sh
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


SERVERPID=$SCALE_HOME/scale.app/tmp/pids/server.pid
PID=$(cat $SERVERPID)
echo "Killing existing server with pid=$PID"
kill $PID

rm -rf $SCALE_HOME/scale.app/public/GNU/*
rm -rf $SCALE_HOME/scale.app/db/backup 
rm -rf $SCALE_HOME/scale.app/archive
rm $SCALE_HOME/scale.app/db/external.sqlite3 
rm $SCALE_HOME/scale.app/db/development.sqlite3 
bundle exec rake db:migrate
bundle exec thin start --port 8080 --daemonize --pid $SERVERPID
# To use SSH:
# nohup bundle exec thin start --ssl --port $PORT --ssl-cert-file $APP/server.crt --ssl-key-file $APP/server.key --daemonize --pid $SERVERPID &
