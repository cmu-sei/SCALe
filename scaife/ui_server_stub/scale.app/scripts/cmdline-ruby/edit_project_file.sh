#!/bin/bash -f
#
# Edits a project attribute that is a file. Takes project id, attribute
# name, and pathname
#
# Can be called from anywhere.

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
BIN_DIR=$(dirname "$BIN_LOC")
. $BIN_DIR/../env.sh

project_id=$1
attribute=$2
new_path=$3
new_file=`basename $new_path`

set_project_vars $project_id

old_file=`echo "SELECT $attribute FROM projects WHERE id=$project_id" | sqlite3 $INTERNAL_DB`
mkdir -p $PROJECT_SUPPLEMENTAL_DIR
if [ ! -z $old_file ]; then
  rm $PROJECT_SUPPLEMENTAL_DIR/$old_file || true
fi
cp $new_path $PROJECT_SUPPLEMENTAL_DIR
# Update attribute in SCALe db
$BIN_DIR/edit_project.sh $project_id $attribute \"$new_file\"
