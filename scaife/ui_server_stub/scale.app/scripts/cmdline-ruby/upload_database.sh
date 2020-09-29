#!/bin/sh -f
# Uploads a project database to the SCALe web app, given the project
# ID and database file, which could have been produced by create_database.py

# Can be called from anywhere, but requires SCALE_HOME to be defined
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

project_id=$1
database=$2

cp  $database  $SCALE_HOME/scale.app/db/external.sqlite3
rm -rf $SCALE_HOME/scale.app/archive/backup/$project_id
mkdir -p $SCALE_HOME/scale.app/archive/backup/$project_id
cp  $SCALE_HOME/scale.app/db/external.sqlite3  $SCALE_HOME/scale.app/archive/backup/$project_id/db.sqlite

echo "
  ac = ApplicationController.new
  ac.import_to_displays($project_id)
  new_project.save
  Display.createLinks($project_id)
" | bundle exec rails console

# Be warned that the `import_to_displays` command will return an error like this:
# Module::DelegationError (ActionController::Metal#session delegated to @_request.session, but @_request is nil: #<ApplicationController:0x0000558d49462e78 @_action_has_layout=true, @_routes=nil, @_request=nil, @_response=nil>)
# This error can be ignored

rm -rf $SCALE_HOME/scale.app/db/backup/$project_id
mkdir -p $SCALE_HOME/scale.app/db/backup/$project_id
cp  $SCALE_HOME/scale.app/db/external.sqlite3  $SCALE_HOME/scale.app/db/backup/$project_id/external.sqlite3
echo "The $database database was successfully uploaded!"
