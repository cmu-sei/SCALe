# This script adds a timestamp to the tox test XML output.
# This is so the continuous integration (CI) automated test results
# can be used in one of the formats our CI system handles.
# It adds the date/time in ISO 8601 format to the element with tag "testsuite"
# in the XML file, as the attribute of attribute/value pair with value "timestamp".
# This script also "prettifies" the XML.
#
# Input parameters: input_filepath output_filename
# Note that input_filepath must be the full filepath

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

import argparse
import os
from bs4 import BeautifulSoup
import time
from datetime import date, datetime


def addDataAndFormatXml(in_filepath, out_filename):
    dir_path,in_file = os.path.split(in_filepath)
    out_filepath = os.path.join(dir_path, out_filename)

    with open(in_filepath) as fp:
        soup = BeautifulSoup(fp, "xml")

        # wrap tag "testsuite" with new tag "testsuites"
        new_tag = soup.new_tag("testsuites")
        testSuiteTag = soup.find('testsuite')
        testSuiteTag.wrap(new_tag)
        
        # get current datetime in ISO 8601 format but remove any microseconds
        dateTime = datetime.utcnow().replace(microsecond=0).isoformat()
        testSuiteTag['timestamp']=dateTime

        # write out to new file, with prettified format
        pretty_xml = soup.prettify()
        with open(out_filepath, "w") as edited_fp:
            edited_fp.write(pretty_xml)
        
    return

def main():
    """This script adds a timestamp to the tox test XML output.
    It adds the date/time in ISO 8601 format to the element with tag of testsuite
    in the XML file, as the attribute of attribute/value pair with value of timestamp.
    The new edited file gets written to the same directory as the original file. This 
    script also reformats the file per requirements and adds beginning and end tags for testsuites.
    This is so the continuous integration (CI) automated test results
    can be used in one of the formats our CI system handles.

    Args:
        input_filepath (filepath): Filepath with tox XML output file. Note this must be the full filepath.
        output_file (filename): Filename to write edits to. (Same directory as original file)

    Returns:    
        None
    """

    # Define the CLI
    arg_parser = argparse.ArgumentParser(
        description="Adds ISO 8601 formatted date/time to tox test XML output file, and writes that to new file in same directory. Script also reformats file per requirements and adds beginning and end tags for testsuites.")
    arg_parser.add_argument("input_filepath", help="FilePATH with tox XML output file. Note it must be the full filepath including the file.")
    arg_parser.add_argument("output_filename", help="FileNAME to write edits to")

        
    args = arg_parser.parse_args()

    if args.input_filepath:
       addDataAndFormatXml(args.input_filepath, args.output_filename)

        

if __name__ == "__main__":
    main()





