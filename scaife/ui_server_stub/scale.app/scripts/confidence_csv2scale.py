#!/usr/bin/env python

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

import argparse
import csv
import sqlite3 as sqlite
from sqlite3 import Error

#Python script that updates a SCALe db from the contents of a confidence csv file.
#SQL UPDATE statements are produced and db is updated accordingly.

cmd_parser = argparse.ArgumentParser(description="Imports contents of a confidence csv file and updates the SCALe database with the output.")
cmd_parser.add_argument("database", help="Database to add confidence values to")
cmd_parser.add_argument("input", help="File containing confidence values")
cmd_parser.add_argument("project_id", help="Project ID to update confidence values")
args = cmd_parser.parse_args()
db = None

def getFileContents():
    csv_contents = []

    try:
        #open the file and read the contents
        with open(args.input, "r") as f:
            csv_reader = csv.DictReader(f)

            #format the contents
            for csv_rows in csv_reader:
                #TO DO: Perform input validation
                confidence = float(csv_rows['Confidence'])
                meta_alert = int(csv_rows['Meta_Alert_ID'])

                if confidence >= 0 and confidence <=100:
                    csv_contents.append([confidence, meta_alert, args.project_id])

            f.close()

    except IOError:
        print("Could not open file: ", args.input)

    try:
        db = sqlite.connect(args.database)
        cursor = db.cursor()

        cursor.executemany('UPDATE displays SET confidence=? WHERE meta_alert_id=? AND project_id=?;', csv_contents)
        db.commit()
    except Error as e:
        print(e)
    finally:
        db.close()

if __name__ == "__main__":
     getFileContents()
