#!/usr/bin/env python

# Script takes SCALe database file as input, and updates output from a tool.
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import argparse
import os
import re
import sqlite3 as sqlite
import subprocess
import glob
import extract


# charuta

parser = argparse.ArgumentParser(description="Assimilates output from diagnsotics or metrics tool into a SCALe database", epilog='''
If database does not exist, it is created.
If database does exist, any data related to tool is first erased.
''')
parser.add_argument("database", help="Database to add input to")
parser.add_argument(
    "input", help="File containing output produced by tool")
parser.add_argument("tool", help="Number indicating valid tool & platform")
parser.add_argument('-s', '--source', action='append',
                    help="Path to source code to correct filenames")
parser.add_argument('-m', '--map',    action='append',
                    help="Path substitution to try when correcting filenames")
parser.add_argument('-v', '--verbose',
                    action="store_true", default=False, help="Verbose output")
args = parser.parse_args()
if args.source is None:
    raise Exception("Need at least one source path to search")
if args.map is None:
    args.map = "="
#   args.input = "\"" + args.input + "\""

if args.verbose:
    print "Copyright (c) 2007-2018 Carnegie Mellon University. ",
    " All Rights Reserved. See COPYRIGHT file for details."
    print "Args are: ", args
    os.environ["VERBOSE"] = "TRUE"
else:
    os.environ["VERBOSE"] = "FALSE"


if not os.path.exists("./org2dbdump.py"):
    raise Exception("CWD must be SCALe directory")


# Create db if necessary
if not os.path.exists(args.database):

    if "TRUE" == os.environ["VERBOSE"]:
        print "Creating new database: " + args.database
    subprocess.check_call(
        "sqlite3 " + args.database + " < create_scale_db.sql", shell=True)
    subprocess.check_call(
        "python ./org2dbdump.py < tools.org | sqlite3 " + args.database,
        shell=True)

    # Must get platform from tool id
    con = None
    con = sqlite.connect(args.database)

    with con:
        cur = con.cursor()
        cur.execute("SELECT platform FROM Tools WHERE id=?", [int(args.tool)])
        row = cur.fetchone()
        platform = row[0]
        if platform == "metric":
            raise Exception(
                "Must provide diagnostic output when creating database.")

        # add cert rules to TaxonomyEntries table and cert_rules table
        subprocess.check_call(
            "fgrep '|' cert_rules." + platform + ".org" +
            " | python ./fix_prob.py " + platform +
            " | python ./csv2sql.py --input org CERTrules 0 " +
            " | sqlite3 " + args.database, shell=True)

        # add id, likelihood, and platform to CWEs table and CWE id, name, and
        # title to TaxonomyEntries
        subprocess.check_call(
            "fgrep '|' ./cwe.all.org" +
            " | python ./csv2sql.py --input org CWEs 1" +
            " | sqlite3 " + args.database, shell=True)

        # Add properties maps
        checker_id = 0
        taxCheckerLinks = dict()
        chkrs = dict()
        mappings = dict()
        for property_map in glob.iglob(platform + ".*.properties"):

            # Must get tool ids associated with this file
            parse = re.match(
                r"([^.]*)\.([^.]*)\.([^.]*\.)?properties", property_map)
            if (parse is None):
                raise Exception("invalid tool name")
            # parse.group(1) is platform, we already have that
            property_tool = parse.group(2)

            if parse.group(3) is None:
                regex_arg = "0"
            if parse.group(3) == "re.":
                regex_arg = "1"
            elif parse.group(3) == "cwe.":
                regex_arg = "0"

            cur.execute(
                "SELECT id FROM Tools WHERE name=? AND platform=?",
                [property_tool, platform])
            row = cur.fetchone()

            other_tool_id = row[0]
            with open(property_map, "r") as f:
                contents = f.read()
                for line in contents.split("\n"):
                    if line.split() != [] and line[0] != "#":
                        line = line.split(":")

                        checker = line[0].strip()
                        taxEntry = line[1].split(",")

                        # create checker name to
                        # checker id mapping
                        if checker not in mappings:
                            if len(taxEntry) == 1 \
                               and taxEntry[0].strip() == "NONE":
                                continue
                            mappings[checker] = checker_id
                            checker_id += 1

                        # for taxonomyCheckerLinks
                        # table
                        if mappings[checker] not in taxCheckerLinks:
                            for i in range(0, len(taxEntry)):
                                taxEntry[i] == taxEntry[i].strip()
                                if taxEntry[i] == "NONE":
                                    continue
                                if i == 0:
                                    taxCheckerLinks[
                                        mappings[checker]] = [taxEntry[i]]
                                else:
                                    taxCheckerLinks[
                                        mappings[checker]].append(taxEntry[i])
                            # taxCheckerLinks[mappings[checker]].append(taxEntry)

                        else:
                            for cwecert in taxEntry:
                                cwecert = cwecert.strip()
                                if cwecert == "NONE":
                                    continue
                                if cwecert not in \
                                   taxCheckerLinks[mappings[checker]]:
                                    taxCheckerLinks[
                                        mappings[checker]].append(cwecert)
                                    # for checkers table
                        if checker not in chkrs:
                            chkrs[checker] = [
                                str(mappings[checker]),
                                checker,
                                str(other_tool_id),
                                regex_arg]

        for item in chkrs:
            values = chkrs[item]
            values[1] = "'" + values[1] + "'"
            statement = "INSERT INTO Checkers VALUES(" + ",".join(values) + ")"
            cur.execute(statement)

        cur.execute("SELECT * from TaxonomyEntries")
        taxEntries = dict()
        for entry in cur.fetchall():

            tax_id = entry[0]
            name = entry[1]
            taxEntries[name] = tax_id
        for item in taxCheckerLinks:
            for multiple in taxCheckerLinks[item]:
                multiple = multiple.strip()
                if multiple in taxEntries:
                    mult = taxEntries[multiple]
                    statement = "INSERT INTO TaxonomyCheckerLinks VALUES(" \
                                + str(mult) + "," + str(item) + ")"
                    cur.execute(statement)


