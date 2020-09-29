#!/bin/sh
# This script deletes all 4 tox test databases for SCAIFE, and 3 of the production databases.
# It leaves the Registration server database. Then it removes the previous output files
# from each of the servers, and restarts the 4 SCAIFE servers.
#
# PREREQUISITE: Before running this script, run the following command in a terminal:
#    ps -aux | grep swagger
# Then, kill the 4 processes (process number IDs, shown in results from above command) for the
# 4 SCAIFE servers if they are currently active. For example:
#    kill 17407 17408 17409 17410

# <legal>
# SCAIFE System version 1.2.2
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

# Use statement
if [ ${#@} -ne 0 ] && ([ "${@#"--help"}" = "" ] || [ "${@#"-h"}" = "" ]); then
    printf -- 'This script deletes all 4 tox test databases for SCAIFE, and 3 of the production databases.\n';
    printf -- 'It leaves the Registration server database. Then it removes the previous output files from\n';
    printf -- 'each of the servers, and restarts the 4 SCAIFE servers.\n';
    printf -- '\n';
    printf -- 'Before running this script, the user should have previously identified and killed the 4 (non-SCALe) SCAIFE servers.\n';
    printf -- 'Do that by running the following command in a terminal.\n';
    printf -- '         ps -aux | grep swagger \n';
    printf -- 'Then, kill the 4 processes (process number IDs, shown in results from above command) for the\n';
    printf -- '4 SCAIFE servers if they are currently active. For example:\n';
    printf -- '         kill 17407 17408 17409 17410\n';
  exit 0;
fi;


# Warn user they should have previously identified and killed the 4 (non-SCALe) SCAIFE servers
echo "User should have previously identified and killed the 4 (non-SCALe) SCAIFE servers. Otherwise you'll need to do that, then re-run this script. For more info, use the -h flag to get use information for this script."

# delete 4 tox test DBs
echo "Deleting 4 tox test DBs"
mongo datahub_test --eval "db.dropDatabase()"
mongo stats_test --eval "db.dropDatabase()"
mongo registration_test --eval "db.dropDatabase()"
mongo prioritization_test --eval "db.dropDatabase()"
# delete production DBs
echo "deleting 3 production DBs (leaving production Registration Module DB)"
mongo datahub_db --eval "db.dropDatabase()"
mongo stats_db --eval "db.dropDatabase()"
mongo prioritization_db --eval "db.dropDatabase()"

SCAIFE_DIR=$DH_SERVER/..

# Remove previously-created output files for the 4 modules
echo "Removing the previously-created output files for the 4 modules"
rm $SCAIFE_DIR/out_*.txt

# Start the 4 (non-SCALe) SCAIFE servers
echo "Starting the 4 (non-SCALe) SCAIFE servers"
cd $DH_SERVER
python3 -m swagger_server > $SCAIFE_DIR/out_dh.txt &
cd $SCAIFE_DIR/priority_server_stub
python3 -m swagger_server > $SCAIFE_DIR/out_priority.txt &
cd $SCAIFE_DIR/registration_server_stub
python3 -m swagger_server > $SCAIFE_DIR/out_reg.txt &
cd $SCAIFE_DIR/stats_server_stub
python3 -m swagger_server > $SCAIFE_DIR/out_stats.txt &
