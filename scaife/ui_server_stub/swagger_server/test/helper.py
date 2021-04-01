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

import os
import sys
import csv
import jwt
import random
import zipfile
import datetime
import json

from flask import current_app as app
from six import BytesIO
from mongoengine import disconnect_all, register_connection
from mongoengine.context_managers import switch_db, switch_collection
from mongoengine.queryset import QuerySet

import swagger_server.database.model as model
from swagger_server import bootstrap

# database aliases
disconnect_all()

STATS_DB_NAME = "stats_test"
DATAHUB_DB_NAME = "datahub_test"

datahub_module = bootstrap.datahub_module(localhost=True)
datahub_svc = datahub_module.service
datahub_db_svc = datahub_module.services_by_name["db_host"]
datahub_url = "http://%s:%s" % (datahub_svc.host, datahub_svc.port)

stats_module = bootstrap.stats_module(localhost=True)
stats_svc = stats_module.service
stats_db_svc = stats_module.services_by_name["db_host"]
stats_url = "http://%s:%s" % (stats_svc.host, stats_svc.port)

register_connection('default', db=STATS_DB_NAME, name=STATS_DB_NAME,
        host=datahub_db_svc.host, port=datahub_db_svc.port)
register_connection('datahub', db=DATAHUB_DB_NAME, name=DATAHUB_DB_NAME,
        host=stats_db_svc.host, port=stats_db_svc.port)

INPUT_DATA_FOLDER = bootstrap.bootstrap_dir.joinpath("test/data")


