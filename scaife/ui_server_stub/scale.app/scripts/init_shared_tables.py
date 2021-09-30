#!/usr/bin/env python

# Python script that converts tools/languages/taxonomies json, loading
# associated data files, and populates the database
#
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

import os, sys, re, subprocess, argparse
import json, math, sqlite3
import bootstrap

from bootstrap import VERBOSE

def load_properties(tool):
    # Retrieve properties maps
    checkers = {}
    prop_files = bootstrap.properties_files(tool)
    if not prop_files and VERBOSE:
        print("no properties files found for (%s, %s, %s)" \
                % (tool.platform_str, tool.name, tool.version))
    for property_file in prop_files:
        if VERBOSE:
            print("prop file: %s" % \
                    os.path.relpath(property_file, bootstrap.properties_dir))

        has_re = "regex" in property_file

        for line in (x.strip() for x in open(property_file)):
            # skip comments and blank lines
            if line.startswith("#") or re.search(r"^\s*$", line):
                continue
            checker, condition_entry = \
                    [x.strip() for x in line.rsplit(':', 1)]
            condition_entry = [x.strip() for x in condition_entry.split(",")]
            if(condition_entry[0] == "NONE"):
                continue
            # create unique checker
            checker_conditions, has_re_prior = checkers.setdefault(
                    checker, ([], has_re))
            if has_re != has_re_prior:
                raise ValueError(
                    "checker collision on regex status: %s in file %s" \
                            % (str(checker_key), properties_file))
            for c in condition_entry:
                if c not in checker_conditions:
                    checker_conditions.append(c)
    return checkers


def insert_checker_mappings(cur, tool, external=False):
    if tool.name == "swamp_oss":
        # Do not load properties files for SWAMP
        return
    sql = "SELECT COUNT(tool_id) FROM checkers WHERE tool_id = ?"
    cur.execute(sql, [tool.id_])
    row = cur.fetchone()
    if row[0]:
        if VERBOSE:
            msg = "tool already loaded: %d (%s) %s" \
                % (tool.id_, tool.name, tool.platform_str)
            if tool.version:
                msg += " (ver %s)" % tool.version
            print(msg)
        return

    if VERBOSE:
        msg = "import mappings for tool: %s (%s)" \
                % (tool.name, tool.platform_str)
        if tool.version:
            msg += " %s" % tool.version
        print(msg)

    # Insert new Checkers into the database
    checkers = load_properties(tool)
    checker_ids = {}
    if sys.version_info[0] < 3:
        #Python 2
        checker_dict = checkers.iteritems()
    else:
        #Python 3
        checker_dict = checkers.items()
    table = "Checkers" if external else "checkers"
    for checker_name, (conditions, has_re) in checker_dict:
        sql = \
            "INSERT INTO %s (name, tool_id, regex) VALUES(?, ?, ?)" % table
        cur.execute(sql, (checker_name, tool.id_, has_re))
        checker_id = checker_ids[checker_name] = cur.lastrowid
    if VERBOSE:
        print("checkers added to db: %d" % len(checker_ids))

    table = "Conditions" if external else "conditions"
    conditions = {}
    cur.execute("SELECT id,name FROM %s" % table)
    for entry in cur.fetchall():
        condition_id = entry[0]
        condition_name = entry[1].strip()
        if condition_name not in conditions:
            conditions[condition_name] = []
        conditions[condition_name].append(condition_id)

    # Insert ConditionCheckerLinks
    table = "ConditionCheckerLinks" if external \
            else "condition_checker_links"
    unknown_conditions = set()
    num_cc_links = 0
    if sys.version_info[0] < 3:
        #Python 2
        checker_dict = checkers.iteritems()
    else:
        #Python 3
        checker_dict = checkers.items()
    for checker_name, (checker_conditions, has_re) in checker_dict:
        checker_id = checker_ids[checker_name]
        for condition_name in checker_conditions:
            if condition_name in conditions:
                for condition_id in conditions[condition_name]:
                    sql = "INSERT INTO %s VALUES(?, ?)" % table
                    try:
                        cur.execute(sql, (condition_id, checker_id))
                    except sqlite3.IntegrityError:
                        continue
                    num_cc_links += 1
            else:
                unknown_conditions.add(checker_name)
    if VERBOSE:
        print("condition/checker links added to db: %d" % num_cc_links)
        if unknown_conditions:
            print("unknown conditions: %d" % len(unknown_conditions))

