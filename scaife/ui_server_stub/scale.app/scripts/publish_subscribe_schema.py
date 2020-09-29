#!/usr/bin/env python

# Data schema used by code to subscribe to SCAIFE data updates

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

from pulsar.schema import *


class Flag(Record):
    flag = String()
    timestamp = String()


class Verdict(Record):
    verdict = String()
    timestamp = String()


class Ignored(Record):
    ignored = String()
    timestamp = String()


class Dead(Record):
    dead = String()
    timestamp = String()


class InapplicableEnvironment(Record):
    inapplicable_environment = String()
    timestamp = String()


class DangerousConstruct(Record):
    dangerous_construct = String()
    timestamp = String()


class Notes(Record):
    notes = String()
    timestamp = String()


class Determination(Record):
    flag_list = Array(Flag())
    verdict_list = Array(Verdict())
    ignored_list = Array(Ignored())
    dead_list = Array(Dead())
    inapplicable_environment_list = Array(InapplicableEnvironment())
    dangerous_construct_list = Array(DangerousConstruct())
    notes_list = Array(Notes())


class SendAlertVerdictUpdateParams(Record):
    project_id = String()
    meta_alert_id = String()
    determination = Determination()


class ProbabilityData(Record):
    meta_alert_id = String()
    probability = String()


class ClassifierResults(Record):
    classifier_instance_id = String()
    project_id = String()
    probability_data = Array(ProbabilityData())

