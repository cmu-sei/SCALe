#!/bin/sh
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

if [ -z "$RAILS_ENV" ]; then
  RAILS_ENV=development
fi

if [ -z "$E_USECERT" ]; then
    echo "E_USECERT not set, Skipping certificate download."
else
    echo "Downloading certificate from $E_USECERT"
    openssl s_client -showcerts -servername $E_USECERT \
    -connect $E_USECERT:443 </dev/null 2>/dev/null | \
    sed -n -e '/BEGIN\ CERTIFICATE/,/END\ CERTIFICATE/ p' > cert.pem
    cat cert.pem | tee -a /etc/ssl/certs/ca-certificates.crt
    rm cert.pem
fi

echo "Adding bundled gems"
bundle config set path ./vendor/bundle \
    && bundle install --quiet --jobs 8

echo "Adding HTML manual"
./scripts/builddocs.sh

DB="./db/$RAILS_ENV.sqlite3"

if [ -f $DB ]; then
  # don't destroy existing data
  echo "Migrating/seeding database: $DB"
  bundle exec rake db:migrate db:setup
else
  # init new DB
  echo "Initializing/seeding database: $DB"
  bundle exec rake db:migrate  \
    && bundle exec rake db:schema:load \
    && bundle exec rake db:seed
fi

if [ $RAILS_ENV != "test" ]; then
  # init new test DB even when not in test mode, for, tests
  echo "Initializing/seeding database: ./db/test.sqlite3"
  RAILS_ENV=test bundle exec rake db:migrate  \
    && bundle exec rake db:schema:load \
    && bundle exec rake db:seed
fi
