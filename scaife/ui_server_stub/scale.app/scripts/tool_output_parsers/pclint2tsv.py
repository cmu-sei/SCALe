#!/usr/bin/env python

# Python script that scrubs pclint alerts.
#
# The first argument indicates the file containing the input.
# The second argument specifies the output file.
#
# This script can produce lots of messages per alert
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
import re

from toolparser import tool_parser_args

def process_result_file(input_file, output_file):
    """Parses a customized PCLint format into alerts.

    The format of the alerts is a little unfortunate. There ought to be tabs
    delimiting the fields, but that seems to not be the case. Instead, fields
    are whitespace delimited. There are four fields in each alert, in this order:

    Filename, Line Number, Alert ID, and Message

    Args:
        input_file(file): A file or file-like object containing the alerts.

    Returns:
        list: A list of model.Alert objects
    """

    for line in input_file:
        # Using a regex because splitting by spaces might die if a
        # filename has spaces in it. A really weird filename might
        # still mess up this regex.
        match = re.match("^(.*\.\w*)\s*([0-9]+)\s*([0-9]+)\s*(.*)$", line)
        if match is None:
            continue

        file_path = match.group(1)
        line_number = match.group(2)
        checker = match.group(3)
        message = match.group(4).split("[")[0].strip() #remove reference file info from message

        if message.lower().startswith("reference cited in prior message"):
            continue

        # Note: No need to check for duplicates, because the next command issued from digest_alerts.py (sort -u) does so
        message = message.strip().replace("\t", " ")
        column_values = "\t".join([checker, file_path, line_number, message])
        output_file.write(column_values + "\n")


def adjustPrimaryMessage(line_file_parse):
    message_front = line_file_parse.group(1)
    message_front = re.split("\d:\s", message_front)[1].strip()
    message_back = line_file_parse.group(4).strip()
    message = message_front + " link" + message_back
    return message


def process_file(input_file, output_file):
    """
    Example line formats parsed by the regular expressions:

    ..\libjasper\base\jas_cm.c(518): error 414: (Warning -- Possible division by 0 [Reference: file ..\libjasper\base\jas_cm.c: line 507] [MISRA 2004 Rule 1.2])

    ..\libjasper\base\jas_icc.c(783): error 774: (Info -- Boolean within 'if' always evaluates to False [Reference: file ..\libjasper\base\jas_icc.c: lines 761, 771] [MISRA C++ Rule 0-1-1, 0-1-2], [MISRA C++ Rule 0-1-9])

..\libjasper\jpc\jpc_dec.c(456): error 613: (Warning -- Possible use of null pointer 'compinfo' in left argument to operator '->' [Reference: file ..\libjasper\base\jas_malloc.c: line 106; file ..\libjasper\jpc\jpc_dec.c: lines 452, 454])
    """
    # Define regular expressions
    alert_regex = re.compile("(.*?)(?:\(?)(\d+)(?:\):\s?)error (\d+): (.*)")
    reference_file_regex = re.compile("(.*?Reference: )file (.*?): line(?:s?) (\d+(?:, \d+)*)(].*)")
    line_file_regex = re.compile("(.*)line (\d+), file ([^\[),]+)(.*)") # to ensure file paths are valid, any character that is NOT " ", ")", or "[" is considered part of the file path string

    for line in input_file:

        alert_parse = re.match(alert_regex, line)
        if alert_parse == None:
            continue

        file_path = alert_parse.group(1).strip()
        line_number = alert_parse.group(2).strip()
        checker = alert_parse.group(3).strip()
        message = alert_parse.group(4).strip()

        # If the message contains a second set of file/line numbers, place this information in a second column.
        secondary_messages = ""

        reference_file_parse = re.match(reference_file_regex, line)

        if reference_file_parse != None:
            # matches reference_file_regex
            message = adjustPrimaryMessage(reference_file_parse)
            # handle one or more reference entries...
            # E.g., "file ..\libjasper\base\jas_malloc.c: line 106; file ..\libjasper\jpc\jpc_dec.c: lines 452, 454")
            references = re.findall(reference_file_regex, line)
            for entry in references:
                secondary_message_line_number = entry[2].strip()
                secondary_message_file_path = entry[1].strip()
                lines = secondary_message_line_number.split(", ")
                for l in lines:
                    secondary_messages += secondary_message_file_path + "\t" + l + "\t \t"
        else:
            # matches line_file_regex
            line_file_parse = re.match(line_file_regex, line)
            if line_file_parse != None:
                message = adjustPrimaryMessage(line_file_parse)
                secondary_message_line_number = line_file_parse.group(2).strip()
                secondary_message_file_path = line_file_parse.group(3).strip()
                secondary_messages += secondary_message_file_path + "\t" + secondary_message_line_number + "\t \t"

        message = message.strip().replace("\t", " ")
        column_values = "\t".join([checker, file_path, line_number, message])
        if("" != secondary_messages):
            column_values += "\t" + secondary_messages
        output_file.write(column_values + "\n")


if __name__ == "__main__":
    args = tool_parser_args()

    input_fh = open(args.input_file, "r")
    output_fh = open(args.output_file, "w")

    if args.input_file[-7:] == ".result":
        # call a different function to process .result files
        process_result_file(input_fh, output_fh)
    else:
        process_file(input_fh, output_fh)
