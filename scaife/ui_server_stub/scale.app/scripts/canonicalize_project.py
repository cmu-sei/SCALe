#!/usr/bin/env python

# Given a project ID, prints a canonical form of the project's data.
#
# This provides us with a definition of equality for projects...two
# projects are equivalent if this script produces the same output for
# them. The output can be compared with diff(1) or a similar utility.
#
# For any project, its canonical data consists of the following:
# * A listing of its GNU Global pages
# * A listing of its supplemental files (source file, metrics info, etc)
# * A dump of its external database
# * A judicious dump of the project-related records in the internal database
#   Records not specific to the project are ignored. For example, the
#   languages, tools, and taxonomies tables are ignored, because they
#   must be exactly the same for all projects (and all other tables without
#   a field named "project_id" are not examined).
#
# These fields must also be ignored, as they will always differ even
# between equivalent projects:
# * The project id
# * Timestamps
# * Floats that measure time (eg how long did this operation take?)
# * All fields named "id" from the internal db,
#   which contains multiple projects
#
# Note that currently confidence scores are not deterministic and will
# vary from run to run given the same initial conditions. Therefore the
# displays/confidence and MetaAlerts/confidence_score columns in the
# internal and exported databases, respectively, must be normalized.
#
# This script produces file listings of the GNU global pages and
# supplemental files. It does not inspect these files
# further. Therefore, it is possible to fool this script if two
# otherwise identical projects have different supplemental files that
# have the same name. In that case their databases and supplemental
# file listing would be identical. A future enhancement of this script
# could also compare files using hashes, to also compare contents of the files.

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

from __future__ import print_function

import sys
import os
import re
import sqlite3
import subprocess

import bootstrap

def make_normalizer():
    ordinal_mapping = {}
    def _normalize(val, table, row, col, wildcard=False):
        val = str(val)
        if wildcard:
            if wildcard is True:
                return "norm(%s:%s%ssplat)" % (table, row, col)
            else:
                return "norm(%s:%s:%s:%s)" % (table, row, col, wildcard)
        if val not in ordinal_mapping:
            #ordinal_mapping[val] = "norm(%06d)" % len(ordinal_mapping)
            ordinal_mapping[val] = "norm(%s:%s:%s)" % (table, row, col)
        return ordinal_mapping[val]
    return _normalize

