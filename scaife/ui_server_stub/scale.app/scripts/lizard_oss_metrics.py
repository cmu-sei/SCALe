#!/usr/bin/env python

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

import lizard
import scale
import argparse
import os
import sys


# Get path arg from cmd line
def getArgs():
    parser = argparse.ArgumentParser(description="Gathers metrics via Lizard")
    parser.add_argument(
        "-p", "--pathName", help="Path in which to begin gathering metrics")

    args = parser.parse_args()

    if args.pathName is None:
        print("Must specify path in which directory", 
            " to parse is located using -p")
        sys.exit(1)

    if not os.path.exists(args.pathName):
        print("Target directory ", args.pathName, " does not exist!")
        sys.exit(1)

    return args.pathName


def convertPath(pathName):
    pathList = pathName.split('/')

    if pathList[len(pathList) - 1]:
        return pathList[len(pathList) - 1]
    else:
        return pathList[len(pathList) - 2]


def getNewFileName(newPath, oldFile):
    fileList = oldFile.split('/')
    pathBegin = None

    for cur in range(len(fileList)):
        if fileList[cur] == newPath:
            pathBegin = cur

    newList = fileList[pathBegin:]
    finalPath = '/' + '/'.join(newList)

    return finalPath


def printMetrics(srcFiles, pathName):
    totSlocFolder = 0
    numFiles = 0

    newPath = convertPath(pathName)
    
    # lizard.analyze_file.processors.insert(0, lizard.CPreExtension)
    analyze_file = lizard.FileAnalyzer(lizard.get_extensions(['cpre']))

    # Insert file metrics as well as metrics for file's functions
    for currFile in srcFiles:
        totSloc = 0
        totParams = 0
        totTokens = 0
        totComplexity = 0

        fileMetrics = analyze_file(currFile)
        #fileMetrics = lizard.analyze_file(currFile)
        numFuncs = len(fileMetrics.function_list)

        fileName = getNewFileName(newPath, fileMetrics.filename)

        for func in fileMetrics.function_list:
            fields = [func.name, func.length, func.nloc, fileName,
                      "", func.cyclomatic_complexity, "",
                      func.parameter_count, "", "", "", func.token_count,
                      "", func.start_line, func.end_line]
            scale.Write_Fields(map(lambda x: str(x), fields))
            totSloc += func.nloc
            totParams += func.parameter_count
            totTokens += func.token_count
            totComplexity += func.cyclomatic_complexity

        if numFuncs != 0:
            avgSloc = round((float(totSloc) / numFuncs), 2)
            avgParams = round((float(totParams) / numFuncs), 2)
            avgTokens = round((float(totTokens) / numFuncs), 2)
            avgComplexity = round((float(totComplexity) / numFuncs), 2)
            fields = [fileName, "", fileMetrics.nloc, "",
                      numFuncs, "", avgComplexity, "", avgSloc,
                      avgParams, "", "", avgTokens, "", ""]
        else:
            fields = [fileName, "", fileMetrics.nloc, "",
                      0, "", 0, "", 0, 0, "", "", 0, "", ""]
        scale.Write_Fields(map(lambda x: str(x), fields))

        totSlocFolder += fileMetrics.nloc
        numFiles += 1

    if numFiles != 0:
        fields = [newPath, "", totSlocFolder,
                  "", "", "", "", "", "", "", "",
                  float(totSlocFolder) / numFiles,
                  "", "", "", ""]
        scale.Write_Fields(map(lambda x: str(x), fields))


def main():
    pathName = getArgs()
    srcFiles = lizard.get_all_source_files([pathName], [], [])
    printMetrics(srcFiles, pathName)

if __name__ == "__main__":
    main()