# Connect to db & get platform
con = None
con = sqlite.connect(args.database)

with con:
    cur = con.cursor()
    cur.execute(
        "SELECT platform, name FROM Tools WHERE id=?", [int(args.tool)])
    row = cur.fetchone()
    if row is None:
        raise Exception("Invalid tool number")
    platform = row[0]
    tool_name = row[1]

    # Clean db of any preexisting messages
    if "TRUE" == os.environ["VERBOSE"]:
        print "Cleaning database " + args.database \
            + " of diagnostics for tool " + args.tool
    if not platform == "metric":  # metrics are cleaned by creation operation
        cur.execute(
            "DELETE FROM Messages WHERE id IN " +
            "(SELECT Messages.id FROM Messages, Diagnostics, Checkers " +
            " WHERE Messages.diagnostic=Diagnostics.id " +
            " AND Diagnostics.checker=Checkers.id " +
            " AND Checkers.tool = ?);", [int(args.tool)])
        cur.execute(
            "DELETE FROM MetaAlerts WHERE id IN " +
            "(SELECT MetaAlerts.id FROM MetaAlerts, " +
            "  DiagnosticMetaAlertLinks, Diagnostics, Checkers " +
            " WHERE DiagnosticMetaAlertLinks.diagnostic=Diagnostics.id " +
            " AND DiagnosticMetaAlertLinks.meta_alert_id=MetaAlerts.id " +
            " AND Diagnostics.checker=Checkers.id " +
            " AND Checkers.tool = ?);", [int(args.tool)])
        cur.execute(
            "DELETE FROM DiagnosticMetaAlertLinks WHERE diagnostic IN " +
            "(SELECT Diagnostics.id FROM Diagnostics, Checkers " +
            " WHERE Diagnostics.checker=Checkers.id " +
            " AND Checkers.tool = ?);", [int(args.tool)])
        cur.execute(
            "DELETE FROM Diagnostics WHERE id IN " +
            "(SELECT Diagnostics.id FROM Diagnostics, Checkers " +
            " WHERE Diagnostics.checker=Checkers.id " +
            " AND Checkers.tool = ?);", [int(args.tool)])


# Sanitize input file to remove |
if "TRUE" == os.environ["VERBOSE"]:
    print "Adding diagnostics to database"

if platform == "metric":
    # load metric data
    subprocess.check_call(
        "python ./" + tool_name + "2sql.py < " + args.input +
        " | sqlite3 " + args.database,
        shell=True)

