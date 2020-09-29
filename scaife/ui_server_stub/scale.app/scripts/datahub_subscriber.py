#!/usr/bin/env python3

# This script contains code to subscribe to data objects from the DataHub.
# The topic is a string describing the type of data object that will be received (e.g., project_id).  
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
import atexit
import pulsar
import random
import requests
import argparse
import bootstrap
from pulsar.schema import AvroSchema
from publish_subscribe_schema import *
from multiprocessing import Process, Queue

  
config_data = bootstrap.scaife_config()
pulsar_url = config_data['development']['pulsar']
client = pulsar.Client('pulsar://' + pulsar_url)

new_determinations_schema = AvroSchema(SendAlertVerdictUpdateParams)


def get_admin_url():
    i = pulsar_url.index(':')
    
    admin_url = pulsar_url[:i] + ':' + '8080'    
    return admin_url     
      
      
def delete_topics():
    # Delete topics that do not have active consumers or producers

    get_topics_url = 'http://' + get_admin_url() + '/admin/v2/namespaces/public/default/topics'
    
    topic_list = requests.get(get_topics_url).json()
    
    for x in topic_list:
        x = x.replace('://', '/')
        requests.delete('http://localhost:8080/admin/v2/' + x)     


def create_consumer(topic_name, subscription_name):
    
    try:
        consumer = client.subscribe(
                topic=topic_name,
                subscription_name=subscription_name,
                schema=new_determinations_schema)
    except: # Consumer with this subscription exists or has been used before
        suffix = str(random.randrange(100000))
        consumer = client.subscribe(
                topic=topic_name,
                subscription_name=subscription_name + suffix,
                schema=new_determinations_schema)
        
    
    return consumer


def pass_messages(consumer, q):
    # this is the child process
    while True:
        msg = consumer.receive()
        msg_data = msg.value()
        try:
            # Print Statement available for visual testing
            print("Child Process Received a Message")
            print("project_id={} meta_alert_id={} determination={}".format(msg_data.project_id, msg_data.meta_alert_id, msg_data.determination))
            
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


def start_subscription(topic_name, subscription_name):
    
    consumer = create_consumer(topic_name, subscription_name)
    messages(consumer)
    
    try:
        for msg in messages(consumer):
            # TODO: Do something with the message
            # Print Statement available for visual testing
            print("Parent Process Received a Message")
            print("project_id={} meta_alert_id={} determination={}".format(msg.project_id, msg.meta_alert_id, msg.determination))
            
            pass
    finally:
        consumer.unsubscribe()
        consumer.close()


if __name__ == "__main__":
    cmd_parser = argparse.ArgumentParser(description="Subscribe to Data Updates from the Datahub")
    cmd_parser.add_argument("topic_name", help="Name of the Topic to Subscribe to")
    cmd_parser.add_argument("subscription_name", help="Name of the subscription string")
    args = cmd_parser.parse_args()

    delete_topics() # Clean up any topics that do not have any consumers or producers open
    start_subscription(args.topic_name, args.subscription_name)
