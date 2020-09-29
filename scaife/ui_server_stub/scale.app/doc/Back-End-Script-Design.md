---
title: 'SCALe : Back-End Script Design'
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

SCALe : Back-End Script Design
===============================

All of the scripts discussed below are located in
the `$SCALE_HOME/scale.app/scripts` directory.

-   [Scripts](#scripts)
-   [Scripts](#scripts)
    -   [cmdline-ruby](#cmdline-ruby)
        -   [create\_project.py](#create_project.py)
        -   [destroy\_project.py](#destroy_project.py)
        -   [edit\_project.py](#edit_project.py)
        -   [edit\_project\_file.py](#edit_project_file.py)
        -   [create\_src\_html.py](#create_src_html.py)
        -   [upload\_src\_html.py](#upload_src_html.py)
        -   [create\_database.py](#create_database.py)
        -   [upload\_database.py](#upload_database.py)
    -   [digest\_alerts.py](#digest_alerts.py)
    -   [init\_project\_db.py](#init_project_db.py)
    -   [init\_shared\_tables.py](#init_shared_tables.py)
    -   [\*2tsv.py](#tsv.py)
    -   [\*2sql.py](#sql.py)
    -   [scale2csv.py](#scale2csv.py)
    -   [csv2scale.py](#csv2scale.py)
    -   [properties2sql.py](#properties2sql.py)
    -   [sql2properties.py](#sql2properties.py)
    -   [csv2sql.py](#csv2sql.py)
    -   [match\_paths.py](#match_paths.py)
    -   [transfer\_verdicts.py](#transfer_verdicts.py)
    -   [mk\_stats.py](#mk_stats.py)
    -   [sanitize\_db.py](#sanitize_db.py)
    -   [cascade\_verdicts.py](#cascade_verdicts.py)
    -   [canonicalize\_project.py](#canonicalize_project.py)
    -   [conditions/cert\_rules.\*.org](#taxonomy.platform.org)
    -   [conditions/cwes.\*.org](#taxonomy.platform.org)
    -   [properties/\*.\*.properties](#properties)
    -   [c.rosecheckers.properties](#c.rosecheckers.properties)
    -   [database\_version\_transfers](#database_version_transfers)
-   [Modules and Data](#modules-and-data)
    -   [bootstrap.py](#bootstrap.py)
    -   [languages.json](#languages.json)
    -   [tools.json](#tools.json)
    -   [taxonomies.json](#taxonomies.json)

Scripts
-------

### cmdline-ruby

This folder contains scripts that create auditable projects without
need for a running SCALe server. They use the Rails console to invoke SCALe code.
CAUTION: Currently these projects are 
NOT the same as projects created using the SCALe GUI, so (1) database field entries
are missing; (2) some files do not get archived; (3) exported databases are missing fields 
(and database exports haven't been tested with this code plus there are no automated regression tests 
to ensure exports continue to work during development, even if they do now); (4) the missing fields
and files will cause failures interacting with other SCAIFE servers.


#### create\_project.py

This is a script for creating initial SCALe projects. The project is
not auditable yet because it lacks source code, GNU Global output, or
static-analysis tool output.

#### destroy\_project.py

This is a script for destroying a SCALe project given its project id.

#### edit\_project.py

This script lets you change the value of a single attribute of a SCALe
project. The value should be a string or number. If a string, it
should be enclosed in quotes (in addition to whatever quoting your
shell requires.)

#### edit\_project\_file.py

This script lets you change the value of a file attribute of a SCALe project.

#### create\_src\_html.py

This is a script for creating GNU Global pages from a source
archive.

#### upload\_src\_html.py

This is a script for uplaoding an HTML archive, such as one produced
by `create_src_html.py` to a SCALe project.

#### create\_database.py

This is a script for creating project databases. It delegates most of
the work to digest_alerts.py, but provides a simpler command-line
interface.

#### upload\_database.py

This is a script for uploading a project database, as created by
`create_database.py` to an initial SCALe project, as created by
create\_project.py.

### digest\_alerts.py

This is the most important back-end script. This script takes the output
from a static analysis tool, scrapes the alert data, and imports
the data into a database. This task is accomplished by performing the
following steps:

1.  If the database file does not exist, create an empty SCALe database.
2.  Populate the Tools table in the SCALe database with data from the
    `tools.json` file, the Taxonomies table with data from the
    `\[taxonomy\]>.\[platform\].org` files, the Checkers table with data
    from the `properties/\*.\*.properties` files, and the ConditionCheckerLinks
    table with data from Conditions and Checkers.
3.  Remove all alerts from the database file that correspond to the
    current tool. (These alerts will be replaced by the alerts
    from the input file.)
4.  Run the appropriate `*2tsv.py` script to convert the alert
    output to a TSV file.
5.  In the TSV file, each alerts's checker is mapped to a CERT rule.
    Any checker that has no corresponding CERT rule causes a warning message
    to be printed.
6.  The TSV file's contents are added to the database.
7.  Populate the MetaAlerts, Determinations, and MetaAlertLinks tables using information
    previously added to the database.

### init\_project\_db.py

### init\_shared\_tables.py

### \*2tsv.py

Many scripts (such as `coverity2tsv.py` and `gcc2tsv.py`) take the
output of a static analysis alert tool and convert it to an tab-separated values (TSV) file.
For example, `gcc2tsv.py` takes output produced
by [GCC](GCC-Warnings.md) and converts it to a TSV file
that consists of all the alerts produced by GCC. The TSV file
produced by these scripts has the following 2-part format.

First part is for an alert's primary message, and the \*2tsv.py output
for the alert begins with a newline:

```
Checker        Path        Line        Message
```

That can be followed by one or more secondary message, with the
following content for each secondary message:

```
        Path        Line        Message
```

1.  `<checker>` is a string field.
2.  The first trio of `<path>-<line>-<message>` indicates the primary
    error (for example, where the
    [vulnerability](Terms-and-Definitions.md#vulnerability)
    exists). Subsequent columns are optional.
3.  `<path>` is a string (a UNIX-style path name).
4.  `<line>` is an integer that indicates the source code line, if
    applicable.

All of the scripts take two arguments consisting of the input file
(i.e., the tool output file name) and an output file. The tools write
their TSV data to the specified output file. The scripts
additionally take a --version parameter for when per-version parsing
needs to be specified manually as opposed to the script
automatically figuring out version-specific parsing.

If a tool does not have identifiable checker names in its output, the
parser script should leave the `<checker>` field blank; it can be filled
in later.

None of the tools perform validation on the data contents; an invalid
data file causes the script to crash with a Python exception.

### \*2sql.py

Many scripts (such as `lizard2sql.py`) take the output of a static
analysis code-metrics tool and convert it to an SQL file. For example,
`lizard2sql.py` takes output produced by
[Lizard](https://github.com/terryyin/lizard){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)
and converts it to an SQL file that produces a single table of metrics data discovered by Lizard.

All of the scripts take the metrics data via standard input. Each one
also takes a single argument indicating the name of the table it should
populate.

`satsv2sql.py` reads in a TSV file produced by one of the `*2tsv.py` scripts,
calls functions in match_paths.py to correct the path names,
and inserts the information into the Alerts and Messages database tables.

### scale2csv.py

This script is used to convert a SCALe database into a tabular file. By
default, the file generated is a CSV file, but you can provide the
parameters -o org to produce an ORG file instead.

```sh
scale2csv.py <db> > <csv-file>
```

### csv2scale.py

This script is used to update a SCALe sqlite database from the contents
of a tabular file (either CSV or ORG). This tabular file should have
been created by `scale2csv.py`.

```sh
csv2scale.py -i csv < <tabular-csv-file> | sqlite3 <db>
```

This script works by taking the tabular file on standard input, and it
produces SQL update commands on standard output.

Actually, the tabular file only requires three columns: the alert
ID, flag, and verdict. Any subsequent columns are ignored. The flag and
verdict for the corresponding alert ID are updated, while all other
alerts are unchanged. Note that if the table has /unknown/
verdicts, they will replace /true/ or /false/ ones in the db. If you
want to update only alerts that are not unknown, you will want to
filter out the unknown alerts from the update commands. The
following command demonstrates how to do this using `grep`.

```sh
csv2scale.py < <table> | grep -v verdict=0 | sqlite3 <db>
```

### properties2sql.py

This script converts a properties file to some SQL insert commands. It
takes a table name as a parameter.

### sql2properties.py

This script converts the output of a SQL select command to a properties
file. The first element is the property and the second element is the
property value.

### csv2sql.py

This script converts a CSV or ORG file to some SQL insert commands. It
takes a table name as a parameter.

The following commands demonstrate the inverse operation: how to convert
from a database selection to a CSV or ORG file:

```sh
sqlite3 -csv <db> "SELECT ..." > <csv-file>
sqlite3 <db> "SELECT ..." | perl -p -e 'chomp; $_ = "|$_|\n";' > <org-file>
```

### match\_paths.py

Functions in this script are called from `satsv2sql.py`. The functions correct the provided
path name to correspond to files in the source tree. It prints a warning message for any path
name it cannot resolve.

### transfer\_verdicts.py

This script is used to fill in the `previous` field in a SCALe database
with verdicts from a previous SCALe audit. For more information, see the
section [Cascading Determinations from Old Codebase to New
Codebase](Cascading-Determinations-from-Old-Codebase-to-New-Codebase.md).

### mk\_stats.py

When run in a source code directory tree, prints out useful statistics
about how much source code exists.

### sanitize\_db.py

The database [sanitizer](Sanitizer.md) script.

### cascade\_verdicts.py

usage:
`cascade_verdicts.py [-h] [-n NOTE] [-v] old_db new_db old_src new_src`

The scenario for its use is that the SCALe webapp has a project which is
version 1 of a codebase. This project has SA tool output and has been
audited (eg many alertConditions have verdicts).  The webapp also has a
second project which is version 2 of the same codebase. This project
also has SA tool output, but there are no verdicts...everything is
'unknown'. It applies the v1 determinations to the v2 codebase. That is,
for each pair of audits, one from v2 and one from v1, where the v1 alert
has a nontrivial determination, the latest determination is added to the
v2 alert. The timestamp for the new v2 determination is set to 'now',
and the Note field receives text similar to "cascaded from v1 project".

This script may be useful for integrating SCALe into a nightly
build/test process.  It may also be useful for integrating
new flaw-finding static analysis (FFSA) tools into a project, or if a
SCALe user discovers that a project has a bad run of a FFSA tool (and
afterwards they have a better run, with more alerts). This
script MAY allow SCALe users to ignore 'legacy' alerts, thereby
focusing on preventing/fixing new alerts.

NOTE OF CAUTION: Cascaded verdicts are not as trustworthy as direct
verdicts, because data, control, and type flow changes may cause the
previously-correct determination to change. E.g., with different control
flow, a previous True can become a currently-correct False.

### canonicalize\_project.py

This script prints a canonical form of a project's data when provided
a single argument of the project's ID number. This provides us with a
definition of equality for projects...two projects are equivalent if
this script produces the same output for them. The output can be
compared with diff(1) or a similar utility.

### \[taxonomy\].\[platform\].org

These files contain lists of the CERT Secure Coding rules and CWEs for the
appropriate languages. The file `conditions/cert_rules.c.org` contains rules for
both C and C++.

### properties/\*.\*.properties

These files contain the mappings between tool checkers and CERT rules.
For example, the file `c.coverity.properties` contains checkers from
Coverity that map to the CERT C Coding Standard:

1.  Each file is called `<language>.<tool>.properties` (for CERT Rules),
    `<language>.<tool>.cwe.properties` (for CWEs), or
    `<language>.<tool>.re.properties` (for regular expressions).  The `\*.\*.re.properties` file is used
    if an alert has no checker IDs, and we must rely on regular expressions to
    identify checkers. A tool can have all three files; if so, the regex file
    will be consulted first when checking for matches.
2.  Each line in a `<language>.<tool>.properties` file maps a checker to one or more CERT Rules. For example:
    `<checker>: <CERT-Rule-id-1>, <CERT-Rule-id-2>, ...`.  Similarly, each line in a `<language>.<tool>.cwe.properties` file maps a
    checker to one or more CWEs.  Each `<language>.<tool>.re.properties` maps a regular expression to a CERT Rule.  Currently, regular expressions are only used to resolve CERT Rules, not CWEs; therefore, there are no CWE regex .properties files.
3.  If we determined the checker in a `<language>.<tool>.properties` or `<language>.<tool>.re.properties` file
    corresponds to no CERT Rule, it is associated with the keyword `NONE`.
4.  Lines beginning with `#` are comments.
5.  The file can start off empty, and you can add checker-to-condition
    (e.g., checker-to-CWE, checker-to-CERT-Rule, etc.) mappings as they are needed.
6.  A single checker can, and often does, map to multiple taxonomies (CWEs, CERT Rules etc.).
    It is also common for a single checker to map to multiple CWEs and/or multiple CERT Rules.

In the `c.<tool>.properties` files, some checkers map to "SPECIAL".
The keyword "SPECIAL" instructs `digest_alerts.py` to use regular expression matching
to make the mappings more accurate (i.e., identifying if the primary message associated with an alert contains text that permits mapping the checker to an appropriate CERT Rule(s)).

For example, suppose an alert uses Checker X.  The `digest_alerts.py` script will look up Checker X's mapping
in the relevant `c.<tool>.properties` file, and find that Checker X maps to "SPECIAL".  This checker's name
will be set to NULL, since `digest_alert.py` will subsequently use mappings in the `c.<tool>.re.properties`
to resolve NULL checkers using regular expressions.

### c.rosecheckers.properties

Unlike the other `.properties` files, this file is autogenerated and not
maintained by hand
because [CERT Rosecheckers](CERT-Rosecheckers.md) uses CERT Secure
Coding rule identifiers as checkers.

The following command regenerates this file:

```sh
cat cert_rules.c.org | perl -p -e 's/^\| (.*?) \|.*/$1: $1/g' > c.rosecheckers.properties
```

### database\_version\_transfers

This folder contains several scripts that migrate from older versions of exported SCALe databases to newer versions. To upgrade a project from an older version of SCALe to a newer version, first export the project's database, run the appropriate migration script, and then import it to the newer version of the SCALe web app.

Modules and Data
----------------

The following python modules and JSON files contain interfaces to and
the information used during the initialization of the SCALe application
database installation as well as each project-specific database when a
project is created. The [initialization module](init_shared_tables.py)
handles the population of these databases with some utilities specified
in [bootstrap.py](bootstrap.py).

### bootstrap.py

This module is used by many of the other python scripts for basic
common definitions (directory names, filenames, etc) as well as
interfaces for the configuration files described below for languages,
taxonomies, and tools.

The following functions that load JSON data:

- [languages_info()](#languages.json)
- [tools_info()](#tools.json)
- [taxonomies_info()](#taxonomies.json)

### languages.json

This file contains information about the types of coding languages
understood by the tools whose analysis output can be used by SCALe after
being processed by [digest\_alerts.py](#digest_alerts.py). The full data
structure is returned by the [`bootstrap.languages_info()`](#bootstrap.py) function.

It is represented by a dictionary of language structures where each key
is the proper name of the language (e.g. "C++"). Each language structure
has the following fields -- some fields, where noted, are not actually
stored in the SCALe databases:

- **platform** : The basic name of this group of languages (e.g. "cpp"),
  used in initialization filenames as well as a way of making inferences
  between languages and tools -- the language names in each tool
  definition must match the key of one of these language definitions.
  field in the database which is derived from the one defined here.
- **versions** : The versions of each language in this group. The order
  that versions appear in this field is the canonical order in which
  they appear in the database -- later versions should be listed after
  earlier versions.
- **file_extensions** : Typical file extensions of source code files
  typically present in projects using this language. These are not
  stored in the SCALe databases, but they are used for certain
  processing during initialization.

### tools.json

This file contains information about the tools whose analysis outputs
are used by SCALe. The full data structure is returned by the
[`bootstrap.tools_info()`](#bootstrap.py) function.

It is represented as a list of tool definitions. Each tool definition
has the following fields -- some fields, where noted, are not stored in
the SCALe databases:

- **name** : The short name of this tool, used for display purposes and
  filenames.
- **label** : The full name of this tool
- **languages** : The list of languages (without versions) that this
  tool can process Each language is either a string, e.g. "Java", or a
  list if it is a language group, e.g. `["C", "C++"]`. The latter
  example with C and C++ is, so far, the only example of when a language
  group should be used -- the tools that support it will process both C
  and C++ on a single pass if present. This list of languages is used to
  store the `platform` field of the tool in the SCALe databases based on
  the platform assosciated with each language in
  [languages.json](#languages.json).
- **type** : The type of tool, e.g. "sca" or "metric" currently. Metrics
  are handled differently by SCALe than the regular analysis tools. Not
  currently stored in the SCALe databases, but is used to override the
  `platform` of the metrics tools to "metric".
- **versions** : Each tool can have multiple versions. This field is a
  list of those version strings. The order that versions appear in this
  field is the canonical order in which they appear in the database --
  later versions should be listed after earlier versions.
- **license** : The type of license (e.g. "open source" or
  "proprietary") under which this tool is released.
- **oses** : The operating systems with which this tool is compatible.
  Not currently stored in the databases.

### taxonomies.json

This file contains information about the various classification
taxonomies (and therefore specific conditions that get mapped to tool
analysis alerts). The full data structure is returned by the
[`bootstrap.taxonomies_info()`](#bootstrap.py) function.

It is represented as a list of taxonomy groups -- currently CERT Rules
and MITRE CWEs. Within each taxonomy group are definitions for the
individual taxonomies.Values defined in the group header apply to all of
the taxonomies in the group. In particular, `default_format` will be the
value for each taxonomy's `format` field unless overridden by that
particular taxonomy. Each taxonomy has the following fields -- some
fields, where noted, are not actually stored in the SCALe databases:

- **format** : If undefined this will be the same as the
  `default_format` for the taxonomy group. Each taxonomy group has extra
  fields that only apply to that taxonomy type. The `Conditions` table
  in the databases does not have columns defined specifically for each
  of these extra fields. Instead there is a single field called
  `formatted_data` that stores these extra field values as a
  JSON-encoded list. The `format` field in the `Taxonomies` table is a
  JSON-encoded list of the names of these extra fields. As stated above,
  if there is a `default_format` defined in the taxonomy header, that is
  used as the format for each taxonomy in the group.
- **platform** : This value is not stored in the database. It represents
  the generic name of the coding language that this taxonomy applies to.
  It is primarily used for calculating the names of the files in the
  `scripts/data` directory that contain the raw data for each taxonomy.
  It can have a value of `all` if the taxonomy doesn't apply to a
  specific language.
- **versions** : Each taxonomy can have multiple versions. This field is
  a list of those versions. Each version has a `version` field and a
  `version_brief` field. The value for `version` goes into the
  databases, the `version_brief`, like `platform`, is used for locating
  files used during intialization. The order that versions appear in
  this field is the canonical order in which they appear in the database
  -- later versions should be listed after earlier versions.

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Web-App-Design.md)
[![](attachments/arrow_up.png)](Welcome.md)
[![](attachments/arrow_right.png)](Exported-Database-Design.md)