else:
    # load entries into Diagnostics, Messages, and MetaAlerts tables
    extract.extract_measurements(
        tool_name, int(args.tool), args.input, args.database)

    # Fix path names
    if "TRUE" == os.environ["VERBOSE"]:
        print "Canonicalizing path names"
    subprocess.check_call("python ./fix_path.py " + args.database + " \"" +
                          "\":\"".join(args.source) + "\" " +
                          args.tool + " \"" +
                          "\" \"".join(args.map) + "\"",
                          shell=True)

    # Add Meta-alerts & determination info
    with con:
        cur = con.cursor()
        if "TRUE" == os.environ["VERBOSE"]:
            print "Creating meta-alerts"
        meta_alerts = dict()
        # Fill meta_alerts with info from all diagnostics laking meta alerts
        # Oh...and create new MetaAlerts for each one
        cur.execute("""
SELECT DISTINCT Messages.line, Messages.path, TaxonomyCheckerLinks.taxonomy_id,
        DiagnosticMetaAlertLinks.meta_alert_id FROM Diagnostics
    JOIN Messages ON Messages.id = Diagnostics.primary_msg
    JOIN Checkers ON Checkers.id = Diagnostics.checker
    JOIN TaxonomyCheckerLinks ON Checkers.id=TaxonomyCheckerLinks.checker
    LEFT JOIN DiagnosticMetaAlertLinks
        ON DiagnosticMetaAlertLinks.diagnostic=Diagnostics.id
    WHERE Checkers.tool=?
""", [args.tool])
        for [line, path, tax_id, meta_alert] in cur.fetchall():
            if meta_alert is None:
                cur.execute(
                    "INSERT INTO MetaAlerts VALUES( \
			NULL, 0, 0, 0, 0, 0, 0, 0, 0, ?)", [tax_id])
                meta_alert = cur.execute(
                    "SELECT last_insert_rowid();").fetchone()[0]
            meta_alerts[(line, path, tax_id)] = meta_alert

        # Now add diag-metaalert-links and determinations
        if "TRUE" == os.environ["VERBOSE"]:
            print "Adding determinations"
        cur.execute("""
SELECT DISTINCT Diagnostics.id, Messages.line, Messages.path, TaxonomyCheckerLinks.taxonomy_id
    FROM Diagnostics
    JOIN Messages ON Messages.id = Diagnostics.primary_msg
    JOIN Checkers ON Checkers.id = Diagnostics.checker
    JOIN TaxonomyCheckerLinks ON Checkers.id=TaxonomyCheckerLinks.checker
    WHERE Checkers.tool=?
""", [args.tool])
        for [diag_id, line, path, tax_id] in cur.fetchall():
            meta_alert = meta_alerts[(line, path, tax_id)]
            cur.execute("INSERT INTO DiagnosticMetaAlertLinks" +
                        " VALUES( ?, ?)", [diag_id, meta_alert])

    # Make sure each diagnostic has a checker associated with a secure coding
    # rule
    if "TRUE" == os.environ["VERBOSE"]:
        print "Fixing checker names"
    subprocess.check_call(
        "sqlite3 " + args.database +
        " 'UPDATE Diagnostics SET checker = NULL" +
        " WHERE (SELECT taxonomyEntries.name FROM taxonomyEntries " +
        " JOIN taxonomyCheckerLinks"
        " ON TaxonomyCheckerLinks.taxonomy_id = TaxonomyEntries.id " +
        " JOIN Checkers ON Checkers.id = TaxonomyCheckerLinks.checker " +
        " WHERE Diagnostics.checker = Checkers.name) = \"SPECIAL\"'",
        shell=True)
    subprocess.check_call(
        "sqlite3 " + args.database + " < regexpendprop.sql", shell=True)

    # checker_error_output = subprocess.check_output(
    #    "sqlite3 " + args.database + " 'SELECT * FROM Diagnostics " +
    #    " JOIN Messages ON Diagnostics.primary_msg = Messages.id " +
    #    " LEFT OUTER JOIN Checkers ON Diagnostics.checker = Checkers.id " +
    #    " WHERE Diagnostics.tool = " + args.tool +
    #    " AND Checkers.rule IS NULL " +
    #    " OR Checkers.rule = \"SPECIAL\"'", shell=True)

    # if "" != checker_error_output:
    #    print >> sys.stderr, "[Warning] The following diagnostics ",
    #    " have no known checker associated with them:"
    #    for error_diagnostic in checker_error_output.split("\n"):
    #        fields = error_diagnostic.split("|")
    #        if 1 < len(fields):
    #            print >> sys.stderr, "Checker: " + \
    #                fields[4] + "   Location: " + fields[9] + \
    #                ":" + fields[10] + "   Message: " + fields[11]
    #

if "TRUE" == os.environ["VERBOSE"]:
    print "Done!"
