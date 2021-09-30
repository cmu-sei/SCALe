#!/usr/bin/env python

# Python script that scrubs cppcheck alerts.
#
# The first argument indicates the file containing the input.
# The second argument specifies the output file.
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

import sys
import re
import xml.etree.ElementTree as ET

from toolparser import tool_parser_args

def is_not_empty(generator):
    '''
        Method to check if the generator has items to iterate over
    '''
    try:
        item = next(generator)
    except StopIteration:
        return False
    return True
           

def process_cppcheck_file(root, output_fh):
    '''
        SCALe-style input consists of alerts, one per line, each of the form separated by tabs:
            <checker>    <file_path>    <line_number>    <message>
        Since cppcheck alerts map to a single source file line, 
        we just have 4 elements per line (i.e., no secondary messages).
        i.e., checker_id     source_file_path    line_number    alert message
    '''
    for node in root.iter("error"):
        checker = node.get("id")
        message = node.get("msg")
        message = message.strip().replace('\t', " ")

        if is_not_empty(node.iter("location")):
            for location in node.iter("location"): # Some files have multiple location tags
                if location is None:
                    continue

                file_path = location.get("file")

                if file_path is None or "" == file_path.strip():
                    continue
                
                line_number = location.get("line")
                
                column_values = "\t".join([checker, file_path, line_number, message])
                output_fh.write(column_values + "\n")
        else:
            # All information is inside of error tag for older versions of cppcheck
            file_path = node.get("file")
            line_number = node.get("line")
            
            if file_path is None or "" == file_path.strip():
                continue

            column_values = "\t".join([checker, file_path, line_number, message])
            output_fh.write(column_values + "\n")
             

def process_file(input_file, output_fh):

    try:
        tree = ET.parse(input_file)
    except:
        raise Exception("An error occurred while parsing the input file. Ensure it's a cppcheck xml file.\n")

    root = tree.getroot()
    
    if root.tag == "arbitrary-root": # File was created by the cat_tool_output script
        for real_root in root.iter("results"):
            process_cppcheck_file(real_root, output_fh)
    else:
        process_cppcheck_file(root, output_fh)


if __name__ == "__main__":
    args = tool_parser_args()

    input_fh = open(args.input_file, "r")
    output_fh = open(args.output_file, "w")

    process_file(input_fh, output_fh)
