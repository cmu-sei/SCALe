---
title: 'SCALe : Adding a Tool to SCALe'
---
 [SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md)
<!-- <legal> -->
<!-- SCALe version r.6.7.0.0.A -->
<!--  -->
<!-- Copyright 2021 Carnegie Mellon University. -->
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

SCALe : Adding a Tool to SCALe
===============================

Static Analysis Alert Tools
---------------------------

A new **general flaw-finding static analysis tool** can be added to
SCALe by performing the following steps:

Map alerts from the new tool to [SEI CERT coding
rules](https://www.securecoding.cert.org/confluence/display/seccode/SEI+CERT+Coding+Standards){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).
A method that has been used to perform mapping is:

1.  Enumerate checkers from the tool’s documentation
2.  Map the checkers to CERT coding rules (as well as possible) based on
    their description
3.  Do spot checking with the actual tool on some test code (e.g.,
    Jasper).
4.  Note: Initial mappings are improved/evolved over time. CERT does an
    initial attempt at mapping, then improves the mappings over the
    course of each subsequent audit using that tool.

Create a new web page about the new tool linked from [Static Analysis
Tools](Static-Analysis-Tools.md). Each such page should
contain the following:

1.  Instructions on how to run the tool such that it produces output
    that can be fed into SCALe (these instructions should produce a
    single human-readable output file containing the information
    reported by the tool. The file could be text, XML, or some other
    format)
2.  Any operational information about the tool

You will need to add information about the tool to the  `       tools.json     ` file. This include the tool's name, [languages it supports and platform](Notes-on-Languages-vs-Platforms.md), and which versions are supported by SCALe. For more information on `tools.json`, see the [Back-End Script Design](Back-End-Script-Design.md).

Design and implement a parser to create TSV files from the new
tool's output. The parser should be named `$TOOL2tsv.py`, and it should
follow the same conventions as the
other `         *2csv.py       `scripts.

1.  If your tool does not provide line numbers for the flaws it finds,
    use the integer 0 for `<line>`.
2.  If the path to a file in the codebase is not available, provide a
    UNIX-style path (including a file name) for
    the `<path>` variable *and* put a dummy file with that file name in
    that path. Empty path names are not permitted.

You need to create a new
[properties](Back-End-Script-Design.md#*.*.properties)
file for the new tool. The file should follow the same conventions as
the other properties files, including:

1.  Name the properties file as follows:
    &lt;language&gt;.&lt;toolname&gt;.&lt;version&gt;.properties

The `config/application.rb` file enumerates all tools supported by
SCALe. You will need to extend this list, which occurs right after the
`module Scale` line (lines 26-28 in current version).

Once you have extended the infrastructure with your tool, you will want
to test it. For this test, you need your source codebase and some
suitable output that your tool produced while analyzing the codebase:

-   Build the SCALe database by using the program
    `        digest_alerts.py      `. This script invokes your
    parser.
-   Give `digest_alerts.py` the outputs from running your tool as
    well as your tool's numeric ID. You can find more information here:
    [Manual Project Creation](Command-Line-Project-Creation.md).

Static Analysis Metric Tools
----------------------------

A new **general code-metric static analysis tool** can be added to SCALe
by performing the following steps:

1.  Determine a schema for new database tables that will hold the new
    code metrics (one field for each metric)
    1.  For the external.sqlite3 and exported databases, the new table
        should be named "&lt;\*&gt;Metrics", where &lt;\*&gt; is a short
        text version of the toolname. For example, "CCSMMetrics" or
        "LizardMetrics".
    2.  Enter that info in [Exported Database
        Design](Exported-Database-Design.md) and [DB Design for per-project SQLite files in backup](DB-Design-for-per-project-SQLite-files-in-backup.md)
2.  Create a new web page about the new tool linked from [Static
    Analysis Tools](Static-Analysis-Tools.md). Each such
    page should contain the following:
    1.  Instructions on how to run the tool such that it produces output
        that can be fed into SCALe (these instructions should consist of
        a single human-readable file; the file could be text, XML, or
        some other format)
    2.  Any operational information about the tool.
3.  The new tool needs a numeric ID; you will add the tool and ID to the
    `       tools.csv     ` file. The id number should be unique and
    large, but under 100. Currently used metric IDs are 91-93. Use
    "metric" as the platform.
4.  Design and implement a parser to create a SQL file from the new
    tool's output. The parser should be named `$TOOL2sql.py`, and it
    should follow the same conventions as the
    other `         *2sql.py       `scripts.
5.  The `config/application.rb` file enumerates all tools supported by
    SCALe. You will need to extend this list, which occurs right after
    the `module Scale` line (lines 24-26 in current version).

Once you have extended the infrastructure with your tool, you will want
to test it. For this test, you need your source codebase and some
suitable output that your tool produced while analyzing the codebase:

-   Build the SCALe database by using the program
    `        digest_alerts.py      `. This script invokes your
    parser.
-   Give `digest_alerts.py` the outputs from running your tool as
    well as your tool's numeric ID. You can find more information here:
    [Manual Project Creation](Command-Line-Project-Creation.md).

------------------------------------------------------------------------


[![](attachments/arrow_left.png)](Exported-Database-Design.md)
[![](attachments/arrow_up.png)](Welcome.md)
[![](attachments/arrow_right.png)](Command-Line-Project-Creation.md)
