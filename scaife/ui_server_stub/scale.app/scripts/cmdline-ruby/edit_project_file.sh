#!/bin/sh -f
# Edits a project attribute that is a file. Takes project id, attribute name, and pathname
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
attribute=$2
new_path=$3

prefix=$SCALE_HOME/scale.app/archive/backup/$project_id/supplemental
old_file=`echo "SELECT $attribute FROM projects WHERE id=$project_id" | sqlite3 $SCALE_HOME/scale.app/db/development.sqlite3`
new_file=`basename $new_path`

mkdir -p $prefix
rm $prefix/$old_file || true
cp $new_path $prefix
# Update attribute in SCALe db
$SCALE_HOME/scale.app/bin/edit_project.sh $project_id $attribute \"$new_file\"
