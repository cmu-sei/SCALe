# coding: utf-8
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

from __future__ import absolute_import

import os, sys
from flask import json
from six import BytesIO
import requests

from swagger_server.models.error import Error  # noqa: E501
from swagger_server.models.request_token import RequestToken  # noqa: E501
from swagger_server.test import BaseTestCase

import swagger_server.test.helper as helper


author_organization_example = ["111111111111222222222222", "Software Engineering Institute"]  # id, name
author_organization_example2 = ["111111111111333333333333", "Carnegie Mellon University"]

author_example1 = ["111111111111444444444444", "user1", "password1"]  # id, username, password
author_example2 = ["111111111111555555555555", "user2", "password2"]

request_index = 0  # used to validate the request_id sent

datahub_url = helper.datahub_url
stats_url = helper.stats_url

INPUT_DATA_FOLDER = "/swagger_server/test/data/"
TAXONOMY_IDS = {} # maps taxonomy_name, taxonomy_version tuples to SCAIFE taxonomy object IDs
CODE_LANGUAGES_IDS = {} # maps language_name, lanuage_version tuples to SCAIFE language object IDs
TOOLS_IDS = {} # maps tool_name, tool_version tuples to SCAIFE tool object IDs
TOOL_CHECKER_NAMES_CONDITION_NAMES = {} # maps tool name, checker name tuples to condition names
CONDITION_NAMES_IDS = {} # maps condition names to SCAIFE checker IDs
TOOL_CHECKER_NAMES_IDS = {} # maps tool name, checker name tuples to SCAIFE checker IDs
CHECKER_IDS_TOOL_CHECKER_NAMES = {} # maps SCAIFE checker IDs to tool name, checker_name tuples
PACKAGE_NAMES_IDS = {} # maps package names to SCAIFE package IDs
PROJECT_NAMES_IDS = {} # maps project names to SCAIFE project IDs
CLASSIFIER_TYPES_IDS = {} # maps classifier types to SCAIFE classifier IDs
CLASSIFIER_INSTANCE_IDS = []
#TODO: Update ahpo_id and adaptive_heuristic_id in RC-1064
#AHPOS = set()
#ADAPTIVE_HEURISTICS = set()
 
classifier_ids_example = ["141414141414141414141414", "151515151515151515151515", "161616161616161616161616"]
classifier_types_example = ["LightGBM", "Random Forest", "XGBoost"]
classifier_instance_names_example = ["Sample classifier instance name 1", "Sample classifier instance name 2", "Sample classifier instance name 3", "Sample classifier instance name 4"]

ahpo_id_example = "171717171717171717171717"
ahpo_names_example = ["Bayesian Optimization", "None"]
adaptive_heuristic_ids_example = ["181818181818181818181818", "191919191919191919191919", "202020202020202020202020"]
adaptive_heuristic_names_example = ["Similarities", "K-Nearest Neighbors", "Label Propagation", "None"]


