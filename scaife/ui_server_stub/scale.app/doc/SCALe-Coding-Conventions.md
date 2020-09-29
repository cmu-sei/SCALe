---
title: 'SCALe : SCALe Coding Conventions'
---
 [SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md)
<!-- <legal> -->
<!-- SCALe version r.6.2.2.2.A -->
<!--  -->
<!-- Copyright 2020 Carnegie Mellon University. -->
<!--  -->
<!-- NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING -->
<!-- INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON -->
<!-- UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR -->
<!-- IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF -->
<!-- FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS -->
<!-- OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT -->
<!-- MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, -->
<!-- TRADEMARK, OR COPYRIGHT INFRINGEMENT. -->
<!--  -->
<!-- Released under a MIT (SEI)-style license, please see COPYRIGHT file or -->
<!-- contact permission@sei.cmu.edu for full terms. -->
<!--  -->
<!-- [DISTRIBUTION STATEMENT A] This material has been approved for public -->
<!-- release and unlimited distribution.  Please see Copyright notice for -->
<!-- non-US Government use and distribution. -->
<!--  -->
<!-- DM19-1274 -->
<!-- </legal> -->

SCALe : SCALe Coding Conventions
================================

This section documents the coding conventions and style guide that we
have decided to use when coding SCALe.

### Code Documentation

The top of every text file should have top-level code comments saying
generally what the file is for. These comments are for developers who
might want to modify the file.

Remember to add blank line after code comments, then legal markings
(``<legal></legal>``), then another blank line before the start of the
code.

A script is any file that can be invoked from from a shell. Scripts
have some additional constraints:

 * There should be 'manual' documentation which provides an overview
   of what the script does. This belongs in the [Back-End Script
   Design](Back-End-Script-Design.md) page. This documentation should
   be useful for developers and non-developers alike. For all the scripts, 
   target this documentation to be comprehensible by non-developers, who 
   may need to run the script but aren't interested in how it works or could 
   be modified.

 * The script should provide its own 'help' documentation, which
   provides a quick reference for what arguments the script takes as
   input, and what it produces as output. This documentation could be
   provided by a script upon any invocation, or when fed invalid
   arguments, or when requested, perhaps via a ``-h`` or ``--help``
   argument. This documentation should live near the top of the
   script, perhaps in a usage() function or global variable.

   For Python scripts specifically (new scripts or scripts you edit):
   - Make sure (add if needed) that there is a "``--help``" use statement
   which includes the info in the code comments, PLUS info about each
   of the input parameters (This is most easily accomplished using
   Python's argparse library).
   - Python  test scripts should invoke pytest.main(). 
   Documentation on using pytest are here: https://docs.pytest.org/en/stable/.
   
 * If you add a new function, unless
   super-simple and immediately obvious, add a comment above it
   specifying what it does. Please do same if you modify a function
   that doesn't already have an appropriate function comment. 

 * Note: If a module is not intended to be invoked as a script for
   normal usage, or is a script that takes no arguments, the overview of
   the module as described in the top comments is sufficient
   documentation. In these cases there is no need to add a "--help"
   command line argument and associated help text.

### Copyright Conventions

Each source file (minus excepted filetypes discussed below) should have legal tags:

    <legal></legal>

When SCALe is bundled for release, these tags are changed to contain legal information, including a copyright and distribution markings. The legal information is contained in the ABOUT file.

The legal information should appear after the top-level comments, but before any code or data. A single blank line separates the legal information from the code/data.

#### Filetype Exceptions

We don't have to add the legal text to filetypes where adding the text would make it non-functional.
Among others, filetype exceptions include:

- .ORG
- .CSV
- .JSON
- .sqlite3
