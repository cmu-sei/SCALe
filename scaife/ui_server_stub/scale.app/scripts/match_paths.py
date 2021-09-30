#!/usr/bin/env python

# Identifies the source path for each path sent as input. Returns warnings about every path it can't find.
# 
# Script takes
# 1st arg is a triple colon-separated list of source directories to search for the files
# 2nd arg is a triple colon-separated list of paths to find
# 3rd arg is the output file to write the file paths status to
#
# Handles Windows filenames by pruning out the c: prefix
# and converting \ and \\ to / before doing checks
#
# usage: ./match_paths.py <sources> <paths_to_find> <output_file>
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
import os
import argparse
import collections


def win2unix(path):
    path = re.sub(r"\w:", "", path)
    path = path.replace("\\", os.sep)
    return path
  
  
# Find the longest common suffix between the filepath and the source_file_path
# Inspired by https://www.geeksforgeeks.org/longest-common-substring-dp-29/
def lcs(i, j, count, filepath, source_file_path):  
      
    if (i == 0 or j == 0) :  
        return count  
          
    if (filepath[i - 1] == source_file_path[j - 1]) : 
        count = lcs(i - 1, j - 1, count + 1, filepath, source_file_path)  
  
    return count 


def get_longest_common_string_index(filepath, source_file_paths):
    common_path_lengths = collections.defaultdict(set)
    
    filepath_split = filepath.split(os.sep)
        
    # Calculate each path length match for the file paths
    # Compare each directory name between the filepath provided 
    # and the one in the source directory 
    for source_file_path in source_file_paths:
        sfp_split = source_file_path.split(os.sep)
        
        common_path_lengths[
            lcs(len(filepath_split), 
                len(sfp_split), 
                0, 
                filepath_split, 
                sfp_split)
        ].add(source_file_path) 
    
    # Get the path with the longest common suffix
    lcs_len = sorted(common_path_lengths.keys())[-1] 
         
    longest_common_string = list(common_path_lengths[lcs_len])
    
    if len(longest_common_string) == 1:
        return source_file_paths.index(longest_common_string[0])
    
    return None # Could not find a unique path
    

def fill_path_map(sources):
    FilePath_Map = {} # Used to hold the actual file paths in the source
    Unix_FilePath_Map = {} # Used to hold the Unix representation of the file paths for better comparisons
    
    if not isinstance(sources, list): # Catch instances when sources is not a list but one source (string).
        sources = [sources]
        
    # Build file path maps
    for source in sources:
        for (dirpath, dirnames, filenames) in os.walk(source):
            for fname in filenames:
                # Get the file path starting from the source directory
                file_path = os.path.join(dirpath, fname)[len(source):].decode("UTF8")
                
                if file_path.rfind(os.sep) == 0:
                    file_path = file_path[len(os.sep):]  # chop off leading /
                
                # Insert the file path into the list 
                fname = fname.lower()
                
                if fname in FilePath_Map:
                    FilePath_Map[fname].append(file_path)
                    Unix_FilePath_Map[fname].append(win2unix(file_path).lower())
                else:
                    FilePath_Map[fname] = [file_path]
                    Unix_FilePath_Map[fname] = [win2unix(file_path).lower()]
           
    return FilePath_Map, Unix_FilePath_Map


def find_filepath(path, FilePath_Map, Unix_FilePath_Map):     
    converted_file_path = win2unix(path)
    filename_to_find = os.path.basename(converted_file_path).lower()  
    unix_file_path = converted_file_path.lower() # Case-insensitive file path
               
    filepaths_found = None
    actual_filepaths = None
    
    if filename_to_find not in Unix_FilePath_Map:
        return None # File name not found in the sources
    
    filepaths_found = Unix_FilePath_Map[filename_to_find] # Find filename in Map
    actual_filepaths = FilePath_Map[filename_to_find]
    
    file_path_found = get_longest_common_string_index(unix_file_path, filepaths_found)
    
    if file_path_found is None: # File path not found
        return None

    return actual_filepaths[file_path_found] # Return the filepath matching the source
    
    
if __name__ == "__main__":
    """
    Code in the main function enables match_paths.py to be run as a standalone script.
    It does not execute when running SCALe.
    """
    
    parser = argparse.ArgumentParser(description="Identifies the source path for each path specified. Returns warnings about every path it can't find.")
    parser.add_argument("sources", help="Paths to the source directories separated by triple-colons")
    parser.add_argument("paths", help="Paths to find in source separated by triple-colons")
    parser.add_argument("output_file", help="Output file to print results")
    parser.add_argument("-v", "--verbose", help="Usage: match_paths.py <sources, separated by :::> <paths_to_find, separated by :::> <output_file>")
    args = parser.parse_args()
    

    sources = args.sources.split(":::")
    paths_to_find = args.paths.split(":::")
    output_file = open(args.output_file,  "w")

    # Traversing the Source
    FilePath_Map, Unix_FilePath_Map = fill_path_map(sources)
    
    # Finding the File Paths
    unmapped_paths = set()
    for p in paths_to_find:  
        p = p.strip() 
        path_found = find_filepath(p.strip(), FilePath_Map, Unix_FilePath_Map)
        
        if not path_found:
            unmapped_paths.add(p)
        else:
            # Path found in the provided source
            output_file.write("Path " + p + " updated to " + path_found + "\n")
            
    for u in unmapped_paths:
        output_file.write("[Warning] Path not found in the provided source: " + u + "\n")
