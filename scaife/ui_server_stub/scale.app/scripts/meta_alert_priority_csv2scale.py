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
import random
import re
import sqlite3 as sqlite
from sqlite3 import Error
import json

#Python script that updates a SCALe db with an evaluation of the alert prioritization formula.
#SQL UPDATE statements are produced and db is updated accordingly.

cmd_parser = argparse.ArgumentParser(description="Imports contents of a priority scheme, evaluates the formula and updates the SCALe database with the output.")
cmd_parser.add_argument("project_id", help="Project ID associated with the formula and columns")
cmd_parser.add_argument("database", help="Database to add alert priority values to")
cmd_parser.add_argument("formula", help="Formula to evaluate priority values")
cmd_parser.add_argument("columns", help="All the columns allowed in the formula")
args = cmd_parser.parse_args()
db = None

def map_columns(columns): #Difference in naming conventions (in SCALe DB) and columns for each taxonomy in the GUI
    col_mapping = {}
    db_fields = []

    col_mapping["cert_likelihood"] = "likelihood"
    col_mapping["cert_remediation"] = "remediation"
    col_mapping["cert_priority"] = "priority"
    col_mapping["cert_level"] = "level"
    col_mapping["cert_severity"] = "severity"
    col_mapping["cwe_likelihood"] = "cwe_likelihood"
    col_mapping["cert_confidence"] = "confidence"
    col_mapping["cwe_confidence"] = "confidence"

    for col in columns:
        if col in col_mapping.keys():
            db_fields.append(col_mapping[col])
        else:
            db_fields.append(col)

    return db_fields

def evaluate_priority(columns, formula, values):
    tax_formula= None

     #workaround for taxonomy type (only supports CWE and CERT, we will need to extend this when we introduce a new taxonomy
    if re.match("CWE\-", values[len(columns)]):
        tax_formula = "IF_CWES\((.*)\)\+"
    elif re.match("[A-Z]{3}\d+\-[PL|CPP|C|J]", values[len(columns)]):
        tax_formula = "IF_CERT_RULES\((.*)\)"

    for i, col in enumerate(columns):
        #turn the formula into an arithmetic equation
        #TODO: Add a mapping for High, medium and low values as well as booleans
        val = "0" if values[i] == None or not isinstance(values[i], (int, float, long)) else str(values[i]) #if the value is not a number than set the value to zero.
        formula = formula.replace(col, val)

    #choose the appropriate formula for this alert's taxonomy
    if tax_formula:
        eval_formula = re.search(tax_formula, formula)
        if eval_formula:
            try:
                calculation = int(eval(eval_formula.group(1)))

                if calculation:
                    return calculation
                else:
                    return 0
            except Error:
                return 0
        else:
            return 0
    else:
        return 0;

def getPriorities():
    csv_contents = []

    pattern = re.compile(r'([a-z]+_?[a-z]+)')
    column_order = re.findall(pattern, args.formula)
    column_unique = list(set(column_order))
    user_col_names = []
    db_col_names = []
    # separate column_unique into user and db_columns by looking for "user_"
    for col in args.columns.strip("[").strip("]").split(","):
        if col.startswith("user_"):
            col = col.replace("user_", "")
            if col in column_unique:
                user_col_names.append(col)
        elif col in column_unique:
            db_col_names.append(col)

    db_columns = map_columns(db_col_names)
    db_columns.append('condition')
    db_columns.append('meta_alert_id')

    try:
        db = sqlite.connect(args.database)
        cursor = db.cursor()
        alerts = cursor.execute("""SELECT {} FROM displays WHERE project_id={};""".format(", ".join(db_columns), args.project_id)).fetchall()

        #get values from user_columns from user_uploads table as array
        user_uploads = cursor.execute(
            """SELECT meta_alert_id, user_columns FROM user_uploads;"""
        ).fetchall()

        #insert empty slot for 'rule'
        user_meta_ids = []
        user_columns = []

        for row in user_uploads:
            user_meta_ids.append(row[0])
            user_cols_json = json.loads(row[1])
            cols = []
            for k, v in user_cols_json.iteritems():
                if k in column_unique:
                    cols.append(int(v.encode("ascii", "ignore")))
            user_columns.append(cols)

        for row in alerts:
            row = list(row)
            values = row
            if row[-1] in user_meta_ids:
                values = user_columns[user_meta_ids.index(row[-1])] + row
                col_names = column_unique

            for i in range(0, len(column_unique) - (len(values) - 2)):
                values = [None] + values

            priority = evaluate_priority(user_col_names + db_col_names, args.formula, values)
            csv_contents.append([ priority, row[len(row)-1], args.project_id ])


        cursor.executemany('UPDATE displays SET meta_alert_priority=? WHERE meta_alert_id=? AND project_id=?;', csv_contents)
        db.commit()
    except Error as e:
        print(e)
    finally:
        db.close()

if __name__ == "__main__":
     getPriorities()