def cert_reader(filename, platform):

    def _reweight_cost(text):
        """
        High severity = 3, but high rem cost = 1. (and reverse for low)
        """
        text = re.sub(r"\|\s*high\s*\|(?=\s*\d)", "|1|", text, flags=re.I)
        text = re.sub(r"\|\s*low\s*\|(?=\s*\d)",  "|3|", text, flags=re.I)
        text = re.sub(r"\|\s*high\s*\|",          "|3|", text, flags=re.I)
        text = re.sub(r"\|\s*low\s*\|",           "|1|", text, flags=re.I)
        text = re.sub(r"\|\s*medium\s*\|",        "|2|", text, flags=re.I)
        text = re.sub(r"\|\s*likely\s*\|",        "|3|", text, flags=re.I)
        text = re.sub(r"\|\s*unlikely\s*\|",      "|1|", text, flags=re.I)
        text = re.sub(r"\|\s*probable\s*\|",      "|2|", text, flags=re.I)
        return text

    for line in (x.strip() for x in open(filename)):
        line = re.sub(r"^\|+", "", line)
        line = re.sub(r"\|+$", "", line)
        line = _reweight_cost(line)
        line = re.split(r"\s*\|\s*", line)
        for i, field in enumerate(line):
            line[i] = field.replace("BAR", "|")
        line.append(platform)
        yield line

def cwe_reader(filename):
    for line in (x.strip() for x in open(filename)):
        line = re.sub(r"^\|+", "", line)
        line = re.sub(r"\|+$", "", line)
        line = re.split(r"\s*\|\s*", line)
        for i, field in enumerate(line):
            line[i] = field.replace("BAR", "|")
        yield line

def insert_taxonomy(cur, ti, index=0, external=False):
    table = "Taxonomies" if external else "taxonomies"
    cur.execute(
        "SELECT COUNT(*) FROM %s WHERE name = ? AND version_string = ?" \
                % table, [ti["name"], ti["version"]]
    )
    present = cur.fetchone()[0]
    if present:
        print("taxonomy %s %s already loaded" % (ti["name"], ti["version"]))
        return None
    cur.execute(
        "INSERT INTO " + table + " (name, version_string, " +
        "  version_number, type, author_source, user_id, " +
        "  user_org_id, format) " +
        "  VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        [
            ti["name"],
            ti["version"] or "",
            ti["version_order"],
            ti["type"],
            ti["author_source"],
            ti["user_id"],
            ti["user_org_id"],
            json.dumps(ti["format"])
        ]
    )
    if ti["version_brief"]:
        filename = \
            "%s.%s.v.%s.org" % \
            (ti["type"], ti["platform"], ti["version_brief"])
    else:
        filename = "%s.%s.org" % (ti["type"], ti["platform"])
    filename = os.path.join(bootstrap.conditions_dir, filename)
    lc = 0
    if os.path.exists(filename):
        cur.execute("SELECT MAX(id) FROM %s" % table)
        taxonomy_id = cur.fetchone()[0]
        table = "Conditions" if external else "conditions"
        if ti["type"] == "cert_rules":
            reader = cert_reader(filename, ti["platform"])
        elif ti["type"] == "cwe":
            reader = cwe_reader(filename)
        for line in reader:
            for i, v in enumerate(line):
                if re.search(r"^\s*\d+\s*$", v):
                    line[i] = int(v.strip())
            name, title = line[0:2]
            formatted_data = json.dumps(line[2:])
            cur.execute("INSERT INTO %s VALUES (?, ?, ?, ?, ?, NULL)" \
                % table, [index, taxonomy_id, name, title, formatted_data])
            index += 1
            lc += 1
    else:
        print("taxonomy file not found (skipping): %s" \
                % os.path.relpath(filename, bootstrap.conditions_dir))
    return lc

def load_taxonomies(cur, external=False):
    table = "Conditions" if external else "conditions"
    cur.execute("DELETE FROM %s" % table)
    table = "Taxonomies" if external else "taxonomies"
    cur.execute("DELETE FROM %s" % table)
    offset = 0
    tc = 0
    cc = 0
    for ti in bootstrap.taxonomies_info():
        insertions = insert_taxonomy(cur, ti, index=offset, external=external)
        # new offset at the next 1000
        offset = int(math.ceil((offset+insertions)/1000.0)) * 1000
        cc += insertions
        tc += 1
    if VERBOSE:
        print("taxonomies added to DB: %d" % tc)
        print("conditions added to DB: %d" % cc)

