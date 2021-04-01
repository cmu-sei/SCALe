#!/usr/bin/env python

# Script takes an Eclipse text output file and extracts its alert
# information
#
# The first argument indicates the file containing the input.
# The second argument specifies the output file.
#
# The data could be produced in one of the following ways:
#  1) from Eclipse's Problems tab:
#   After building a project, select the warnings to save,
#   copy and past them into a text editor, and save it.
#  2) from Terminal command-line:
#   First, install ecj.jar file from 'Using the Batch Compiler' section
#   in Eclipse documentation. Run following command on Terminal:
#   java -jar <PATH_TO_ECJ_FILE> -warn:all <PATH_TO_FILE_TO_COMPILE> &>output
#   Then, using the output file, run eclipse_convert.py.
#
# This script never produces more than one message per alert
#
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

import sys
import csv

from toolparser import tool_parser_args

def processFile(input_file, output_file):

    for columns in input_file:
        error_type = columns[0]
        if "Java Problem" != error_type: # handle malformed tool output (e.g., header rows interspersed with data)
            continue
        directory = columns[1]
        message = columns[2]
        message = message.strip().replace("\t", " ")
        line_number = columns[3].split("line ")[1]
        file_name = columns[4]
        file_path = directory + "/" + file_name
        column_values = "\t".join(["", file_path, line_number, message])
        output_file.write(column_values + "\n")


if __name__ == "__main__":
    args = tool_parser_args()

    input_fh = open(args.input_file, "r")
    output_fh = open(args.output_file, "w")

    tsv_reader = csv.reader(input_fh, delimiter='\t')

    processFile(tsv_reader, output_fh)
