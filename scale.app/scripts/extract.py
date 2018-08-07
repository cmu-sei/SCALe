# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

import subprocess
import feature_extraction as fe
from feature_extraction import FeatureName, Category, Tool
import re

import sqlite3


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
            for diag in fortify_extract(data_inner):
                features = diag.feature_dict()
                checker = features[FeatureName.Checker]
                checker.value = bad_checker_chars.sub("_", checker.value)
                filtered.append(diag)
            return filtered
        return extract_inner
    else:
        return None


def extract_msg_info(features):
    desired = [FeatureName.Message,
               FeatureName.FilePath, FeatureName.LineStart]
    return [features.get(item) for item in desired]


def extract_src_context(features):
    desired = [
        FeatureName.FunctionOrMethod,
        FeatureName.Class,
        FeatureName.Namespace,
        FeatureName.LineEnd,
        FeatureName.ColStart,
        FeatureName.ColEnd]
    return [features.get(item) for item in desired]


def measurements_to_scale(measurements, database, tool_id):
    diags = []
    messages = []
    source_contexts = []
    extra_features = []

    extra_features_of_interest = [
        FeatureName.FortifyKingdom,
        FeatureName.FortifyClassId,
        FeatureName.FortifyClassType,
        FeatureName.FortifyClassSubType,
        FeatureName.FortifyAnalyzerName,
        FeatureName.FortifyDefaultSeverity,
        FeatureName.FortifyInstanceId,
        FeatureName.FortifyInstanceInfo,
        FeatureName.FortifyInstanceSeverity,
        FeatureName.FortifyConfidence]

    msg_id = int(tool_id)
    diag_id = int(tool_id)
    incr = 100

    for measurement in measurements:
        features = measurement.feature_value_dict()
        category = features[FeatureName.Category]

        if category == Category.Diagnostic:
            checker = features.get(FeatureName.Checker)
            diags.append((str(diag_id), "0", "0", "0", checker, str(
                tool_id), unicode(msg_id), "", "0", "0", "0", "0", "0", "0"))
            msg_index = 1
            for item in [features] + features['__sub']:
                msg, path, line = extract_msg_info(item)
                func, clazz, ns, line_end, col_start, col_end = extract_src_context(
                    item)
                if msg == None:
                    msg = ""
                messages.append(
                    (str(msg_id), str(diag_id), path, line, msg.decode('utf8')))
                source_contexts.append((
                    str(msg_id),
                        str(func),
                        str(clazz),
                        str(ns),
                        str(line_end),
                        str(col_start),
                        str(col_end)))
                msg_id += incr

            for item in extra_features_of_interest:
                if item in features:
                    feature = features[item]
                    if feature is not None:
                        extra_features.append(
                            (str(diag_id), str(item), str(features[item])))

            diag_id += incr

    with sqlite3.connect(database) as db:
        cursor = db.cursor()
        cursor.executemany(
            'INSERT INTO "Diagnostics" VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)', diags)
        cursor.executemany(
            'INSERT INTO "Messages" VALUES(?,?,?,?,?)', messages)
        cursor.executemany(
            'INSERT INTO "ExtraSourceContext" VALUES(?,?,?,?,?,?,?)', source_contexts)
        cursor.executemany(
            'INSERT INTO "ExtraFeatures" VALUES(?,?,?)', extra_features)


def extract_measurements(tool_name, tool_id, input_file, database):
    extractor_function = get_extractor_function(tool_name, input_file)
    if extractor_function is not None:
        subprocess.check_call("python ./" + tool_name + "2org.py " + input_file +
                              " | sort -u " +
                              " | python ./saorg2sql.py " + str(tool_id) + " " + database, shell=True)
        # this method provides more information - extra features, extra source content
        # with open(input_file) as data:
            # diagnostics = extractor_function(data)
            # measurements_to_scale(diagnostics, database, tool_id)
    else:
        input_file = '"' + input_file + '"'
        tool = str(tool_id)
                # charuta
        # different scripts for .rps and other input files
        if input_file.endswith(".rps\"") and tool_name == "ldra":
            subprocess.check_call("python ./new" + tool_name + "2org.py " +
                                  input_file + 
				  " | sort -u " +
				  " | python ./saorg2sql.py " + tool + " " + database, shell=True)
        else:
            subprocess.check_call("python ./" + tool_name + "2org.py " + 
				  input_file +
				  " | sort -u " +
                                  " | python ./saorg2sql.py " + tool + " " + database, shell=True)
