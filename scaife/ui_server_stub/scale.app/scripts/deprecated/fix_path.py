#!/usr/bin/env python

# Script takes
# Returns warnings about every path it can't fix.
#
# 1st arg is a colon-separated path list of source directories to search for the files
# 2nd arg is a colon-separated substitution list, of the form
# <path>=<path>. If any path begins with a left path in the arglist,
# it is replaced with the right path, and tried again.
# 3rd arg is a colon-separated list of paths to fix
# 4th arg is the output file to write the corrected paths
#
# Handles Windows filenames by pruning out the c: prefix
# and converting \ and \\ to / before doing checks
#
# usage: ./fix_path.py <sources> <substitution_map> <paths_to_fix> <output_file>
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
import os
import sqlite3 as sqlite
from collections import Counter


def win2unix(path):
    path = re.sub(r"\w:", "", path)
    path = path.replace("\\", "/")
    return path


def fillPathMaps(sources):
    Path_Case_Map = {}
    File_Paths_Map = {}
    File_Paths_Count = Counter()

    sources = sources.split(":")
    
    # Build file path maps
    for arg in sources: # iterate through the provided src directories
        for (dirpath, dirnames, filenames) in os.walk(arg):
            for fname in filenames:
                file_path = os.path.join(dirpath, fname)[len(arg):].decode("UTF8")
                if file_path.rfind(os.sep) == 0:
                    file_path = file_path[len(os.sep):]  # chop off leading /
                Path_Case_Map[file_path.lower()] = file_path
                File_Paths_Map[fname.lower()] = file_path
                File_Paths_Count[fname.lower()] += 1
    return Path_Case_Map, File_Paths_Map, File_Paths_Count


def findPath(path, Substitution_Map, Path_Case_Map, File_Paths_Map, File_Paths_Count, Sorted_Path_Keys):
    path = win2unix(path)
    path = path.lower()
    for key in iter(Substitution_Map):
        if not path.startswith(key) or key == "":
            continue
        path = path.replace(key, Substitution_Map[key], 1)

    if path in Path_Case_Map:
        return Path_Case_Map[path], Substitution_Map

    slashpath = "/" + path if not path.startswith("/") else path
    
    for key in Sorted_Path_Keys:
        if key.endswith(slashpath):
            return Path_Case_Map[key], Substitution_Map

        
    # If the filename is unique (no more than one copy in source)
    # then we can extract the relative path directly and get the map
    fileName = os.path.basename(path)
    if fileName in File_Paths_Map and File_Paths_Count[fileName] == 1:
        relPath = File_Paths_Map[fileName].lower()

        # Simple case: replace with ""
        if path.endswith(relPath):
            newMap = path[0:(len(path) - len(relPath))]
            if newMap.endswith(os.sep):
                newMap = newMap[0:len(newMap) - 1]
            Substitution_Map[newMap] = ""
            path = path.replace(newMap, Substitution_Map[newMap], 1)

            if path in Path_Case_Map:
                return Path_Case_Map[path], Substitution_Map

            for key in Sorted_Path_Keys:
                if key.endswith(path):
                    return Path_Case_Map[key], Substitution_Map
        # More complicated case: find longest common suffix, and map the
        # prefixes
        else:
            common_suffix = os.path.commonprefix(
                [path[::-1], relPath[::-1]])[::-1]
            newMap = path[0:len(path) - len(common_suffix)]
            newTarget = relPath[0:len(relPath) - len(common_suffix)]

            Substitution_Map[newMap] = newTarget
            path = path.replace(newMap, Substitution_Map[newMap], 1)

            if path in Path_Case_Map:
                return Path_Case_Map[path], Substitution_Map

            for key in Sorted_Path_Keys:
                if key.endswith(path):
                    return Path_Case_Map[key], Substitution_Map
    return None, Substitution_Map


