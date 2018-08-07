#!/usr/bin/env python

# Script takes SCALe database file as input,
# and fixes the paths in the database.
# Issues warnings about every path it can't fix.
#
# 1st arg is the database file
# 2nd arg is a colon-separated path list of paths to search for the files
#
# Each remaining arg is a substitution list, of the form
# <path>=<path>. If any path begins with a left path in the arglist,
# it is replaced with the right path, and tried again.
#
# If no mapping is found, the source dir is searched again
# for a path that ends in the specified path.
#
# Handles Windows filenames by pruning out the c: prefix
# and converting \ and \\ to / before doing checks
#
# usage: ./fix_path.py <db> <searchpath> <path>=<path> <path>=<path> ...
#
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.


import sys
import re
import os
import sqlite3 as sqlite


def win2unix(path):
    path = re.sub(r"\w:", "", path)
    path = re.sub(r"\\\\", "/", path)
    path = re.sub(r"\\", "/", path)
    path = path.lower()
    return path


def find_path(path):
    path = win2unix(path)
    for key in iter(Substitution_Map):
        if not path.startswith(key) or key == "":
            continue
        path = path.replace(key, Substitution_Map[key], 1)

    if path in Path_Case_Map:
        return Path_Case_Map[path.lower()]

    path_lower = path.lower()
    for key in iter(Path_Case_Map):
        if key.endswith(path_lower):
            return Path_Case_Map[key]

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

            if "TRUE" == os.environ["VERBOSE"] and newMap != "":
                print("Detected new map: " + newMap)

            if path in Path_Case_Map:
                return Path_Case_Map[path.lower()]

            path_lower = path.lower()
            for key in iter(Path_Case_Map):
                if key.endswith(path_lower):
                    return Path_Case_Map[key]
        # More complicated case: find longest common suffix, and map the
        # prefixes
        else:
            common_suffix = os.path.commonprefix(
                [path[::-1], relPath[::-1]])[::-1]
            newMap = path[0:len(path) - len(common_suffix)]
            newTarget = relPath[0:len(relPath) - len(common_suffix)]

            Substitution_Map[newMap] = newTarget
            path = path.replace(newMap, Substitution_Map[newMap], 1)

            if "TRUE" == os.environ["VERBOSE"]:
                print("Detected new map: " + newMap + " --> " + newTarget)

            if path in Path_Case_Map:
                return Path_Case_Map[path.lower()]

            path_lower = path.lower()
            for key in iter(Path_Case_Map):
                if key.endswith(path_lower):
                    return Path_Case_Map[key]
    return None

if len(sys.argv) < 2:
    print "usage: " + sys.argv[0] \
        + " <db> <searchpath> <toolid> " \
        + "<path>=<path> <path>=<path> ..."
    exit(1)

db = sys.argv[1]
Search_Path = sys.argv[2].split(":")
# Build map of substitions from args
Substitution_Map = {'': ''}
tool_id = sys.argv[3]
for arg in sys.argv[4:]:
    paths = arg.lower().split("=")
    if len(paths) < 2:
        paths = [arg.lower(), ""]
    Substitution_Map[win2unix(paths[0])] = win2unix(paths[1])

# Get case-sensitive paths from search path
Path_Case_Map = {}
# Get paths from filename
File_Paths_Map = {}
File_Paths_Count = {}
for arg in Search_Path:
    for dirPath, dirNames, fileNames in os.walk(arg):
        for fileName in fileNames:
            pathName = os.path.join(dirPath, fileName)[
                len(arg):].decode("UTF8")
            if pathName.rfind(os.sep) == 0:
                pathName = pathName[len(os.sep):]  # chop off leading /
            Path_Case_Map[pathName.lower()] = pathName

            # Also store the path for the filename
            if fileName.lower() in File_Paths_Map:
                File_Paths_Count[fileName.lower()] += 1
            else:
                File_Paths_Count[fileName.lower()] = 1
                File_Paths_Map[fileName.lower()] = pathName

if "TRUE" == os.environ["VERBOSE"]:
    print("Finished parsing filepaths")
not_found_rows = []
unmapped_paths = set()

con = None
if not os.path.exists(db):
    raise Exception("Database does not exist")
con = sqlite.connect(db)
with con:
    cur = con.cursor()
    cur.execute("""
SELECT Messages.id, Messages.path FROM Messages
    JOIN Diagnostics ON Diagnostics.id=Messages.diagnostic
    JOIN Checkers ON Checkers.id=Diagnostics.checker
    WHERE Checkers.tool=?""", (tool_id,))

    rows = cur.fetchall()
    for row in rows:
        msg_id = row[0]
        path = row[1]
        if path is None:
            path = ""
        if path.rfind(os.sep) == 0:
            path = path[len(os.sep):]  # chop off leading /
        found_path = find_path(path)
        if found_path is not None:
            cur.execute(
                "UPDATE Messages SET path=? WHERE id=?", (found_path, msg_id))
        else:
            not_found_rows.append(row)

    if "TRUE" == os.environ["VERBOSE"]:
        print("Starting second pass")

    # Second pass through for initially unfound;
    # perhaps the mapping was found later for a unique file.
    # Pretty much an identical copy of the previous code.
    for row in not_found_rows:
        msg_id = row[0]
        path = row[1]
        if path is None:
            path = ""
        if path.rfind(os.sep) == 0:
            path = path[len(os.sep):]  # chop off leading /
        found_path = find_path(path)
        if found_path is not None:
            cur.execute(
                "UPDATE Messages SET path=? WHERE id=?", (found_path, msg_id))
        # Only give it one additional pass
        else:
            unmapped_paths.add(path)

    for p in unmapped_paths:
        print "[Warning] Path not found in the provided source:", p

    con.commit()
