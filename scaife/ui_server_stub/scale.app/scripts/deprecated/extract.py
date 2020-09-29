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

import subprocess
import feature_extraction as fe
from feature_extraction import FeatureName, Category, Tool
import re

import sqlite3


#def extract_msg_info(features):
#"""Called by measurements_to_scale, which is currently unused."""
#    desired = [FeatureName.Message,
#               FeatureName.FilePath, FeatureName.LineStart]#
#    return [features.get(item) for item in desired]


#def extract_src_context(features):
#"""Called by measurements_to_scale, which is currently unused."""
#    desired = [
#        FeatureName.FunctionOrMethod,
#        FeatureName.Class,
#        FeatureName.Namespace,
#        FeatureName.LineEnd,
#        FeatureName.ColStart,
#        FeatureName.ColEnd]
#    return [features.get(item) for item in desired]


#def measurements_to_scale(measurements, database, tool_id):
#"""Called by extract_measurements.  Currently unused."""
#    alerts = []
#    messages = []
#    source_contexts = []
#    extra_features = []

#    extra_features_of_interest = [
#        FeatureName.FortifyKingdom,
#        FeatureName.FortifyClassId,
#        FeatureName.FortifyClassType,
#        FeatureName.FortifyClassSubType,
#        FeatureName.FortifyAnalyzerName,
#        FeatureName.FortifyDefaultSeverity,
#        FeatureName.FortifyInstanceId,
#        FeatureName.FortifyInstanceInfo,
#        FeatureName.FortifyInstanceSeverity,
#        FeatureName.FortifyConfidence]

#    msg_id = int(tool_id)
#    alert_id = int(tool_id)
#    incr = 100

#    for measurement in measurements:
#        features = measurement.feature_value_dict()
#        category = features[FeatureName.Category]

#        if category == Category.Alert:
#            checker = features.get(FeatureName.Checker)
#            alerts.append((str(alert_id), "0", "0", "0", checker, str(
#                tool_id), unicode(msg_id), "", "0", "0", "0", "0", "0", "0"))
#            msg_index = 1
#            for item in [features] + features['__sub']:
#                msg, path, line = extract_msg_info(item)
#                func, clazz, ns, line_end, col_start, col_end = extract_src_context(
#                    item)
#                if msg == None:
#                    msg = ""
#                messages.append(
#                    (str(msg_id), str(alert_id), path, line, msg.decode('utf8')))
#                source_contexts.append((
#                    str(msg_id),
#                        str(func),
#                        str(clazz),
#                        str(ns),
#                        str(line_end),
#                        str(col_start),
#                        str(col_end)))
#                msg_id += incr

#            for item in extra_features_of_interest:
#                if item in features:
#                    feature = features[item]
#                    if feature is not None:
#                        extra_features.append(
#                            (str(alert_id), str(item), str(features[item])))

#            alert_id += incr

#    with sqlite3.connect(database) as db:
#        cursor = db.cursor()
#        cursor.executemany(
#            'INSERT INTO "Alerts" VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)', alerts)
#        cursor.executemany(
#            'INSERT INTO "Messages" VALUES(?,?,?,?,?)', messages)
#        cursor.executemany(
#            'INSERT INTO "ExtraSourceContext" VALUES(?,?,?,?,?,?,?)', source_contexts)
#        cursor.executemany(
#            'INSERT INTO "ExtraFeatures" VALUES(?,?,?)', extra_features)


def get_extractor_function(tool_name, input_file):
    if tool_name == "coverity":
        return fe.extractors[Tool.Coverity]["json_v2"]
    elif tool_name == "fortify":
        input_file = input_file.strip()

        fortify_extract = None
        if input_file.endswith(".fvdl"):
            fortify_extract = fe.extractors[Tool.Fortify]["fvdl"]
        else:
            fortify_extract = fe.extractors[Tool.Fortify]["dev_xml"]

        def extract_inner(data_inner):
            bad_checker_chars = re.compile(r"[^A-Za-z0-9_]")
            filtered = []
            for alert in fortify_extract(data_inner):
                features = alert.feature_dict()
                checker = features[FeatureName.Checker]
                checker.value = bad_checker_chars.sub("_", checker.value)
                filtered.append(alert)
            return filtered
        return extract_inner
    else:
        return None


def extract_measurements(tool_name, tool_id, input_file, database):
    #NOTE: the following lines that are commented out reference unused, legacy code
    #extractor_function = get_extractor_function(tool_name, input_file)
    #if extractor_function is not None:
    #    subprocess.check_call("python ./" + tool_name + "2org.py " + input_file +
    #                          " | sort -u " +
    #                          " | python ./saorg2sql.py " + str(tool_id) + " " + database, shell=True)
        # this method provides more information - extra features, extra source content
        # with open(input_file) as data:
            # alert = extractor_function(data)
            # measurements_to_scale(alert, database, tool_id)
    #else:
    #input_file = '"' + input_file + '"'
    tool = str(tool_id)

    # different scripts for .rps and other input files
    subprocess.check_call("python ./tool_output_parsers"/ + tool_name + "2org.py " + input_file +
                                  " | sort -u " +
                                  " | python ./saorg2sql.py " + tool + " " + database, shell=True)
