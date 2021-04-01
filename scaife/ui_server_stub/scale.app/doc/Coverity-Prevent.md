---
title: 'SCALe : Coverity Prevent'
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

SCALe : Coverity Prevent
=========================

Coverity is a proprietary static analysis tool, which strives to
minimize false positives. It operates by watching a standard build, and
learns what source files are compiled and which arguments they are
compiled with. To use Coverity in SCALe, perform the following steps:

Use `cov-build` to build your code.
-----------------------------------

### Linux

You should prepend `cov-build` before your build command. Go in to your
codebase's top-level directory, and type the following:

```sh
mkdir tmp
$COVERITY_HOME/bin/cov-build --dir tmp ant
```

Coverity monitors the build for doing its analysis. Coverity pipes its
output to `tmp/build-log.txt`; you can follow it using
the `tail -f` command.

### Windows

In this scenario, your codebase is a project in
[MSVS](Terms-and-Definitions.md#msvc).
You must use the MS Command prompt, and run MSVS with Coverity
monitoring it. (This command does not work in Cygwin.)

```sh
$COVERITY_HOME\bin\cov-build --dir tmp "C:\Program Files\Microsoft Visual Studio 9.0\Common7\IDE\devenv.exe"
```

When MSVS starts up, do a complete build. Quit MSVS when done.

If you only have one C file to build, you can dispense with the command
line and do this in MSVS:

Select `Tools -> Visual Studio 2008 Command Prompt`:

Then enter the following command:

```sh
cov-build --dir tmp cl -c test.c
```

Use the Coverity analyzer.
--------------------------

The following command runs the static analysis on the source files in
the codebase:

```sh
$COVERITY_HOME/bin/cov-analyze --dir tmp --aggressiveness-level medium --all
```

Formatting Output For SCALe
---------------------------

The following command saves the Coverity alerts into a a single
output file named `coverity_results.json`.  This file can be uploaded to
the SCALe web application:`        `

```sh
$COVERITY_HOME/bin/cov-format-errors --dir tmp --json-output-v2 coverity_results.json
```

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](CERT-Rosecheckers.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](Fortify-SCA.md)