def populate_tables(cur, external=False):
    lang_info = bootstrap.languages_info()
    unique = set()
    lang_ids_by_platform = {}
    lang_id = 1
    table = "Languages" if external else "languages"
    cur.execute("DELETE FROM %s" % table)
    if VERBOSE:
        print("populating table: %s" % table)
    cur.execute("DELETE FROM %s" % table)
    for lang in sorted(lang_info):
        li = lang_info[lang]
        if li["platform"] not in lang_ids_by_platform:
            lang_ids_by_platform[li["platform"]] = []
        lids = lang_ids_by_platform[li["platform"]]
        for version in li["versions"]:
            u = (lang, version)
            if u in unique:
                raise ValueError("language entry not unique: (%s, %s)" % u)
            unique.add(u)
            lang_row = (lang_id, lang, li["platform"], version)
            cur.execute(
                "INSERT INTO %s VALUES(?, ?, ?, ?, NULL)" % table,
                lang_row
            )
            lids.append(lang_id)
            lang_id += 1
    if VERBOSE:
        print("languages added to DB: %d" % len(lids))
    unique = set()
    tools_by_platform = {}
    metrics = []
    platform_order = []
    for tool_info in bootstrap.tools_info():
        tool_name = tool_info["name"]
        for platform_group in tool_info["platforms"]:
            if tool_info["type"] == "metric":
                platform_group = ["metric"]
            platform_group = json.dumps(platform_group)
            u = (tool_name, platform_group, version)
            if u in unique:
                raise ValueError("tool entry not unique: (%s, %s, %s)" % u)
            unique.add(u)
            for version in tool_info["versions"] or [""]:
                tool = (tool_name, platform_group, version, tool_info["label"])
                if tool_info["type"] == "metric":
                    metrics.append(tool)
                else:
                    if platform_group not in tools_by_platform:
                        tools_by_platform[platform_group] = []
                        platform_order.append(platform_group)
                    tools_by_platform[platform_group].append(tool)
    tools = []
    tool_id = 1
    for ptools in (tools_by_platform[p] for p in platform_order):
        for i, pt in enumerate(ptools):
            ptools[i] = (tool_id,) + ptools[i]
            tool_id += 1
        tools += ptools
    for i, m in enumerate(metrics):
        metrics[i] = (tool_id,) + m
        tool_id += 1
    table = "Tools" if external else "tools"
    if VERBOSE:
        print("populating table: %s" % table)
    cur.execute("DELETE FROM %s" % table)
    tool_language_rows = []
    for tool in tools + metrics:
        cur.execute(
            "INSERT INTO %s VALUES(?, ?, ?, ?, ?, NULL);" % table, tool)
        # we aren't currently associating 'languages' to tools in the DB
        # 'metric' should not be present
        # tool_id = tool[0]
        # platform = tool[2]
        # if platform in lang_ids_by_platform:
        #    for lang_id in lang_ids_by_platform[platform]:
        #        tool_language_rows.append((tool_id, lang_id))
    if VERBOSE:
        print("tools added to DB: %d" % (len(tools) + len(metrics)))

    load_taxonomies(cur, external=external)

    # import taxonomies/checkers
    table = "Checkers" if external else "checkers"
    cur.execute("DELETE FROM %s" % table)
    table = "ConditionCheckerLinks" if external else "condition_checker_links"
    cur.execute("DELETE FROM %s" % table)
    for tool in tools:
        tool_id, name, platform_group, version, label = tool
        tool = bootstrap.Tool(name, platform_group, version, label, id_=tool_id)
        insert_checker_mappings(cur, tool, external=external)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Initialize languages/taxonomies/tools tables")
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    parser.add_argument("database", help="Target database.")
    parser.add_argument("-f", "--force", action="store_true",
        help="replace DB if it exists")
    parser.add_argument("-e", "--external", action="store_true",
                        help="use external schema")
    args = parser.parse_args()
    if os.path.exists(args.database):
        if args.force:
            os.unlink(args.database)
    if VERBOSE:
        print("initialize DB: %s" % args.database)
    if not os.path.exists(args.database):
        create_db_sql_file = \
            os.path.join(bootstrap.scripts_dir, "create_scale_db.sql")
        subprocess.check_call(
            "sqlite3 '%s' < %s" % (args.database, create_db_sql_file),
            shell=True)
    with sqlite3.connect(args.database) as con:
        cur = con.cursor()
        populate_tables(cur, external=args.external)
