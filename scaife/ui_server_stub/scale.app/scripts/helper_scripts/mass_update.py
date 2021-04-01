#!/usr/bin/env python3

# This script can be used to update a sqlite3 database with determination entries.
# Mass update in the browser takes a long time with large projects so this script
# was created to avoid the lengthy process of mass updates in SCALe. It should be 
# used for test purposes such as quick cascading and updates to SCALe. 

# CAUTION: The script will insert any number of meta-alert adjudications into the DB
# and can be much larger than the number of actual meta alerts in the database, as long as there
# are no UNIQUE Constraint errors. It should only be used for inserting adjudications one time, 
# and only if no previous adjudication of any kind already exists for that meta-alert ID and project_id.
# Currently, this script does not update existing
# Determination values in the database. The determination values are also hardcoded
# below and currently only inserts a True verdict 
# into the Determinations table. To change the other determinations, edit the line
# starting "INSERT INTO" to hardcode determination values.

# Note for using this script with SCALe's running developement.sqlite3:
# - This script only inserts data into the Determination Table. Users will still need to 
# update the Displays table in SCALe to see the changes in the GUI.  

# Usage: mass_update.py <path_to_db_file> <meta-alert_id_to_stop_determinations> [-s meta-alert_id_to_start_determinations][-p <project_id>]

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

import os, argparse, sys, sqlite3, datetime

def update(db, start, stop, project_id): # Default stop will not execute the command.
    conn = None
    
    try:
        with sqlite3.connect(db) as conn:
            cur = conn.cursor()
            
            date_now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            
            cur.execute(""" SELECT COUNT (*) FROM `determinations` """.strip())
            
            (starting_row,) = cur.fetchone()
            
            print(starting_row)
            
            for x in range(start,stop):
                starting_row = starting_row + 1 
                row = [starting_row, project_id, x, date_now]
                
                cur.execute("""
                    INSERT INTO `determinations`(`id`,`project_id`,`meta_alert_id`,`time`,`verdict`,`flag`,`notes`,`ignored`,`dead`,`inapplicable_environment`,`dangerous_construct`) VALUES (?,?,?,?,4,0,0,0,0,0,0)
                """.strip(), row)

    except Exception as e:
        print("ERROR: " + str(e))
    finally:
        if conn:
            conn.close()
    
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="""
    Insert determinations into a database table.
    """)
    parser.add_argument("db", help="DB file to Update")
    parser.add_argument("end", metavar='N', type=int, help="Meta-alert ID to Stop (not inclusive)")
    parser.add_argument("-s", "--start", metavar='N', type=int, help="Meta-alert ID to Start (inclusive). Default: 1")
    parser.add_argument("-p", "--project_id", metavar='N', type=int, help="Project ID to Update. Default: 1")
    
    args = parser.parse_args()
    
    project_id = 1 # Default project ID to update
    start = 1 # Default meta-alert ID to start creating adjudications
    
    if args.project_id:
        project_id = args.project_id
        
    if args.start:
        start = args.start

    if os.path.isfile(args.db) and args.db.endswith("sqlite3"):
        update(args.db, start, args.end, project_id)
    else:
        print("Database file does not exist or is invalid. Must be a sqlite3 file.")