class TestUI(BaseTestCase):
    """UI integration test stubs"""

    @classmethod
    def setup_class(self):
        for i in range(0, len(classifier_types_example)):
            helper.create_classifier(classifier_ids_example[i], classifier_types_example[i],
                                 adaptive_heuristic_ids_example[i], adaptive_heuristic_names_example[i], ahpo_id_example, ahpo_names_example[0])


    @classmethod
    def teardown_class(self):
        datahub_model_names = helper.get_db_model_names("datahub")
        stats_model_names = helper.get_db_model_names("stats")

        for name in datahub_model_names:
            helper.delete_generic_objects(name, "datahub")

        for name in stats_model_names:
            helper.delete_generic_objects(name, "stats")

 
    def test_1_create_languages(self):

        datahub_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "datahub")}

        create_language_request_url = datahub_url + "/languages"

        code_languages_versions = helper.get_code_languages()

        i = 0
        for (lang_name, lang_version) in code_languages_versions:         
            code_language = {}
            code_language["language"] = lang_name
            code_language["version"] = lang_version
            i += 1

            datahub_response = requests.post(
                create_language_request_url,
                data=json.dumps(code_language),
                headers=datahub_headers)
            self.assert200(datahub_response, "Response body is : " + datahub_response.text)

            response = datahub_response.json()
            language_id = response["code_language_id"]
            language_name = response["language"]
            language_version = response.get("version")
            CODE_LANGUAGES_IDS[(language_name, language_version)] = language_id
  

    def test_2_create_taxonomies(self):

        datahub_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "datahub")}

        taxonomy_request_url = datahub_url + "/taxonomies"

        # TODO: Expand to include multiple code language ids per condition.  Right now, just include C version 89.
        code_language_ids = [ CODE_LANGUAGES_IDS[("C", "89")] ]

        taxonomies_conditions = helper.get_taxonomies_and_conditions()

        i = 0
        taxonomy_version = "generic"
        for taxonomy_name, condition_tuples in taxonomies_conditions.items():
            conditions = []
            for (condition_name, condition_title) in condition_tuples:
                c = {"code_language_ids": code_language_ids, "condition_name": condition_name, "title": condition_title}
                conditions.append(c)
                
            taxonomy = {}
            taxonomy["taxonomy_name"] = taxonomy_name
            taxonomy["taxonomy_version"] = taxonomy_version
            taxonomy["description"] = "Sample " + taxonomy_name + " taxonomy description"
            taxonomy["conditions"] = conditions
            taxonomy["author_source"] = "Unknown author"

            i += 1         
            datahub_response = requests.post(
                taxonomy_request_url,
                data=json.dumps(taxonomy),
                headers=datahub_headers)
            self.assert200(datahub_response, "Response body is : " + datahub_response.text)

            response = datahub_response.json()
            taxonomy_id = response["taxonomy_id"]   
            TAXONOMY_IDS[(taxonomy_name, taxonomy_version)] = taxonomy_id
            if "conditions" not in response:
                raise Exception("Required Condition objects weren't sent by the DataHub")

            for c in response.get("conditions", []):
                condition_id = c["condition_id"]
                condition_name = c["condition_name"]
                CONDITION_NAMES_IDS[condition_name] = condition_id

   
    def test_3_upload_tools(self):

        datahub_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "datahub")}

        upload_tool_request_url = datahub_url + "/tools"

        # TODO: Expand to include multiple code language ids per condition.  Right now, just include C version 89.
        code_language_ids = [ CODE_LANGUAGES_IDS[("C", "89")] ]

        tools, tool_names_types = helper.get_tools()
        tool_names_checkers_conditions = helper.get_checkers_and_conditions()
        code_metrics_headers = {}

        i = 0
        for tool_name, tool_version in tools:
            checker_mappings = []
            checker_names = []  
            tool_category = None
            if tool_name in tool_names_checkers_conditions:
                checkers_conditions = tool_names_checkers_conditions[tool_name]
                for checker_name, condition_name in checkers_conditions.items():
                    TOOL_CHECKER_NAMES_CONDITION_NAMES[(tool_name, checker_name)] = condition_name
                checker_names = list(checkers_conditions.keys())
 
            tool_category = tool_names_types[tool_name]
            
            tool_info = {}
            tool_info["tool_name"] = tool_name
            tool_info["tool_version"] = tool_version
            tool_info["category"] = tool_category
            tool_info["author_source"] = "Unknown author"
            if len(code_language_ids) > 0:
                tool_info["code_language_ids"] = code_language_ids
            if len(checker_mappings) > 0:
                tool_info["checker_mappings"] = checker_mappings
            if len(checker_names) > 0:
                tool_info["checkers"] = checker_names
            if len(code_metrics_headers) > 0:
                tool_info["code_metrics_headers"] = code_metrics_headers

            i += 1         
            datahub_response = requests.post(
                upload_tool_request_url,
                data=json.dumps(tool_info),
                headers=datahub_headers)
            self.assert200(datahub_response, "Response body is : " + datahub_response.text)

            response = datahub_response.json()

            tool_id = response["tool_id"]
            tool_name = response["tool_name"]
            tool_version = response["tool_version"]
            TOOLS_IDS[(tool_name, tool_version)] = tool_id


    def test_4_get_tool_data(self):

        datahub_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "datahub")}

        i = 0
        for (tool_name, tool_version), tool_id in TOOLS_IDS.items():  
            get_tool_data_request_url = datahub_url + "/tools/" + tool_id
            i += 1

            datahub_response = requests.get(
                get_tool_data_request_url,
                headers=datahub_headers)
            self.assert200(datahub_response, "Response body is : " + datahub_response.text)

            response = datahub_response.json()

            if not (tool_id == response["tool_id"]):
                raise Exception("Received data for unexpected tool")

            if "source_mappings" in response:
                for source_mappings in response["source_mappings"]:
                    for checker in source_mappings["checker_mappings"]:
                        checker_id = checker["checker_id"]
                        checker_name = checker["checker_name"]
                        TOOL_CHECKER_NAMES_IDS[(tool_name, checker_name)] = checker_id
                        CHECKER_IDS_TOOL_CHECKER_NAMES[checker_id] = (tool_name, checker_name)

        if(0 == len(CHECKER_IDS_TOOL_CHECKER_NAMES)):
            raise Exception("DataHub didn't send checker information")


    def test_5_create_rosecheckers_dos2unix_package_and_project(self):

        package_name = "dos2unix"
        source_directory = "dos2unix-7.2.2.zip"
        source_directory_filepath = helper.get_codebase_filepath(source_directory)


        # Make API call to create_package
        datahub_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "datahub")}

        author_source = "Unknown author"
        code_source_url = None
        source_file_url = None
        source_function_url = None
        test_suite_id = None

        #TODO Resolve how tools can be associated with more than one code language in SCALe, but alerts can only be associated with a single code language
        code_language_name = "C"
        code_language_version = "89"
        code_language = dict(
            language = code_language_name,
            version = code_language_version,
        )

        # TODO: Expand to include multiple code language ids per condition.  Right now, just include C version 89.
        code_language_ids = [ CODE_LANGUAGES_IDS[(code_language_name, code_language_version)] ]

        tool_name = "rosecheckers_oss"
        tool_id = TOOLS_IDS[(tool_name, "generic")]
        tool_ids = [tool_id]

        rosecheckers_alerts = helper.get_alerts(source_directory_filepath, tool_name, package_name, code_language_name, code_language_version, tool_id, TOOL_CHECKER_NAMES_IDS)

        ui_id_alert_data = {}
        for a in rosecheckers_alerts:
            alert_data = dict(
                ui_alert_id = a["ui_alert_id"],
                checker_id = a["checker_id"],
                primary_message=a["primary_message"],
                code_language = code_language,
                tool_id = tool_id,
                # TODO: Replace fields mistakenly removed with RC-1559 in RC-1712
                #filepath = a["primary_message"]["filepath"],
                #line_start = int(a["primary_message"]["line_start"]),
            )
            ui_id_alert_data[a["ui_alert_id"]] = alert_data

        package = {}
        package["package_name"] = package_name
        package["package_description"] = "Sample package description for " + package_name
        package["code_language_ids"] = code_language_ids
        if author_source:
            package["author_source"] = author_source
        if code_source_url:
            package["code_source_url"] = code_source_url
        if source_file_url:
            package["source_file_url"] = source_file_url
        if source_function_url:
            package["source_function_url"] = source_file_url
        if test_suite_id:
            package["test_suite_id"] = test_suite_id    
        if rosecheckers_alerts:
            package["alerts"] = rosecheckers_alerts   
        if tool_ids:
            package["tool_ids"] = tool_ids  
        if ui_id_alert_data:
            package["alerts"] = list(ui_id_alert_data.values())

        create_package_request_url = datahub_url + "/packages"
        datahub_response = requests.post(
            create_package_request_url,
            data=json.dumps(package),
            headers=datahub_headers)
        self.assert200(datahub_response, "Response body is %s : " + datahub_response.text)

        response = datahub_response.json()

        PACKAGE_NAMES_IDS[package_name] = response["package_id"]

        alert_mappings = response["alert_mappings"]
        rosecheckers_meta_alerts = helper.get_meta_alerts(alert_mappings, ui_id_alert_data, CHECKER_IDS_TOOL_CHECKER_NAMES, TOOL_CHECKER_NAMES_CONDITION_NAMES, CONDITION_NAMES_IDS)

        if 0 == len(rosecheckers_meta_alerts):
            raise Exception("Test helper failed to retrieve meta-alerts")

        # Make API call to upload_codebase_for_package
        datahub_headers = {'x_access_token': helper.get_access_token(author_example1, author_organization_example, "datahub")}

        multipart_form_data = {
            'sourcecode_archive': ("dos2unix-7.2.2.zip", open(source_directory_filepath, 'rb'))
        }

        package_id = PACKAGE_NAMES_IDS[package_name]
 
        upload_codebase_request_url = datahub_url + "/packages/" + package_id
        datahub_response = requests.post(
            upload_codebase_request_url,
            files=multipart_form_data,
            headers=datahub_headers)
        self.assert200(datahub_response, "Response body is : " + datahub_response.text)

        response = datahub_response.json()

        # Make API call to create_project
        datahub_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "datahub")}

        project_name = package_name
        project_description = "Sample package description for " + project_name
        author_source = "Unknown author"
        package_id = PACKAGE_NAMES_IDS[package_name]
        taxonomy_ids = list(TAXONOMY_IDS.values())

        project = {}
        project["project_name"] = project_name
        project["project_description"] = project_description
        project["package_id"] = package_id
        if author_source:
            project["author_source"] = author_source
        if len(rosecheckers_meta_alerts) > 0:
            project["meta_alerts"] = rosecheckers_meta_alerts
        if len(taxonomy_ids) > 0:
            project["taxonomy_ids"] = taxonomy_ids

        create_project_request_url = datahub_url + "/projects"
        datahub_response = requests.post(
            create_project_request_url,
            data=json.dumps(project),
            headers=datahub_headers)
        self.assert200(datahub_response, "Response body is : " + datahub_response.text)

        response = datahub_response.json()

        PROJECT_NAMES_IDS[package_name] = response["project_id"]
        meta_alert_mappings = response["meta_alert_mappings"]

        if 238 != len(meta_alert_mappings):
            raise Exception("Unexpected number of meta-alerts uploaded to the DataHub")


    def test_6_create_and_run_rosecheckers_dos2unix_classifier(self):

        # Make API call to list_classifiers
        stats_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "stats")}
              
        classifiers_request_url = stats_url + "/classifiers"
        stats_headers["x_request_token"] = helper.get_request_token(0)
        stats_response = requests.get(
            classifiers_request_url,
            headers=stats_headers)
        self.assert200(stats_response, "Response body is : " + stats_response.text)

        classifer_objects = stats_response.json()

        if not len(classifer_objects) >= 3:
            raise Exception("Unexpected number of classifiers retrieved from the Stats Module")

        for classifier in classifer_objects:
            classifier_id = classifier["classifier_id"]
            classifier_type = classifier["classifier_type"]
            CLASSIFIER_TYPES_IDS[classifier_type] = classifier_id
            #[AHPOS.add(x["name"]) for x classifier["ahpos"] ]
            #[ADAPTIVE_HEURISTICS.add(x["name"]) for x classifier["adaptive_heuristics"] ]


        c_type = "Random Forest"
        c_id = CLASSIFIER_TYPES_IDS[classifier_type]
        classifier_instance_name = "test"
        package_name = "dos2unix"
        project_ids = [ PROJECT_NAMES_IDS[package_name] ]
        ahpo_name = "Bayesian Optimization"
        adaptive_heuristic_name = "Similarities"

        #TODO: Update ahpo_id and adaptive_heuristic_id in RC-1064
        classifier_data = {
            "classifier_id": c_id,
            "classifier_type": c_type,
            "classifier_instance_name": classifier_instance_name,
            "project_ids": project_ids,
            "feature_selection_category": "intersection",
            "ahpo_id": "Sample AHPO ID",
            "ahpo_name": ahpo_name,
            "ahpo_parameters": {},
            "adaptive_heuristic_id": "Sample AH ID",
            "adaptive_heuristic_name": adaptive_heuristic_name,
            "adaptive_heuristic_parameters": {}
        }

        # Make API call to create_classifier_instance
        stats_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "stats")}
              
        classifiers_request_url = stats_url + "/classifiers"
        stats_headers["x_request_token"] = helper.get_request_token(0)
        stats_response = requests.post(
            classifiers_request_url,
            data=json.dumps(classifier_data),
            headers=stats_headers)
        self.assert200(stats_response, "Response body is : " + stats_response.text)

        response = stats_response.json()

        classifier_instance_id = response["classifier_instance_id"]
        project_id = response["project_id"]
        CLASSIFIER_INSTANCE_IDS.append((classifier_instance_id, project_id))
     
        # Make API call to run_classifier_instance
        stats_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "stats")}
              
        run_classifier_request_url = stats_url + "/classifiers/" + classifier_instance_id + "/projects/" + project_id

        stats_headers["x_request_token"] = helper.get_request_token(0)
        stats_response = requests.put(
            run_classifier_request_url,
            headers=stats_headers)
        self.assert200(stats_response, "Response body is : " + stats_response.text)

        response = stats_response.json()

        probability_data = response["probability_data"]
        for obj in probability_data:
            confidence_value = float(obj["probability"])
            if not confidence_value > 0:
                raise Exception("Stats Module failed to send confidence values")  


    def test_7_create_cppcheck_microjuliet_package_and_project(self):

        package_name = "microjuliet"
        source_directory = "micro_juliet_v1-2_for_C_Cpp_cppcheck.zip"
        source_directory_filepath = helper.get_codebase_filepath(source_directory)

        #TODO RC-1710 -- Resolve how tools can be associated with more than one code language in SCALe, but alerts can only be associated with a single code language
        code_language_name = "C"
        code_language_version = "89"
        code_language = {"language": code_language_name, "version": code_language_version}

        # Make API call to create_test_suite

        datahub_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "datahub")}

        test_suite = {}
        test_suite["test_suite_name"] = "micro_juliet_test"
        test_suite["test_suite_version"] = "1.0"
        test_suite["test_suite_type"] = "juliet"
        test_suite["manifest_urls"] = []
        test_suite["use_license_file_url"] = ""
        test_suite["author_source"] = "author"
        test_suite["code_languages"] = [code_language]

        create_test_suite_request_url = datahub_url + "/test_suites"
        datahub_headers["x_request_token"] = helper.get_request_token(0)
        datahub_response = requests.post(create_test_suite_request_url, data=json.dumps(test_suite), headers=datahub_headers)
        status_code = datahub_response.status_code
        response = datahub_response.json()
        if 200 != status_code and 422 != status_code:
            raise Exception(response)

        
        # Make API call to create_package

        author_source = "Unknown author"
        code_source_url = None
        source_file_url = None
        source_function_url = None
        test_suite_id = response["test_suite_id"]

        # TODO in RC-1342: Expand to include multiple code language ids per condition.  Right now, just include C version 89.
        code_language_ids = [ CODE_LANGUAGES_IDS[(code_language_name, code_language_version)] ]

        tool_name = "cppcheck_oss"
        tool_id = TOOLS_IDS[(tool_name, "1.83")]
        tool_ids = [tool_id, TOOLS_IDS[(tool_name, "1.00")], TOOLS_IDS[(tool_name, "1.66")], TOOLS_IDS[(tool_name, "1.86")], TOOLS_IDS[(tool_name, "generic")]]

        cppcheck_alerts = helper.get_alerts(source_directory_filepath, tool_name, package_name, code_language_name, code_language_version, tool_id, TOOL_CHECKER_NAMES_IDS)

        #raise Exception(tool_id)

        ui_id_alert_data = {}
        for a in cppcheck_alerts:
            alert_data = dict(
                ui_alert_id = a["ui_alert_id"],
                checker_id = a["checker_id"],
                primary_message=a["primary_message"],
                code_language = code_language,
                tool_id = tool_id,
                filepath = a["primary_message"]["filepath"],
                line_start = int(a["primary_message"]["line_start"])
            )
            ui_id_alert_data[a["ui_alert_id"]] = alert_data

        package = {}
        package["package_name"] = package_name
        package["package_description"] = "Sample package description for " + package_name
        package["code_language_ids"] = code_language_ids
        if author_source:
            package["author_source"] = author_source
        if code_source_url:
            package["code_source_url"] = code_source_url
        if source_file_url:
            package["source_file_url"] = source_file_url
        if source_function_url:
            package["source_function_url"] = source_file_url
        if test_suite_id:
            package["test_suite_id"] = test_suite_id    
        if cppcheck_alerts:
            package["alerts"] = cppcheck_alerts   
        if tool_ids:
            package["tool_ids"] = tool_ids  

        create_package_request_url = datahub_url + "/packages"
        datahub_headers["x_request_token"] = helper.get_request_token(0)
        datahub_response = requests.post(create_package_request_url, data=json.dumps(package), headers=datahub_headers)
        status_code = datahub_response.status_code
        response = datahub_response.json()
        if 200 != status_code:
            raise Exception(response)

        package = response
        PACKAGE_NAMES_IDS[package_name] = package["package_id"]

        alert_mappings = package["alert_mappings"]
        cppcheck_meta_alerts = helper.get_meta_alerts(alert_mappings, ui_id_alert_data, CHECKER_IDS_TOOL_CHECKER_NAMES, TOOL_CHECKER_NAMES_CONDITION_NAMES, CONDITION_NAMES_IDS)

        if 0 == len(cppcheck_meta_alerts):
            raise Exception("Test helper failed to retrieve meta-alerts")

        # Make API call to upload_codebase_for_package
        datahub_headers = {'x_access_token': helper.get_access_token(author_example1, author_organization_example, "datahub")}

        multipart_form_data = {
            'sourcecode_archive': ("micro_juliet_v1-2_for_C_Cpp_cppcheck.zip", open(source_directory_filepath, 'rb'))
        }

        package_id = PACKAGE_NAMES_IDS[package_name]
 
        upload_codebase_request_url = datahub_url + "/packages/" + package_id
        datahub_headers["x_request_token"] = helper.get_request_token(0)
        datahub_response = requests.post(upload_codebase_request_url, files=multipart_form_data, headers=datahub_headers)
        status_code = datahub_response.status_code
        response = datahub_response.json()
        if 200 != status_code:
            raise Exception(response)


        # Make API call to upload_test_suite
        
        test_suite_dir = helper.get_test_suite_filepath(package_name)
        manifest_filename = "micro_juliet_v1-2_for_C_Cpp_cppcheck_manifest.xml"
        file_info_filename = "juliet_v1-2_files_cppcheck.csv"
        function_info_filename = "juliet_v1-2_functions_cppcheck.csv"

        multipart_form_data = {
            'manifest_file': (manifest_filename, open(test_suite_dir + "/" + manifest_filename, 'rb')),
            'source_file_csv': (file_info_filename, open(test_suite_dir + "/" + file_info_filename, 'rb')),
            'source_function_csv': (function_info_filename, open(test_suite_dir + "/" + function_info_filename, 'rb'))
        }

        upload_test_suite_request_url = datahub_url + "/test_suites/" + test_suite_id + "/packages/" + package_id
        datahub_headers["x_request_token"] = helper.get_request_token(0)
        datahub_response = requests.post(upload_test_suite_request_url, 
                                         files=multipart_form_data, 
                                         headers=datahub_headers
                                         )
        status_code = datahub_response.status_code
        response = datahub_response.json()
        if 200 != status_code:
            raise Exception(response)


        # Make API call to create_project
        datahub_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "datahub")}

        project_name = package_name
        project_description = "Sample package description for " + project_name
        author_source = "Unknown author"
        package_id = PACKAGE_NAMES_IDS[package_name]
        taxonomy_ids = list(TAXONOMY_IDS.values())

        project = {}
        project["project_name"] = project_name
        project["project_description"] = project_description
        project["package_id"] = package_id
        if author_source:
            project["author_source"] = author_source
        if len(cppcheck_meta_alerts) > 0:
            project["meta_alerts"] = cppcheck_meta_alerts
        if len(taxonomy_ids) > 0:
            project["taxonomy_ids"] = taxonomy_ids

        create_project_request_url = datahub_url + "/projects"
        datahub_headers["x_request_token"] = helper.get_request_token(0)
        datahub_response = requests.post(create_project_request_url, data=json.dumps(project), headers=datahub_headers)
        status_code = datahub_response.status_code
        response = datahub_response.json()
        if 200 != status_code:
            raise Exception(response)

        project_object = response
        PROJECT_NAMES_IDS[package_name] = project_object["project_id"]
        meta_alert_mappings = project_object["meta_alert_mappings"]

        if 91 != len(meta_alert_mappings):
            raise Exception("Unexpected number of meta-alerts uploaded to the DataHub")


    def test_8_create_and_run_cppcheck_microjuliet_classifier(self):

        # Make API call to list_classifiers
        stats_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "stats")}
              
        classifiers_request_url = stats_url + "/classifiers"
        stats_headers["x_request_token"] = helper.get_request_token(0)
        stats_response = requests.get(
            classifiers_request_url,
            headers=stats_headers)
        self.assert200(stats_response, "Response body is : " + stats_response.text)

        classifer_objects = stats_response.json()

        if not len(classifer_objects) >= 3:
            raise Exception("Unexpected number of classifiers retrieved from the Stats Module")

        for classifier in classifer_objects:
            classifier_id = classifier["classifier_id"]
            classifier_type = classifier["classifier_type"]
            CLASSIFIER_TYPES_IDS[classifier_type] = classifier_id
            #[AHPOS.add(x["name"]) for x classifier["ahpos"] ]
            #[ADAPTIVE_HEURISTICS.add(x["name"]) for x classifier["adaptive_heuristics"] ]


        c_type = "Random Forest"
        c_id = CLASSIFIER_TYPES_IDS[classifier_type]
        classifier_instance_name = "test2"
        package_name = "microjuliet"
        project_ids = [ PROJECT_NAMES_IDS[package_name] ]
        ahpo_name = "Bayesian Optimization"
        adaptive_heuristic_name = "Similarities"

        #TODO: Update ahpo_id and adaptive_heuristic_id in RC-1064
        classifier_data = {
            "classifier_id": c_id,
            "classifier_type": c_type,
            "classifier_instance_name": classifier_instance_name,
            "project_ids": project_ids,
            "feature_selection_category": "intersection",
            "ahpo_id": "Sample AHPO ID",
            "ahpo_name": ahpo_name,
            "ahpo_parameters": {},
            "adaptive_heuristic_id": "Sample AH ID",
            "adaptive_heuristic_name": adaptive_heuristic_name,
            "adaptive_heuristic_parameters": {}
        }

        # Make API call to create_classifier_instance
        stats_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "stats")}
              
        classifiers_request_url = stats_url + "/classifiers"
        stats_headers["x_request_token"] = helper.get_request_token(0)
        stats_response = requests.post(
            classifiers_request_url,
            data=json.dumps(classifier_data),
            headers=stats_headers)
        self.assert200(stats_response, "Response body is : " + stats_response.text)

        response = stats_response.json()

        classifier_instance_id = response["classifier_instance_id"]
        project_id = response["project_id"]
        CLASSIFIER_INSTANCE_IDS.append((classifier_instance_id, project_id))
     
        # Make API call to run_classifier_instance
        stats_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "stats")}
              
        run_classifier_request_url = stats_url + "/classifiers/" + classifier_instance_id + "/projects/" + project_id

        stats_headers["x_request_token"] = helper.get_request_token(0)
        stats_response = requests.put(
            run_classifier_request_url,
            headers=stats_headers)
        self.assert200(stats_response, "Response body is : " + stats_response.text)

        response = stats_response.json()

        probability_data = response["probability_data"]
        for obj in probability_data:
            confidence_value = float(obj["probability"])
            if not confidence_value > 0:
                raise Exception("Stats Module failed to send confidence values") 


    def test_9_create_and_run_classifier_using_multiple_projects(self):

        # Make API call to list_classifiers
        stats_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "stats")}
              
        classifiers_request_url = stats_url + "/classifiers"
        stats_headers["x_request_token"] = helper.get_request_token(0)
        stats_response = requests.get(
            classifiers_request_url,
            headers=stats_headers)
        self.assert200(stats_response, "Response body is : " + stats_response.text)

        classifer_objects = stats_response.json()

        if not len(classifer_objects) >= 3:
            raise Exception("Unexpected number of classifiers retrieved from the Stats Module")

        for classifier in classifer_objects:
            classifier_id = classifier["classifier_id"]
            classifier_type = classifier["classifier_type"]
            CLASSIFIER_TYPES_IDS[classifier_type] = classifier_id
            #[AHPOS.add(x["name"]) for x classifier["ahpos"] ]
            #[ADAPTIVE_HEURISTICS.add(x["name"]) for x classifier["adaptive_heuristics"] ]


        c_type = "Random Forest"
        c_id = CLASSIFIER_TYPES_IDS[classifier_type]
        classifier_instance_name = "test3"
        project_ids = [ PROJECT_NAMES_IDS["dos2unix"],  PROJECT_NAMES_IDS["microjuliet"]]
        ahpo_name = "Bayesian Optimization"
        adaptive_heuristic_name = "Similarities"

        #TODO: Update ahpo_id and adaptive_heuristic_id in RC-1064
        classifier_data = {
            "classifier_id": c_id,
            "classifier_type": c_type,
            "classifier_instance_name": classifier_instance_name,
            "project_ids": project_ids,
            "feature_selection_category": "intersection",
            "ahpo_id": "Sample AHPO ID",
            "ahpo_name": ahpo_name,
            "ahpo_parameters": {},
            "adaptive_heuristic_id": "Sample AH ID",
            "adaptive_heuristic_name": adaptive_heuristic_name,
            "adaptive_heuristic_parameters": {}
        }

        # Make API call to create_classifier_instance
        stats_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "stats")}
              
        classifiers_request_url = stats_url + "/classifiers"
        stats_headers["x_request_token"] = helper.get_request_token(0)
        stats_response = requests.post(
            classifiers_request_url,
            data=json.dumps(classifier_data),
            headers=stats_headers)
        self.assert200(stats_response, "Response body is : " + stats_response.text)

        response = stats_response.json()

        classifier_instance_id = response["classifier_instance_id"]
        project_id = response["project_id"]
        CLASSIFIER_INSTANCE_IDS.append((classifier_instance_id, project_id))
     
        # Make API call to run_classifier_instance
        stats_headers = {'Content-Type': 'application/json', 'x_access_token': helper.get_access_token(author_example1, author_organization_example, "stats")}
              
        run_classifier_request_url = stats_url + "/classifiers/" + classifier_instance_id + "/projects/" + project_id

        stats_headers["x_request_token"] = helper.get_request_token(0)
        stats_response = requests.put(
            run_classifier_request_url,
            headers=stats_headers)
        self.assert200(stats_response, "Response body is : " + stats_response.text)

        response = stats_response.json()

        probability_data = response["probability_data"]
        for obj in probability_data:
            confidence_value = float(obj["probability"])
            if not confidence_value > 0:
                raise Exception("Stats Module failed to send confidence values")      
           


if __name__ == '__main__':
    import unittest

    unittest.main()
