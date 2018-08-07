#!/usr/bin/env python

# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import os
import csv
from time import gmtime, strftime

ERROR_FILE = "error_log.txt"
WHITELIST = ["VIOLATION", "LDRA CODE", "STANDARDS", "NAME", "MODIFICATION",
             "CODE", "SRC", "LINE", "FILE", "Standards Violation Summary",
             "Include Hierarchy"]


def log_error(err):
    f = open(ERROR_FILE, "a")
    time = strftime("%Y-%m-%d %H:%M:%S", gmtime())
    err_str = time + ":\t" + err + "\n"
    print err_str
    f.write(err_str)
    f.close()

# Produces checker to message mappings


def m2c(content_lines):
    c2msg = {}
    rule_lines = []
    placeholder_found = 0

    for line in content_lines:
        # the next line after the placeholder needs to be ignored
        if placeholder_found == 1:
            placeholder_found = 2
            continue

        if placeholder_found == 2 and line.strip() != "":
            rule_lines.append(line.strip())

        if placeholder_found == 2 and line.strip() == "":
            placeholder_found = 0

        if WHITELIST[0] in line and WHITELIST[1] in line and WHITELIST[2] in line:
            placeholder_found = 1

    # not all rule mappings need to be used,
    # so the ones with 0 violations are removed
    for rules in rule_lines:
        # Num of violations, checker and message are separated by 8 spaces
        rule_list = rules.split("        ")

        num_violations = rule_list[0].strip()
        checker = rule_list[1].strip()
        msg = rule_list[2].strip()

        if msg[0] == "*":
            msg = msg[1:].strip()

        if num_violations == "-" or int(num_violations) == 0:
            continue

        c2msg[msg] = checker

    return c2msg


def f2p(content_lines):
    f2path = {}
    placeholder_found = 0

    for line in content_lines:
        # the next line after the placeholder needs to be ignored
        if placeholder_found == 1:
            placeholder_found = 2
            continue

        if placeholder_found == 2 and line.strip() != "" and "." in line:
            file_line = line.strip()

            if "\\" in file_line:
                file_list = file_line.split("\\")
                f2path[file_list[-1]] = file_line

            if "/" in file_line:
                file_list = file_line.split("/")
                f2path[file_list[-1]] = file_line

        if placeholder_found == 2 and line.strip() == "":
            placeholder_found = 0

        if WHITELIST[3] in line and WHITELIST[4] in line:
            placeholder_found = 1

    skipped = 0
    placeholder_found = 0
    blank_lines = 0
    i = 0

    # searching for the include hierarchy
    for index, line in enumerate(content_lines):

        if WHITELIST[10] in line and placeholder_found == 0:
            index = index + 4
            placeholder_found = 1
            continue

        if placeholder_found == 1:
            if skipped < 5:
                skipped += 1
                continue

            if line.strip() == "":
                blank_lines += 1
                if blank_lines == 2:
                    placeholder_found = 0
                else:
                    continue

            blank_lines = 0

            # 9 spaces between Yes Ok No. So if split is done using 10 spaces
            # Yes Ok and No will all be a single value of the list
            include_list = line.strip().split("             ")
            include_list = [x for x in include_list if x]

            if len(include_list) < 3:
                continue

            file_name = include_list[0].strip()
            path = include_list[2].strip()

            if file_name in f2path.keys():
                continue

            f2path[file_name] = path

    return f2path


def create_checker_list(content_lines, msg2checker, file2path):

    checker_list = {}

    placeholder_found = 0

    for line in content_lines:
        if placeholder_found == 1:
            placeholder_found = 2
            continue

        if WHITELIST[0] in line and WHITELIST[5] in line and WHITELIST[6] in line\
                and WHITELIST[7] in line and WHITELIST[8] in line:
            placeholder_found = 1

        if placeholder_found == 2:

            if line.strip() == "":
                placeholder_found = 0

            else:
                violation_list = line.strip().split(" ")
                violation_list = [x for x in violation_list if x]

                if len(violation_list) < 3:
                    continue

                msg = " ".join(violation_list[3:]).strip()
                line = violation_list[2]
                file_name = violation_list[1][:-1]

                # for some files path name may not be available
                if file_name not in file2path.keys():
                    path = file_name
                else:
                    path = file2path[file_name]

                if not (msg in msg2checker.keys() or msg[:(msg.find(".") + 1)]
                        in msg2checker.keys()):
                    if "." in msg:
                        msg = msg[:(msg.find(".") + 1)]

                    log_error("Message not found: " + msg)
                    sys.exit(-1)

                if "." in msg:
                    msg_checker = msg[:(msg.find(".") + 1)]
                else:
                    msg_checker = msg

                checker = msg2checker[msg_checker]

                if checker not in checker_list.keys():
                    checker_list[checker] = []

                checker_list[checker].append(
                    "|" + path + "|" + line + "|" + msg)

    placeholder_found = 0
    file_name_found = 0
    i = 0
    j = 0

    # diagonstics for indvidual files are also available
    # removing the intro lines
    for index, line in enumerate(content_lines):
        if WHITELIST[9] == line.strip():
            file_line = content_lines[index - 5]

            # get file name
            file_list = file_line.split(" ")
            file_list = [x for x in file_list if x]

            # if the file name is parsed correctly it should have ")" as
            # the ending character
            if ")" not in file_list[4]:
                log_error("Error in file name: " + file_line)
                sys.exit(-1)

            file_name = file_list[4][:-1]

            if file_name not in file2path.keys():
                path = file_name
            else:
                path = file2path[file_name]

            # get violations
            for violation_line in content_lines[index + 5:]:
                if violation_line.strip() == "":
                    break

                violation_list = violation_line.split("  ")
                violation_list = [x for x in violation_list if x]

                if len(violation_list) < 3:
                    continue

                line = violation_list[1]
                msg = violation_list[2]

                if msg.split(":")[0].strip() not in msg2checker.keys():
                    log_error(
                        "Message not found: " + msg.split(":")[0].strip())
                    sys.exit(-1)

                checker = msg2checker[msg.split(":")[0].strip()]

                if checker not in checker_list.keys():
                    checker_list[checker] = []

                checker_list[checker].append(
                    "|" + path + "|" + line + "|" + msg)

    return checker_list


def process_file(input_file):
    f = open(input_file)
    content = f.read()
    f.close()
    content_lines = content.splitlines()

    msg2checker = {}
    msg2checker = m2c(content_lines)

    file2path = {}
    file2path = f2p(content_lines)

    checker = create_checker_list(content_lines, msg2checker, file2path)
    print_checker_list(checker)


def print_checker_list(checker):

    for key, value in checker.items():
        for items in value:
            key = key.replace(" ", "_")
            print "|" + key + items + "| \n"


def usage():
    print "python ldra2csv.py annotated_source"


def main(argv=None):
    if len(sys.argv) < 2:
        log_error("usage error")
        usage()
        sys.exit(-1)

    c_annotated = sys.argv[1]
    process_file(c_annotated)

if __name__ == "__main__":
    main()
