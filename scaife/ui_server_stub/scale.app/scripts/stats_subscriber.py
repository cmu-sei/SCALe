#!/usr/bin/env python

# This script contains code to subscribe to data objects from the Stats Module.
# The topic is a string describing the type of data object that will be received (e.g., classifier_results).
# Publishers must use the same topic string to send data objects of a given type.

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

import os
import pulsar
from pulsar.schema import *
from publish_subscribe_schema import *
from subprocess import *

import bootstrap


Config_Data = bootstrap.scaife_config()
Client = pulsar.Client('pulsar://' + Config_Data['development']['pulsar'])
Classifier_Results_Schema = AvroSchema(ClassifierResults)
Db_File = os.getenv("SCALE_HOME") + "/scale.app/db/development.sqlite3"


def update_db(db_file, msg):
    import sqlite3
    import time
    with sqlite3.connect(db_file) as con:
        cur = con.cursor()
        # The confidence_lock has 4 states:
        # 0 = confidences are up-to-date
        # 1 = this script is busy updating next_confidence
        # 2 = next_confidences are updated, must be xferred
        # 3 = SCALe is busy updating confidence.
        lock = 1
        while lock not in [0, 2]:
            cur.execute("SELECT confidence_lock FROM projects"
                        " WHERE scaife_project_id = ?", [msg.project_id])
            lock = cur.fetchone()[0]
            if lock in [0, 2]:
                break
            time.sleep(2)

        cur.execute("UPDATE projects SET confidence_lock=1"
                    " WHERE scaife_project_id = ?", [msg.project_id])

        # Make this transactional, so SCALe doesn't see partially-filled data
        for prob_datum in msg.probability_data:
            cur.execute("UPDATE displays SET next_confidence = ? "
                        "WHERE scaife_meta_alert_id = ?",
                        [prob_datum.probability, prob_datum.meta_alert_id])

        cur.execute("UPDATE projects SET confidence_lock=2"
                    " WHERE scaife_project_id = ?", [msg.project_id])
        con.commit()


def main():
    consumer = Client.subscribe(
                      topic='classifier_predictions',
                      subscription_name='sample_subscription',
                      schema=Classifier_Results_Schema)

    while True:
        msg = consumer.receive()
        msg_data = msg.value()
        try:
            print("Received a message")
            print("classifier_instance_id={} project_id={} probability_data={}"
                  .format(msg_data.classifier_instance_id,
                          msg_data.project_id,
                          msg_data.probability_data))
            update_db(Db_File, msg_data)

            # Acknowledge successful processing of the message
            consumer.acknowledge(msg)
        except:
            # Message failed to be processed
            consumer.negative_acknowledge(msg)

    consumer.unsubscribe()
    consumer.close()


if __name__ == "__main__":
    main()
