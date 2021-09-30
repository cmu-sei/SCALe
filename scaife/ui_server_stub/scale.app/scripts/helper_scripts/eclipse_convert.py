#!/usr/bin/env python3
#
# This script takes a path of an Eclipse command-line output file,
# and converts to a tab-separated file for SCALe use.
#
# To run this script use the following command on the terminal:
#   python3 eclipse_covert.py <path-to-raw-file> <desired-path-for-tsv-file>
#
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

import argparse


def get_path(each_line):
    start = each_line.find("/")
    end = each_line.rfind("/")

    return each_line[start:end]

def get_resource(each_line):
    start = each_line.rfind("/") + 1  # +1 to get rid of / in front
    end = each_line.rfind("(") - 1

    return each_line[start:end]

def get_location(each_line):
    start = each_line.rfind("line")

    return each_line[start:-2]  # return line # except \n and ) at the end

def get_type(each_line):
    if ("pom.xml" in each_line):
        return "Maven pom Loading"
    else:
        start = each_line.rfind(".") + 1
        end = each_line.rfind("(") - 1
        suffix = each_line[start:end]

        if (suffix == "js"):
            return "Javascript"
        elif (suffix == "java"):
            return "Java"
        else:
            return suffix.upper()


def convert():
    arg_parser = argparse.ArgumentParser(
                description="Convert from command-line raw file to tab-separated file")
    arg_parser.add_argument("raw_output", help="command-line raw output file path")
    arg_parser.add_argument("tab_separated_output", help="tab-separate output file path")
    args = arg_parser.parse_args()

    txt_file = open(args.raw_output, 'r')
    converted = open(args.tab_separated_output, 'w')

    description = ["Description"]
    resource = ["Resource"]
    path_error = ["Path"]
    location = ["Location"]
    type_error = ["Type"]

    count = 1

    while (True):
        each_line = txt_file.readline()

        if (each_line == ''):
            break  # break when it reaches end

        elif (each_line[0] == '-' or each_line[0] == '\t'):
            continue

        elif (each_line[0].isdigit()):
            if (('ERROR' in each_line) or ('WARNING' in each_line)):
                path_error.append(get_path(each_line)) # PATH
                location.append(get_location(each_line))  # LOCATION
                type_error.append(get_type(each_line) + " Problem")  # TYPE
                resource.append(get_resource(each_line))  # RESOURCE
            else:
                total = each_line[:-1]
                break  # reached end of file

        else:
            # DESCRIPTION
            description.append(each_line[:-2]) # -1 to get rid of ' \n' at the end

        count += 1



    # length of type_error == length of path_error, location, resource, and description
    for i in range(len(type_error)):
        converted.write(type_error[i] + '\t' + path_error[i] + '\t'
                       + description[i] + '\t' + location[i] + '\t'
                       + resource[i] + '\n')

    print("Original file had: %s" % total)
    print("Number of error messages converted to new file: %d messages" % (len(type_error)-1))


convert()
