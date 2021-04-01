#!/usr/bin/env python

# Script converts MSVS code analysis and/or compiler warnings to MSVC format
#
# Example code analysis input format:
#
#C6326	Constant constant comparison	Potential comparison of a constant with another constant.	CWE114_Process_Control	cwe114_process_control__w32_char_connect_socket_03.c	50
#
# Example compiler warnings input format:
#
# Warning,3,warning C4127: conditional expression is constant,c:\juliet_test_suite_v1.2_for_c_cpp\testcases\cwe467_use_of_sizeof_on_pointer_type\cwe467_use_of_sizeof_on_pointer_type__int_02.c,22,1,CWE467_Use_of_sizeof_on_Pointer_Type
#
# Example alert output format:
#
# c:\documents and settings\administrator\desktop\jasper-1.900.1\src\libjasper\bmp\bmp_dec.c(154) : warning C4244: '=' : conversion from 'int' to 'uint_fast16_t', possible loss of data
#
# Example secondary message output format (eight spaces precede the file_path):
#
#         .\TestPpmApplication.cpp(11) : see declaration of '???'
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

import os
import sys
import csv
import argparse

names2paths = {}


def usage():
    print("Script converts MSVS code analysis and/or compiler warnings to MSVC format")
    print("usage: python msvs2msvc.py -test_suite [test_suite_directory] -code_analysis [code_analysis_input_file] -compiler_warnings [compiler_warnings_input_file] -output_file [output_file]")
    print("example: python msvs2msvc.py -test_suite Juliet_Test_Suite_v1.2_for_C_Cpp -code_analysis msvs/JulietMSVSCodeAnalysis.txt -compiler_warnings msvs/JulietMSVSCompilerWarnings.csv -output_file juliet_msvc.txt")


def getFilePath(file_name):
    if(file_name in names2paths):
        file_path = names2paths[file_name]
    else:
        #cannot map file name to file path; use file name
        file_path = file_name
    return (file_path)


def extractCodeAnalysis(input_file, output_file):
    """From the file containing code analysis, this function extracts the checker, message, secondary messages, file_name, and line_number."""
    csv_reader = csv.reader(input_file, delimiter='\t')

    previous_file_path = ""
    for columns in csv_reader:
        if(len(columns) < 2):
            continue

        checker = columns[0]
        message = columns[2]
        line_number = columns[5]

        if(checker != ""):
            file_name = columns[4].lower()
            file_path = getFilePath(file_name)
            previous_file_path = file_path #set previous_file_path needed to create secondary message output
            alert_output_format = "{}({}) : warning {}: {}\n" #define the alert output format; this format is compatible with msvc2org.py
            output_line = alert_output_format.format(file_path, line_number, checker, message)
        else:
           #the checker field is blank, so this is a secondary message
           secondary_message_output_format = "        {}({}) : {}\n" #define the secondary message output format; this format is compatible with msvc2org.py
           output_line = secondary_message_output_format.format(file_path, line_number, message)
        output_file.write(output_line)


def extractCompilerWarnings(input_file, output_file):
    """From the file containing compiler warnings, this script extracts the checker, message, file_path, and line_number."""
    csv_reader = csv.reader(input_file, delimiter=',')

    for columns in csv_reader:
        file_path = columns[3]
        line_number = columns[4]
        severity_and_checker, message = columns[2].split(": ", 1)
        output_format = "{}({}) : {}: {}\n" #define the alert output format; this format is compatible with msvc2org.py
        output_line = output_format.format(file_path, line_number, severity_and_checker, message)
        output_file.write(output_line)


def getArguments():
    """Returns the set of command line arguments."""
    parser = argparse.ArgumentParser()
    parser.add_argument("-test_suite", "--test_suite_directory", help="Test suite directory path")
    parser.add_argument("-code_analysis", "--code_analysis_input_file", help="Code analysis input file path")
    parser.add_argument("-compiler_warnings", "--compiler_warnings_input_file", help="Compiler warnings input file path")
    parser.add_argument("-output_file", "--output_file", help="Output file name")
    return parser.parse_args()


if __name__=="__main__":

    if len(sys.argv) < 4:
        usage()
        sys.exit(-1)

    args = getArguments() #retrieve command line arguments

    TEST_SUITE_DIR = args.test_suite_directory
    CODE_ANALYSIS = args.code_analysis_input_file
    COMPILER_WARNINGS = args.compiler_warnings_input_file
    OUTPUT_FILE = open(args.output_file, "w")

    #Create a mapping from file names to file paths using the provided tool output package
    for (dirpath, dirnames, filenames) in os.walk(TEST_SUITE_DIR):
        for fname in filenames:
            file_path = os.path.join(dirpath, fname)
            # Convert both the file name and file path to lowercase, which is needed for compatibility with the file names that appear in the code analysis input file
            file_path = file_path.lower()
            fname = fname.lower()
            names2paths[fname] = file_path
    if(CODE_ANALYSIS != None):
        extractCodeAnalysis(open(CODE_ANALYSIS, "r"), OUTPUT_FILE)
    if(COMPILER_WARNINGS != None):
        extractCompilerWarnings(open(COMPILER_WARNINGS, "r"), OUTPUT_FILE)
