---
title: 'SCALe : Fortify SCA'
---
 [SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Audit Instructions](Audit-Instructions.md) / [Static Analysis Tools](Static-Analysis-Tools.md)
<!-- <legal> -->
<!-- SCALe version r.6.5.5.1.A -->
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

SCALe : Fortify SCA
===================

Fortify SCA (henceforth known as Fortify) is a proprietary static
analysis tool.  Fortify's different categories of alerts are
documented

[on Fortify's website](https://www.microfocus.com/en-us/products/static-code-analysis-sast/overview){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).

Fortify scans consist of two phases: translation and analysis:

-   In the translation phase, Fortify translates your code into an
    internal representation. It does this either by directly processing
    your source files or by monitoring your build process (e.g., mvn,
    make, ant).
-   In the analysis phase, Fortify scans the output from the previous
    phase, and produces a list of alerts.

Depending on your language and build architecture, you have options for
running a scan: use the Fortify command-line utilities or else use the
Audit Workbench (AW) GUI. The latter option is limited only to scanning
Java projects. The command-line tools offer much more utility.

Command Line
------------

The main tool used for Fortify scans is called `sourceanalyzer`.  This
tool performs both the translation and analysis steps discussed above.
However, a separate invocation is required for the two steps. A basic
scan takes the following form:

```sh
# Translate
sourceanalyzer -b my_project <list of sources, or build command>

# Analyze (comprehensive, more info)
sourceanalyzer -b my_project -scan -format fvdl -f results.fvdl

# As an alternative scan:  (simpler, less info)
sourceanalyzer -b my_project -scan -f results.fpr
```

The first command translates your sources. The argument to the `-b`
option should uniquely identify your project.  Depending on the language
you are translating, the rest of the command will either take a list of
source code files (wildcards are acceptable, e.g.,
`src/**/*.java`) or a
build command (e.g.,
`gcc myfile.c`).  See
the Java and C sections below for more details on translation, or
reference the Fortify SCA User Guide. If successful, this command should
have no output. Fortify maintains the translated representation in some
internal fashion (so you should not be surprised that no file is added
to the local directory, for example).

The latter commands perform the analysis and produces alerts. You can
use either one. The argument to `-b` must be the same as that passed
to the translate command. The `-f` options indicates the file where
the alert details should be stored. This file is formatted as an FVDL
file, or alternately, a "Fortify Project file," and should have the
extension `.fvdl` or `.fpr`.  If `-f` is omitted, the command produces
a terse summary of the alerts encountered. The `.fpr` file can be
opened in AW to easily review the results.

### Memory Exhaustion Issues

Your Fortify scan may issue warnings indicating that it is running low
on memory or may even terminate because it has exhausted the memory
available to it.  The SCA User Manual says the following on this topic:

> By default, SCA uses up to 600 MB of memory. If this is not sufficient
> to analyze a particular code base, you might have to provide more
> memory in the scan phase. This can be done bypassing the **-Xmx**
> option to the sourceanalyzer command.  For example, to make 1000 MB
> available to SCA, include the option **-Xmx1000M**.

So, if your scan phase is running out of memory, try increasing the max
heap size with the `-Xmx` option.

### Disk Exhaustion Issues

Fortify stores project information in a `.fortify` subdirectory in your
home directory. If Fortify runs out of disk space, you can move this
directory to a partition with sufficient space, and then create a
symbolic link in your home directory.

### Sledgehammer Script

Sometimes you will get warnings for classes you think should be in the
path. One approach is add every jar file you think you may need on the
command line. The following shell script does precisely this; it scans
several directories for relevant jars and invokes Fortify with all the
jars. It also provides verbose debug output. This script is not hardened
for reuse. You should make a copy and configure it to work in your
environment:
```sh
    #!/bin/sh
    # fortify_for_java.sh by Derrick H. Karimi, 2014
    #
    # Directions:
    # edit some lines below to grab jars specific to your build environment

    jar_list()
    {
        # use the shell's tools to generate a classpath with directories and wildcards like this:
        # /a/super/large/*:/list/of/*:/directories/*

        find $1 -name "*.jar" -exec dirname {} \; | uniq | xargs | sed 's, ,/*:,g'
    }
    export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

    #
    # edit below to be the jar's you want

    jars="$(jar_list .)"
    jars="$jars:$(jar_list  ~/.m2/repository)"
    jars="$jars:$(jar_list  $JAVA_HOME)"

    # edit above to be the jar's you want
    #

    echo "Using jars:  $jars"
    now=$(date +"%Y%m%d%H%M%S")
    run="$(basename $(pwd))-$now"
    echo "run name is: $run"
    sourceanalyzer -b $run -debug -verbose --jdk 1.7 -cp "$jars" "./**/*.java"
    sourceanalyzer -b $run -scan -f $run.fpr
    ReportGenerator -format xml -f $run.xml -source $run.fpr -template /opt/fortify/Core/config/reports/DeveloperWorkbook.xml
```
Formatting Output For SCALe
---------------------------

Fortify output can be uploaded to the SCALe web application as an FVDL
file.  Alternately, SCALe also accepts XML file generated from the
`*.fpr` file produced by the Fortify Scan. You can use the command
line or the Audit Workbench GUI to generate the XML file.

### Command Line

The `ReportGenerator` command can produce the desired XML file. The
following example assumes that the environment variable `$FORTIFY_HOME`
points to the directory where Fortify is installed:

```sh
export FORTIFY_HOME=/path/to/fortify/installation
ReportGenerator -format xml -f fortify_results.xml -source results.fpr -template $FORTIFY_HOME/Core/config/reports/DeveloperWorkbook.xml
```

### Audit Workbench (AW) GUI

For Java: you can run the `Fortify Audit Workbench`. When the GUI comes
up, `Scan Java project` and select the codebase. For this run, the
codebase should live in `C:`.

For C/C++, you should first run the `Fortify Build Monitor`.
Select `Monitor`, build project in MSVS, and then select `Build Done`.
The monitor should have logged the files that were built. Then
select `Scan`, and the monitor should bring up the audit workbench, with
violations to view.

Once the audit workbench is up,
select `Report` tab, `Fortify Developer's Workbook`, and save report as
XML. But first, be sure to turn off `limit-to-5-errors`, which is buried
in `Result Outline->Listing by Category`.

To create Fortify output,
select `Tools->Generate Report, Fortify Developer Workbook. `Then` Save Report, Browse Desktop, XML` .

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Coverity-Prevent.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](Cppcheck.md)