def output_canonicalized_db(db_path, project_id, internal_db=True,
        out=sys.stdout):
    if not os.path.exists(db_path):
        raise ValueError("DB does not exist: %s" % db_path)
    project = bootstrap.Project(project_id,
            db=db_path, external=not internal_db)
    with sqlite3.connect(db_path) as con:
        cur = con.cursor()

        # ignore tables
        ignore_tables = set([
            "performance_metrics", "PerformanceMetrics",
        ])

        # note variable columns that aren't automatically identified
        variable_cols = {}

        variable_cols["projects"] = variable_cols["Projects"] = [
            "name",
            "description",
            "version",
            "project_data_source",
            "author_source",
            "license_file",
            "last_used_confidence_scheme",
            "last_used_priority_scheme",
            "current_classifier_scheme",
        ]
        variable_cols["classifier_schemes"] = \
                variable_cols["ClassifierSchemes"] = [
            "classifier_instance_name",
            "source_domain",
        ]

        # completely unpredictable
        variable_wildcard_cols = {}
        variable_wildcard_cols["displays"] = [
            "confidence",
            "class_label",
        ]
        variable_wildcard_cols["MetaAlerts"] = [
            "confidence_score",
            "class_label",
        ]

        variable_timestamp_cols = {}

        normalize = make_normalizer()

        # Iterate over all tables in db
        cur.execute("SELECT name FROM SQLITE_MASTER WHERE type='table'")
        for [table_name, ] in cur.fetchall():
            if table_name in ignore_tables:
                continue
            for exception_cols in (variable_cols,
                    variable_timestamp_cols, variable_wildcard_cols):
                if table_name not in exception_cols:
                    exception_cols[table_name] = set()
            normalize_cols = set(variable_cols[table_name])
            timestamp_cols = set(variable_timestamp_cols[table_name])
            wildcard_cols = set(variable_wildcard_cols[table_name])
            cur2 = con.cursor()
            cur2.execute("SELECT name, type FROM pragma_table_info(?)",
                         [table_name, ])
            column_names = []
            for [column_name, column_type] in cur2.fetchall():
                # normalize timestamps
                if column_type.lower() == "datetime":
                    timestamp_cols.add(column_name)
                # normalize time measurements
                if column_type.lower() == "float" and \
                        column_name.endswith("_time"):
                    normalize_cols.add(column_name)
                # normalize scaife IDs
                if re.search(r"scaife.*_id$", column_name):
                    normalize_cols.add(column_name)
                column_names.append(column_name)

            if column_names[0].lower() == "id" \
                    and "project_id" not in column_names:
                del column_names[0]

            orig_column_names = list(column_names)

            if internal_db:
                # Prune out id from all tables in internal db that
                # have that field...two identical projects in the
                # internal db will still have different 'id' fields in
                # many tables since it has to be unique.
                if column_names[0].lower() == "id":
                    del column_names[0]

                # Skip tables without a 'project_id' field in internal db
                # unless it's the classifiers table
               # if "project_id" in column_names:
               #     column_names.remove("project_id")
               # elif table_name != "projects" or table_name != "classifiers":
               #     continue
                if "project_id" not in column_names and \
                       table_name not in ("projects", "classifiers"):
                   continue
                if "project_id" in column_names:
                    column_names.remove("project_id")

            normalize_indices = []
            for col in normalize_cols:
                normalize_indices.append(column_names.index(col))
            timestamp_indices = []
            for col in timestamp_cols:
                timestamp_indices.append(column_names.index(col))
            wildcard_indices = []
            for col in wildcard_cols:
                wildcard_indices.append(column_names.index(col))

            # Search by "id" in internal db's projects table
            # Search by "project_id" elsewhere
            query = [
                "SELECT %s FROM %s" % (', '.join(column_names), table_name)
            ]
            args = []
            if internal_db and \
                    (table_name == "projects" or \
                         "project_id" in orig_column_names):
                if table_name == "projects":
                    sql = "WHERE id = ?"
                else:
                    sql = "WHERE project_id = ?"
                query.append(sql)
                args.append(project_id)
            elif table_name in ("classifier_schemes", "ClassifierSchemes"):
                if project.current_classifier_scheme:
                    query.append("WHERE classifier_instance_name = ?")
                    args.append(project.current_classifier_scheme)
                else:
                    # skip table, project has used no classifiers
                    continue
            cur2.execute(' '.join(query), args)
            rows = cur2.fetchall()
            if not rows:
                continue

            out.write("TABLE: " + table_name + "\n")
            out.write("  COLUMNS: " + "|".join([str(c) for c in column_names])
                      + "\n")

            link = -1
            if "link" in column_names:
                link = column_names.index("link")

            for row_idx, row in enumerate(rows):
                # If there is a 'link' column, canonicalize the project id
                # (in its path)
                rowlist = []
                for val in row:
                    if val is None:
                        val = ''
                    elif val in (True, False):
                        val = str(int(val))
                    else:
                        val = str(val)
                    #if scaife_id_relevant and cid not in scaife_id_relevant:
                    #    # scaife IDs are relevant and this row id isn't
                    #    # one we're interested in, so make them blank
                    #    if i in scaife_indices:
                    #        val = ''
                    rowlist.append(val)
                if link != -1:
                    rowlist[link] = re.sub(r"GNU/%s/" % project_id,
                                           r"GNU/<project>/", rowlist[link])
                for idx in normalize_indices:
                    if rowlist[idx]:
                        rowlist[idx] = \
                            normalize(row[idx], table_name, row_idx, idx)
                for idx in timestamp_indices:
                    if rowlist[idx]:
                        rowlist[idx] = \
                            normalize(row[idx], table_name,
                                    row_idx, idx, wildcard="timestamp")
                for idx in wildcard_indices:
                    if rowlist[idx]:
                        rowlist[idx] = \
                            normalize(row[idx], table_name,
                                    row_idx, idx, wildcard=True)
                out.write("    ROW: " + "|".join(rowlist) + "\n")

def output_canonicalized_project(project_id, out=sys.stdout):
    # Produce canonical info for project database
    if project_id is None:
        raise ValueError("project_id required, given: %s" % project_id)
    out.write("External Database Contents:\n")
    backup_db = bootstrap.find_project_db(project_id)
    if not backup_db:
        raise ValueError("project %s has no external DBs" % project_id)
    # external always has project id 0
    output_canonicalized_db(backup_db, 0, internal_db=False, out=out)
    out.write("\n")

    # Produce canonical info for project in internal database
    out.write("Internal Database Contents:\n")
    output_canonicalized_db(bootstrap.internal_db, project_id, out=out)
    out.write("\n")

    # Produce directory listing of project's 'supplemental' directory.
    supplemental_dir = bootstrap.project_supplemental_dir(project_id)
    if os.path.exists(supplemental_dir):
        # currently only gets created if project is a test suite
        out.write("Supplemental File Listing:\n")
        out.flush()  # prevent mis-ordered output
        os.chdir(supplemental_dir)
        # dumb term prevents colorized output
        subprocess.call("env TERM=dumb ls -R1", shell=True, stdout=out)
        out.flush()
        out.write("\n")

    # Produce directory listing of project's GNU Global files.
    out.write("GNU Global File Listing:\n")
    out.flush()  # prevent mis-ordered output
    gnu_dir = bootstrap.project_gnu_dir(project_id)
    os.chdir(gnu_dir)
    # dumb term prevents colorized output
    subprocess.call("env TERM=dumb ls -R1", shell=True, stdout=out)
    out.flush()


if __name__ == "__main__":
    if "-h" in sys.argv or "--help" in sys.argv:
        print("Usage: ", sys.argv[0], " <project-id>")
        exit(1)
    if len(sys.argv) > 1:
        project_id = int(sys.argv[1])
    else:
        project_id = bootstrap.get_latest_project_id()
        if not project_id:
            print("no projects present in DB", file=sys.stderr)
            sys.exit(1)
    output_canonicalized_project(project_id)
