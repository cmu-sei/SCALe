#!/usr/bin/env python

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

import argparse
import csv
import os
import random
import sqlite3 as sqlite
from sqlite3 import Error

#Python script that generates a confidence csv file to be used based on the meta_alerts present in the database.

cmd_parser = argparse.ArgumentParser(description="Create a confidence csv file based on the meta_alerts in the DB.")
cmd_parser.add_argument("database", help="Database to get meta_alerts from")
cmd_parser.add_argument("output", help="File containing confidence values")
cmd_parser.add_argument("project_id", help="Project ID to update confidence values")
args = cmd_parser.parse_args()
db = None

def createConfidence():
    try:
        db = sqlite.connect(args.database)
        connection = db.cursor()

        meta_alerts = connection.execute('SELECT meta_alert_id FROM displays WHERE project_id=?', (args.project_id,))
        db.commit()

        if not os.path.exists(os.path.dirname(args.output)):
            try:
                os.makedir(os.path.dirname(args.output))
            except OSError:
                print("Could not create file")

        try:
            with open(args.output, "w") as f:
                csv_writer = csv.writer(f, delimiter=",")
                csv_writer.writerow(["Meta_Alert_ID", "Confidence"])

                for alert in meta_alerts:
                    random_number = round(random.uniform(0, 100), 2)
                    csv_writer.writerow([alert[0], random_number])

                f.close()
        except IOError:
            print("Could not open file: ", args.output)

    except Error as e:
        print(e)
    finally:
        db.close()


if __name__ == "__main__":
    createConfidence()
