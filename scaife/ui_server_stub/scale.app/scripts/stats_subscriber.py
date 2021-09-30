#!/usr/bin/env python3

# This script contains code to subscribe to data objects from the Stats Module.
# The topic is a string describing the type of data object that will be received (e.g., classifier_results).
# Publishers must use the same topic string to send data objects of a given type.

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

import os
import atexit
import random
import pulsar
from pulsar.schema import AvroSchema
from publish_subscribe_schema import *
from multiprocessing import Process, Queue

import bootstrap


config_data = bootstrap.scaife_config()
pulsar_url = config_data["pulsar"]
client = pulsar.Client('pulsar://' + pulsar_url)

classifier_results_schema = AvroSchema(ClassifierResults)

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
            cur.execute("UPDATE displays SET next_confidence = ?, class_label = ?"
                        "WHERE scaife_meta_alert_id = ?",
                        [prob_datum.probability, prob_datum.label, prob_datum.meta_alert_id])

        cur.execute("UPDATE projects SET confidence_lock=2"
                    " WHERE scaife_project_id = ?", [msg.project_id])
        con.commit()

def create_consumer(topic_name, subscription_name):
    try:
        consumer = client.subscribe(
                topic=topic_name,
                subscription_name=subscription_name,
                schema=classifier_results_schema)
    except:
        suffix = str(random.randrange(100000))
        consumer = client.subscribe(
                topic=topic_name,
                subscription_name=subscription_name + suffix,
                schema=classifier_results_schema)
    return consumer

def pass_messages(consumer, q):
    # this is the child process
    while True:
        msg = consumer.receive()
        msg_data = msg.value()
        if msg_data.probability_data:
            # since pulsar.schema doesn't support Arrays of Records
            msg_data.probability_data = \
                [ProbabilityData(**x) for x in msg_data.probability_data]
        try:
            # Print Statement available for visual testing
            print("Child Process Received a Message")
            print("classifier_instance_id={} project_id={} probability_data={}"
                  .format(msg_data.classifier_instance_id,
                          msg_data.project_id,
                          msg_data.probability_data))

            # Acknowledge successful processing of the message
            consumer.acknowledge(msg)
        except:
            # Message failed to be processed
            print("Child Process DID NOT Received a Message")
            consumer.negative_acknowledge(msg)
        # we could try passing the msg object itself if we want
        q.put(msg_data)

def messages(consumer):
    q = Queue()
    p = Process(target=pass_messages, args=(consumer, q))
    p.start()
    def _reap_child():
        if p.is_alive():
            print("Terminating Spawned Process")
            p.terminate()
    atexit.register(_reap_child)

    try:
        while True:
            msg = q.get()
            print("Parent Got Message Data: %s" % msg)
            yield msg
    finally:
        # could pass a timeout value
        p.join()

def main():
    consumer = create_consumer("classifier_predictions", "sample_subscription")
    try:
        for msg in messages(consumer):
            # TODO: Do something with the message
            # Print Statement available for visual testing
            print("Parent Process Received a Message")
            print("classifier_instance_id={} project_id={} probability_data={}"
                  .format(msg.classifier_instance_id,
                          msg.project_id,
                          msg.probability_data))
            update_db(bootstrap.internal_db, msg)

    finally:
        consumer.unsubscribe()
        consumer.close()


if __name__ == "__main__":
    main()