def get_access_token(author_example, organization_example, module_name):  # get an authentication token
    server_key = module_name.upper() + "_KEY"
    return jwt.encode({"username": author_example[1], "organization_id": organization_example[0],
                       "server_key": app.config[server_key],
                       "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=1)}, app.config["SECRET_KEY"])


def get_request_token(i):
    request_token = str(i)
    while len(request_token) < 3:
        request_token = "0" + request_token
    return request_token


def create_classifier(classifier_id, classifier_type, adaptive_heuristic_id, adaptive_heuristic_name, ahpo_id, ahpo_name):
    ahpo = model.Ahpo()
    ahpo.id = ahpo_id
    ahpo.name = ahpo_name

    adaptive_heuristic = model.AdaptiveHeuristic()
    adaptive_heuristic.id = adaptive_heuristic_id
    adaptive_heuristic.name = adaptive_heuristic_name

    classifier = model.Classifier()
    classifier.switch_db('default')
    classifier.id = classifier_id
    classifier.classifier_type = classifier_type  # e.g., "LightGBM"
    classifier.ahpos = [ahpo]
    classifier.adaptive_heuristics = [adaptive_heuristic]
    classifier.save()


def get_code_languages(): 
    code_languages_versions = []
  
    data_filepath = INPUT_DATA_FOLDER.joinpath("languages.json")
    data = json.load(data_filepath.open())
    
    for lang in data:
        versions = data[lang]["versions"]
        for v in versions:
            code_languages_versions.append((lang, v))
    return code_languages_versions


def get_conditions(data_filepath):
    conditions = []
    f = open(data_filepath, 'r')
    for line in f:
        temp = line.split("|")
        condition_name = temp[1]
        condition_title = temp[2]
        conditions.append((condition_name, condition_title))
    f.close()   
    return conditions


def get_taxonomies_and_conditions(): 
    taxonomies_conditions = {}

    cert_data_filepath = INPUT_DATA_FOLDER.joinpath(
            "conditions/cert_rules.c.v.2016.org")

    cert_conditions = get_conditions(cert_data_filepath)
    taxonomies_conditions["cert"] = cert_conditions

    cert_data_filepath = INPUT_DATA_FOLDER.joinpath(
            "conditions/cwe.all.v.2.11.org")

    cwe_conditions = get_conditions(cert_data_filepath)
    taxonomies_conditions["cwe"] = cwe_conditions
    return taxonomies_conditions
  

def get_tools(): 
    tool_names_versions = []
    tool_names_types = {}
  
    data_filepath = INPUT_DATA_FOLDER.joinpath("tools.json")
    data = json.load(data_filepath.open())
    
    for obj in data:
        tool_name = obj["name"]
        tool_type = obj["type"]
        tool_names_types[tool_name] = tool_type 
        tool_names_versions.append((tool_name, "generic"))
        versions = obj["versions"]
        for v in versions:
            tool_names_versions.append((tool_name, v))
    return tool_names_versions, tool_names_types


def get_codebase_filepath(package_name):
    package_dir = INPUT_DATA_FOLDER.joinpath("packages")
    input_file_path = package_dir.joinpath(package_name)
    return str(input_file_path)


def get_test_suite_filepath(package_name):
    package_dir = INPUT_DATA_FOLDER.joinpath("packages")
    input_file_path = package_dir.joinpath("test_suite_files")
    return str(input_file_path)


def resolve_filepath(tool_name, paths, temp_path):
    file_path = None
    for p in paths:
        if "cppcheck_oss" == tool_name:
            temp_path = temp_path.split("\\")[-1]
        if temp_path in p:
            file_path = p
    if not file_path:
        raise Exception(file_path)
    return file_path


def get_valid_filepaths(directory):
    paths = set()
    idx = len(str(directory))
    for (dirpath, dirnames, filenames) in os.walk(directory):
        for fname in filenames:
            file_path = os.path.join(dirpath, fname)[idx:]
            if file_path.rfind(os.sep) == 0:
                file_path = file_path[len(os.sep):]  # chop off leading /
            paths.add(str(file_path)) 
    return paths


def get_alerts_from_file(source_directory_filepath, tool_output_filepath, code_language_name, code_language_version, tool_id, tool_name, tool_checker_names_ids):
    package_dir = INPUT_DATA_FOLDER.joinpath("packages")
    output_dir = package_dir.joinpath("output")
    with zipfile.ZipFile(source_directory_filepath, "r") as zip_ref:
        zip_ref.extractall(output_dir)

    paths = get_valid_filepaths(output_dir)


    code_language = {"language": code_language_name, "version": code_language_version}

    tsv_reader = csv.reader(tool_output_filepath.open(), delimiter='\t')
    alerts = []
    unknown_checkers = set()
    ui_alert_id = 0
    for fields in tsv_reader:
        ui_alert_id += 1
        if not fields:
            continue 
        checker_name = fields[0].strip()
        if (tool_name, checker_name) not in tool_checker_names_ids:
            unknown_checkers.add(checker_name)
            continue
        checker_id = tool_checker_names_ids[(tool_name, checker_name)]
        primary_message = None
        secondary_messages = []
        msg_index = 1
        while msg_index < len(fields) - 1:
            temp_path = fields[msg_index].strip()   
            path = resolve_filepath(tool_name, paths, temp_path)
            line_number = int(fields[msg_index + 1].strip())
            msg_text = fields[msg_index + 2].strip()
            message_data = {"line_start": line_number, "line_end": line_number, "filepath": path, "message_text": msg_text}
            if 1 == msg_index:
                # Collect the primary message
                primary_message = message_data
            else:
                # Collect the secondary message
                secondary_messages.append(message_data)
            msg_index = msg_index + 3

        alert_object = {}
        alert_object["ui_alert_id"] = str(ui_alert_id)      
        alert_object["code_language"] = code_language
        alert_object["tool_id"] = tool_id
        alert_object["checker_id"] = checker_id
        alert_object["primary_message"] = primary_message
        if (0  == len(secondary_messages)):
            alert_object["secondary_messages"] = secondary_messages
        alerts.append(alert_object)
    for c in unknown_checkers:
        message = "WARNING: checker name " + c + " in tool parser output, but not in .properties file"
        print(message, file=sys.stdout)
    return alerts


def get_alerts(source_directory_filepath, tool_name, package_name, code_language_name, code_language_version, tool_id, tool_checker_names_ids): 
    alerts = {}

    tool_parser_output_dir = INPUT_DATA_FOLDER.joinpath("tool_parser_output")

    for file_name in tool_parser_output_dir.iterdir():
        file_name = str(file_name)
        tool_output_filepath = tool_parser_output_dir.joinpath(file_name)
        if not ((tool_name in file_name) and (package_name in file_name)):
            continue

        alerts = get_alerts_from_file(source_directory_filepath, tool_output_filepath, code_language_name, code_language_version, tool_id, tool_name, tool_checker_names_ids)        
    return alerts     
    

def get_meta_alerts(alert_mappings, ui_id_alert_data, checker_ids_tool_checker_names, tool_checker_names_condition_names, condition_names_ids): 

    temp_meta_alerts = {}
    #raise Exception(alert_mappings)
    all_conditions = set()
    for alert in alert_mappings:
        alert_id = alert["alert_id"]
        ui_alert_id = alert["ui_alert_id"]

        alert_data = ui_id_alert_data[ui_alert_id]
        checker_id = alert_data["checker_id"]
        filepath = alert_data["primary_message"]["filepath"]
        line_number = alert_data["primary_message"]["line_start"]

        # Get condition_id from checker_id
        (tool_name, checker_name) = checker_ids_tool_checker_names[checker_id]
        condition_name = tool_checker_names_condition_names[(tool_name, checker_name)]
        condition_id = condition_names_ids[condition_name]
        
        all_conditions.add(condition_id)
 
        if (filepath, line_number, condition_id) not in temp_meta_alerts:
            temp_meta_alerts[(filepath, line_number, condition_id)] = [alert_id]
        else:
            temp_meta_alerts[(filepath, line_number, condition_id)].append(alert_id)

    meta_alerts = []


    for (filepath, line_number, condition_id), alert_ids in temp_meta_alerts.items():

        random_verdict = random.choice(["True", "False", "Unknown"])

        timestamp_example = datetime.datetime.utcnow().replace(microsecond=0)

        verdict_list = [ {"verdict": random_verdict, "timestamp": timestamp_example} ]

        determination = {"flag_list": [], "inapplicable_environment_list": [], "ignored_list": [], "verdict_list": verdict_list, "dead_list": [], "dangerous_construct_list": [], "notes_list": []}
        m_alert = {"condition_id": condition_id,  "filepath": filepath, "line_number": line_number, "alert_ids": alert_ids, "determination": determination}
        meta_alerts.append(m_alert)
    return meta_alerts


def get_checkers_and_conditions(): 
    tool_name_map = {}

    properties_dir = INPUT_DATA_FOLDER.joinpath("properties")

    for file_name in properties_dir.iterdir():
        filepath = properties_dir.joinpath(file_name)
        tool_name = str(file_name).split(".")[1]
        checkers_conditions = {}
        for line in filepath.open():
            line = line.strip()
            if (0 == len(line)) or ("#" in line):
                continue
            temp = line.split(":")
            checker_name = temp[0].strip()
            condition_name = temp[1].strip()
            checkers_conditions[checker_name] = condition_name
        tool_name_map[tool_name] = checkers_conditions
    return tool_name_map     
     

def standard2camel(name):
    return ''.join([x.capitalize() for x in name.split('_')])


def get_db_model_names(module_name):
    db_model_names = ["alert", "checker", "checker_condition", "checker_mapping", "code_language", "condition", "meta_alert", "package", "performance_metrics", "project", "source_file", "source_function", "taxonomy", "tool"]
    if "stats" == module_name:
        db_model_names = db_model_names + ["classifier_data", "classifier_instance", "classifier", "observation", "classifier_performance_metrics"]
    else:
        db_model_names = db_model_names + ["test_suite"]
    return db_model_names


def delete_generic_objects(model_name, database):  # delete objects from the MongoDB
    model_object = getattr(model, standard2camel(model_name))
    if 'datahub' == database:
        with switch_db(model_object, 'datahub') as datahub_obj:
            objects_to_delete = datahub_obj.objects()
    else:
        objects_to_delete = model_object.objects()

    if objects_to_delete:
        objects_to_delete.delete()


