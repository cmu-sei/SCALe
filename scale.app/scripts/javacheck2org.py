#!/usr/bin/env python
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

import sys
import re
import os


def main():
    if len(sys.argv) != 2:
        raise TypeError(
            "Usage: " + sys.argv[0] + " <raw-input> > <org-output>")
    infile = sys.argv[1]
    parseRE = re.compile(r"\|(.*?)\|(.*?)\|(.*?)\|(.*?)\|(.*?)\|")

    fh = open(infile, 'r')
              #No try-except since we just want to die on error anyway
    # Format of output is | Rule | Path | File | Line | Desc |
    for line in fh:
        parse = parseRE.match(line)
        if parse is not None:
            rule = (parse.group(1)).strip()
            path = os.path.join(
                (parse.group(2)).strip(), (parse.group(3)).strip())
            line = (parse.group(4)).strip()
            desc = (parse.group(5)).strip()
            print "| " + rule + " | " + path + " | " + line + " | " + desc + " |"

if __name__ == "__main__":
    main()
