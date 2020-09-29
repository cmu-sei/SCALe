---
title: 'SCALe : Source Code Statistics'
---
[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Audit Instructions](Audit-Instructions.md) / [Building an Audit Report](Building-an-Audit-Report.md)
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

SCALe : Source Code Statistics
===============================

For each codebase we analyze in SCALe, we capture the following
statistics:

-   [Qualitative Values](#qualitative-values)
    -   [Codebase](#codebase)
    -   [Customer](#customer)
    -   [Language](#language)
    -   [License](#license)
    -   [Iterations](#iterations)
    -   [Start Date](#start-date)
    -   [End Date](#end-date)
-   [Basic Measured Values](#basic-measured-values)
    -   [Distribution](#distribution)
    -   [Source](#source)
    -   [Files](#files)
    -   [kLoC](#kloc)
    -   [ksigLoC](#ksigloc)
-   [Basic Derived Values](#basic-derived-values)
    -   [Filesize](#filesize)
    -   [Comment](#comment)
-   [Audit Measured Values](#audit-measured-values)
    -   [Rules](#rules)
    -   [True](#true)
    -   [Suspicious](#suspicious)
    -   [Unknown](#unknown)
    -   [False](#false)
-   [Audit Derived Values](#audit-derived-values)
    -   [Alerts](#alerts)
    -   [Uncertainty](#uncertainty)
    -   [File Density](#file-density)
    -   [Line Density](#line-density)

Qualitative Values
------------------

These items are not measured

### Codebase

Name of codebase to analyze

### Customer

Who we did the audit for

### Language

Programming language used by codebase

### License

Is software proprietary or open-source?

### Iterations

Number of SCALe audits on this codebase

### Start Date

Date when source code received

### End Date

Date when audit report completed

Basic Measured Values
---------------------

These are items we measure, but they do not require an audit to be
complete.
For these items, we will provide a POSIX command that produces the
measurement when run in a directory that contains all of the source code
(and perhaps other files). We will assume the language is Java.

### Distribution

Size of codebase (in kilobytes)

    du | tail -1

### Source

Size of source code files (in kilobytes) (including blanklines & comments)

    expr `find . -name *.java -exec cat {} \; | wc -c` / 1024

### Files

Number of source files

    find . -name *.java -print | wc -l

### kLoC

lines of source code (/ 1000)

    expr `find . -name *.java -exec cat {} \; | wc -l` / 1000

### ksigLoC

lines of significant source code (/ 1000) (w/o blanklines & comments)

    expr `find . -name *.java -exec cat {} \; | sloc.py -l c | wc -l` / 1000

The `sloc.py` script is part of the SCALe app, in the scripts directory.
It filters out blanklines and comments. the -l option indicates the
comment style, either 'c' for C-style comments (/\* \*/, //) or 'sh' for
Perl-style comments (\#).

Basic Derived Values
--------------------

These values are determined by calculations on the Basic Measured Values

### Filesize

Lines of code per file

    1000 * kLoC / Files

### Comment

Percentage of significant source code to total code

    ksigLoC / kLoC

Audit Measured Values
---------------------

These are items we measure based on a completed SCALe audit.

### Rules

Number of CERT rules that were violated by a True alert

### True

Number of true violations

### Suspicious

Number of suspicious violations

### Unknown

Number of unknown violations

### False

Number of false positives

Audit Derived Values
--------------------

These values are determined by calculations on the Basic and Audit
Measured Values

### Meta-Alerts

Total number of Meta-Alerts reported

    True + Suspicious + Unknown

### Uncertainty

Ratio of reported Meta-Alerts per True Meta-Alert

    (Suspicious + Unknown) / True

This represents the likelihood that a non-false Meta-Alert is to be True

### File Density

Ratio of reported defects per file

    Meta-Alerts / Files

### Line Density

Ratio of defects per code size

    True and Suspicious Meta-Alerts / ksigLoC
