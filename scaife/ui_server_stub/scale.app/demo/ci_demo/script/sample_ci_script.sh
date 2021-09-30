#!/usr/bin/env bash

# The package access token and tool ID were displayed during CI project
# creation in SCALe.

PKG_TOKEN="Paste your SCAIFE package access token here"

TOOL_ID="Paste your SCAIFE tool ID here"

# Set to hostname/ip of your datahub
DATAHUB_HOST="datahub"

SCAIFE_URL="http://$DATAHUB_HOST:8084/analyze"

# $GIT_COMMIT_HASH (revision) should be set to the commit hash which
# triggered the build. This is provided either as the first argument or
# through the environment variable $GIT_COMMIT_HASH made available by the
# CI server.
#
# If no argument is present, or if $GIT_COMMIT_HASH has not already been
# set, default to bamboo CI server from Atlassian.
  
if [ ! -z "$1" ]; then
  # Set from first argument if present.
  GIT_COMMIT_HASH=$1
elif [ -z "$GIT_COMMIT_HASH" ]; then
  # Or, if the $GIT_COMMIT_HASH environment was not already set
  # externally by the CI server, default to the value from the bamboo CI
  # server from Atlassian.
  GIT_COMMIT_HASH="${bamboo.repository.revision.number}"
fi

# The $TOOL_OUTPUT variable should be set to the location of the static
# analysis tool output. (if you're running the demo you can find some
# example outputs in the scale.app/demo/ci_demo/non_ci_demo directory)

TOOL_OUTPUT="rosecheckers.txt"

curl --verbose -X POST ${SCAIFE_URL} -H 'accept: application/json' \
  -H  "x_access_token: $PKG_TOKEN" \
  -H  'Content-Type: multipart/form-data' \
  -F "git_commit_hash=$GIT_COMMIT_HASH" \
  -F "tool_id=$TOOL_ID" \
  -F "tool_output=@$TOOL_OUTPUT;type=text/plain"
