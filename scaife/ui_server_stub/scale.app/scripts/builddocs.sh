#!/bin/sh
# Script to take the markdown in doc and convert it into .html in public
# This script assumes that pandoc > v2.6 is installed on the current machine:
#    http://pandoc.org/installing.html
#
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

# Get the script location
SCRIPT_LOC=$(readlink -f "$0")
SCRIPT_PATH=$(dirname "$SCRIPT_LOC")

if [ ! -d $SCRIPT_PATH ]; then
    echo "Unable to find script execution directory."
    exit 1
fi

# Locations
SRC_DIR=$SCRIPT_PATH/../doc
DEST_DIR=$SCRIPT_PATH/../public/doc/scale2
ATTACHMENTS_DIR=$SRC_DIR/attachments
CONTROL_DIR=$SRC_DIR/control
IMAGES_DIR=$SRC_DIR/images
STYLES_DIR=$SRC_DIR/styles
# STYLES_FILE gets injected into html so relative to documentation root
STYLES_FILE=styles/styles.css
TEMPLATE_FILE=$CONTROL_DIR/html.template
LUA_FILE=$CONTROL_DIR/md-to-html.lua
BUILD_CMD="pandoc"

if ! type $BUILD_CMD > /dev/null; then
    echo "Documentation build requires pandoc 2.6 or higher.  http://pandoc.org/installing.html"
    exit 1
fi

# Cleanup directory if exists...
if [ -d $DEST_DIR ]; then
    echo "Destination exists, removing before build."
    rm -r $DEST_DIR
fi

# attachments, images, and styles go as is
mkdir -p $DEST_DIR

cp -R $ATTACHMENTS_DIR $DEST_DIR
cp -R $IMAGES_DIR $DEST_DIR
cp -R $STYLES_DIR $DEST_DIR

for f in $SRC_DIR/*.md; do
 SRC_NAME=$f
 TMP_NAME=$(basename "$f")
 DEST_NAME="${DEST_DIR}/${TMP_NAME%.*}.html"

 echo "Converting $SRC_NAME to $DEST_NAME"
 eval "$BUILD_CMD -c $STYLES_FILE --template=$TEMPLATE_FILE -f markdown $SRC_NAME -o $DEST_NAME --lua-filter=$LUA_FILE"
 done
