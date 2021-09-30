#!/usr/bin/env python

#Script combines tool output contained in INPUT_DIR, which references a directory (and subdirectories)
#The single file that will contain the concatenated output is specified by the OUTPUT_FILE variable.
#
#IMPORTANT: When processing a directory of ldra output, the file extension of OUTPUT_FILE must be ".rpf"
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

import os
import sys

def usage():
    print("Script performs simple concatenation of output files from static analysis tools by recursively " +
          "searching through subdirectories for files.  For LDRA only: (1) the script contatenates only .rpf " +
          "files, and (2) the input directory must be named 'ldra'.")
    print("usage: python cat_tool_output.py tool_name input_dir output_file")
    print("example: python cat_tool_output.py ldra /ldra_dir ldra_output_combined.rpf")


if __name__=="__main__":
    if len(sys.argv) < 4:
        usage()
        sys.exit(-1)
        
    tools_that_use_xml = ["fortify", "cppcheck", "scarf"]
        
    TOOL_NAME = sys.argv[1].lower()
    
    root_tag_needed = False
    
    for name in tools_that_use_xml: # Add an Arbitrary root and remove the duplicate prologs
        if name in TOOL_NAME:
            root_tag_needed =  True
            break
                         
    INPUT_DIR = sys.argv[2]
    if not os.path.isdir(INPUT_DIR):
        raise Exception ("Cannot find directory " + INPUT_DIR)

    OUTPUT_FILE = sys.argv[3]
    path = INPUT_DIR + "/"
    file_num = 1
    with open(OUTPUT_FILE, 'w') as outfile:             
        first_line = True # Used to indicate the first line of the file output (useful for removing duplicate XML prologs)
                    
        for (dirpath, dirnames, filenames) in os.walk(path):
            for fname in filenames:
                #Only process .rpf files in ldra
                if "ldra" in TOOL_NAME and fname[-4:] != ".rpf":
                    continue
                else:                            
                    print("[" + str(file_num) + "] " + fname)
                    local_path = os.path.join(dirpath, fname)
                    
                    with open(local_path) as infile: 
                        for line in infile:
                            if root_tag_needed:
                                if "<?xml" in line:
                                    if first_line:
                                        outfile.write(line)
                                        outfile.write("<arbitrary-root>\r\n")
                                        first_line = False
                                        continue
                                    else:
                                        continue # Ignore duplicate XML prologs

                            outfile.write(line)
                    file_num += 1
                    
        if root_tag_needed: # Close the root tag to the file
            outfile.write("</arbitrary-root>")