def updatePath(path, Substitution_Map, Path_Case_Map, File_Paths_Map, File_Paths_Count, Sorted_Path_Keys):
    unmapped_path = False

    if path is None:
        path = ""

    if path.rfind(os.sep) == 0:
        path = path[len(os.sep):]

    found_path, Substitution_Map = findPath(path, Substitution_Map, Path_Case_Map, File_Paths_Map, File_Paths_Count, Sorted_Path_Keys)

    if found_path is not None:
        unmapped_path = False
        return found_path, unmapped_path, Substitution_Map
    else:
        unmapped_path = True
        return path, unmapped_path, Substitution_Map


if __name__ == "__main__":
    """
    Code in the main function enables fix_path.py to be run as a standalone script.
    It does not execute when running SCALe.
    """

    if len(sys.argv) != 4:
        raise Exception("usage: " + sys.argv[0] + " <sources> <paths_to_fix> <output_file>")

    sources = sys.argv[1]
    paths_to_fix = sys.argv[2].split(":")
    output_file = open(sys.argv[3],  "w")

    Path_Case_Map, File_Paths_Map, File_Paths_Count = fillPathMaps(sources)
    Substitution_Map = {}

    Sorted_Path_Keys = Path_Case_Map.keys()
    Sorted_Path_Keys.sort(key=lambda k : len(k.split("/")))

    unmapped_paths = set()
    for p in paths_to_fix:
        p = p.strip()
        path, unmapped, Substitution_Map = updatePath(p, Substitution_Map, Path_Case_Map, File_Paths_Map, File_Paths_Count, Sorted_Path_Keys)

        if (unmapped):
            unmapped_paths.add(p)
        else:
            # Path found in the provided source
            output_file.write("Path " + p + " updated to " + path + "\n")

    for u in unmapped_paths:
        output_file.write("[Warning] Path not found in the provided source: " + u + "\n")

    #Path_Case_Map #e.g., u'todo.txt': u'TODO.txt'
    #File_Paths_Map #e.g., 'utf16be.txt': u'/test/utf16be.txt'; 'copying.txt': u'COPYING.txt'

    #con = sqlite.connect(sys.argv[1])
    #with con:
        # Sigh...I'm going to OO hell for this.
    #    query_map = {
    #        0:  [["other", """
    #                       SELECT Messages.path FROM Messages
    #                       JOIN Alerts ON Alerts.id=Messages.alert_id
    #                       JOIN Checkers ON Checkers.id=Alerts.checker_id
    #                       WHERE Checkers.tool_id=?""",
    #                       "UPDATE Messages SET path=? WHERE path=?"]],
    #        91: [["lizard_name",
    #                       "SELECT name   FROM LizardMetrics WHERE parent IS NULL AND '91'=?",
    #                       "UPDATE LizardMetrics SET name=?   WHERE name=?"],
    #                       ["lizard_parent",
    #                            "SELECT parent FROM LizardMetrics WHERE parent IS NOT NULL AND '91'=?",
    #                            "UPDATE LizardMetrics SET parent=? WHERE parent=?"]],
    #        92: [["ccsm",
    #                      "SELECT File FROM CcsmMetrics WHERE File != 'Global' AND '92'=?",
    #                      "UPDATE CcsmMetrics SET File=? WHERE File=?"]],
    #        93: [["understand_name",
    #                                 "SELECT Name FROM UnderstandMetrics WHERE Kind=1 AND '93'=?",
    #                                 "UPDATE UnderstandMetrics SET Name=? WHERE Name=?"],
    #                                 ["understand_file",
    #                                                   "SELECT File FROM UnderstandMetrics WHERE File!=0 AND '93'=?",
    #                                                    "UPDATE UnderstandMetrics SET File=? WHERE File=?"]]
    #    }
        #lookup_tool_id = int(tool_id) if int(tool_id) in query_map.keys() else 0

        #cur = con.cursor()
    #    for [tool_name, select_query, update_query] in query_map[lookup_tool_id]:
    #        cur.execute(select_query, (tool_id,))
    #        update_paths(con, cur.fetchall(), update_query)
