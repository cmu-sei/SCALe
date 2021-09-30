#!/bin/sh
# Script to run integration test on SCAIFE
# Takes a bamboo branch argument
# Fills test-output directory with test results
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

export SERVER="integration"

/usr/local/bin/docker-compose \
    -f docker-compose.yml \
    up -d datahub stats registration ${SERVER} || { echo "ERROR - docker-compose up command failed." ; exit 1 ; }

docker exec ${SERVER} ./wait_for_services.py -vv -e priority

echo "Starting tests..."
# FIXME: Once the remaining tests are fixed, then tox can be called with no args
docker exec ${SERVER} tox \
       swagger_server/test/test_ui_to_datahub_and_stats.py:TestUI.test_1_create_languages \
       swagger_server/test/test_ui_to_datahub_and_stats.py:TestUI.test_2_create_taxonomies \
       swagger_server/test/test_ui_to_datahub_and_stats.py:TestUI.test_3_upload_tools \
       swagger_server/test/test_ui_to_datahub_and_stats.py:TestUI.test_4_get_tool_data \
       swagger_server/test/test_ui_to_datahub_and_stats.py:TestUI.test_5_create_rosecheckers_dos2unix_package_and_project \
       swagger_server/test/test_ui_to_datahub_and_stats.py:TestUI.test_7_create_cppcheck_microjuliet_package_and_project

docker cp helpers ${SERVER}:/usr/src/app || { echo "ERROR - docker-compose cp command failed." ; exit 1 ; }
docker exec ${SERVER} python3 helpers/xmlFileAddDataAndFormat.py nosetests.xml junit.nosetests.xml || { echo "ERROR - docker-compose exec ${SERVER} python command failed." ; exit 1 ; }
docker cp ${SERVER}:/usr/src/app/junit.nosetests.xml  . || { echo "ERROR - docker-compose cp command failed." ; exit 1 ; }

exit 0
