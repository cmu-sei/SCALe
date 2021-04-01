#!/bin/bash

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

BIN_LOC=$(readlink -f "${BASH_SOURCE[0]}")
SCRIPTS_DIR=$(dirname "$BIN_LOC")

SCALE_DIR=$(readlink -f "$SCRIPTS_DIR/..")
if [ -z "$SCALE_HOME" ]; then
  SCALE_HOME=$(readlink -f "$SCALE_DIR/..")
fi

export SCALE_HOME
export SCALE_DIR
export SCRIPTS_DIR

if [ -z "$RAILS_ENV" ]; then
  export RAILS_ENV=development
fi

DB_DIR="$SCALE_DIR/db"
DB_BACKUP_DIR="$SCALE_DIR/$DB_DIR/$RAILS_ENV/backup"
DB_ARCHIVE_DIR="$SCALE_DIR/archive/$RAILS_ENV/backup"

INTERNAL_DB="$DB_DIR/$RAILS_ENV.sqlite3"
EXTERNAL_DB="$DB_DIR/external.sqlite3"

function set_project_vars {
  if [ -z "$1" ]; then
    echo "project id required"
    exit 1
  fi
  PROJECT_BACKUP_DIR="$DB_BACKUP_DIR/$1"
  PROJECT_BACKUP_DB="$PROJECT_BACKUP_DIR/external.sqlite3"
  PROJECT_ARCHIVE_DIR="$DB_ARCHIVE_DIR/$1"
  PROJECT_ARCHIVE_DB="$PROJECT_ARCHIVE_DIR/db.sqlite"
  PROJECT_SUPPLEMENTAL_DIR="$PROJECT_ARCHIVE_DIR/supplemental"
  PROJECT_GNU_DIR="$SCALE_DIR/public/GNU/$1"
}
