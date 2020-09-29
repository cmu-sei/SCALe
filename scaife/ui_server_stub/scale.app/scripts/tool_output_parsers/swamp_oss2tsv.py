#!/usr/bin/env python

# <legal>
# SCALe version r.6.2.2.2.A
# 
# Copyright 2020 Carnegie Mellon University.
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

'''
Python script that parses SWAMP Common Assessment Result Format (SCARF) v1.4.1 output.

    Args:
        input_file: SWAMP Common Assessment Result Format (SCARF) file to parse
        output_file: Destination for the parsed alert data.

    SWAMP's SCARF output files are agnostic of tool and will need more information to process the data
    in SCALe than the other parser files. Features like tool name and version must be captured to identify
    the appropriate tool in SCALe to associate these alerts with.
'''

import sys
import xml.etree.ElementTree as ET

from toolparser import tool_parser_args

def process_file(input_file, output_file):
    try:
        tree = ET.parse(input_file)
    except:
	    raise Exception("An error occured while parsing the input file. Ensure it's a SCARF xml file.\n")

    root = tree.getroot()

    #Get tool name and version information:
    tool_name = root.get('tool_name')
    tool_version = root.get('tool_version')
    platform = root.get('platform_name')

    for buginstance in root.iter('BugInstance'):
        file_path = ""
        line_number = ""

        #use the bug code for checker id.
        checker = buginstance.find('BugCode').text

        primary_message = buginstance.find('BugMessage').text.split('\n')[0].strip().replace("\t", " ")

        #scarf also outputs specific tool CWE IDs but not for all alerts
        #checker = buginstance.find('CweId')

        for location in buginstance.iter('Location'):
            secondary_messages = ""

            temp_filepath = location.find('SourceFile').text
            temp_line_number = location.find('StartLine').text
            temp_message = location.find('Explanation')

            if location.get('primary') == "true":
                filepath = temp_filepath
                line_number = temp_line_number
            else:
                if temp_message is not None: #explanation for this location is present
                    secondary_messages += "\t".join([temp_filepath, temp_line_number, temp_message.text.split('\n')[0].strip().replace("\t", " ")]) #<filepath>, <line number>, <message>
                else:
                    secondary_messages += "\t".join([temp_filepath, temp_line_number, primary_message]) #use the primary message if the explanation doesn't exist

        column_values = "\t".join([checker, filepath, line_number, primary_message]) #<checker>, <filepath>, <line number>, <message>

        output_file.write(column_values + "\n")

      #  if secondary_messages is not None:
      #      output_file.write("\t" + secondary_messages)


if __name__ == "__main__":
    args = tool_parser_args()

    input_fh = open(args.input_file, "r")
    output_fh = open(args.output_file, "w")

    process_file(input_fh, output_fh)
