---
title: 'SCALe : CERT Rosecheckers'
---
[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Audit Instructions](Audit-Instructions.md) / [Static Analysis Tools](Static-Analysis-Tools.md)
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

SCALe : CERT Rosecheckers
=========================

CERT Rosecheckers is an open-source static analysis tool. It was developed by
the CERT Division to look for violations of the CERT C Coding Standard.

The `rosecheckers` command takes the same arguments as the GCC compiler,
but instead of compiling the code, CERT Rosecheckers prints alerts. To
run CERT Rosecheckers on a single file, pass rosecheckers the same arguments
that you would pass to GCC. You do not have to explicitly specify
warnings to GCC like you do when harvesting its output, as
specified [here](GCC-Warnings.md). To run CERT Rosecheckers on a
codebase with multiple source files, use either of the following two
approaches.

### Substitution

In this approach, you replace GCC with a program that both runs GCC and
rosecheckers, using the `$SCALE_HOME/scripts/gcc_as_rosecheckers`
script. It runs both
`gcc`
and `rosecheckers` with
the arguments given to it.

-   Rename this script to
    `gcc` (and/or
    `g++` if you are
    using that) and ensure it is in your
    `$PATH`, so when
    your build system invokes `gcc` and/or `g++`, it really invokes your
    script instead.
-   Make the renamed-script files executable (`chmod 700`)
-   You must modify the line with the `rosecheckers` command, to provide
    the correct path on your own machine. (As of 7/12/18, currently it
    references a path `/home/rose/src/rosecheckers/rosecheckers`)
-   If your path to `gcc` is different than `/usr/bin/gcc`, then modify
    the line with the `gcc` command.
-   Then perform a normal build, and redirect the raw output into a text
    file.

### Shell Log

In this approach, you run the normal working build, but log raw text
output produced by `make`. Use that output to build a shell script that
runs rosecheckers on the same files built by GCC. Follow these steps:

-   Build a `makelog` file, which captures standard output and error
    from a successful build. (This assumes that your build process
    prints the commands it executes, which is the default behavior
    of `make`).
-   Run `$SCALE_HOME/scripts/demake.py` on the `makelog` file, which
    prunes out the 'make' commands and directory changes.
-   Prune out lines with `:`(they indicate warnings and errors). You
    could use the following command:

    ```
    fgrep -v :
    ```

-   Remove any other lines that would break this shell script.
-   Run Bash on the shellscript, and save the output in a text file.

Formatting Output For SCALe
---------------------------

The two approaches described above both result in a text file. This file
can be uploaded to the SCALe web application.

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](GCC-Warnings.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](Coverity-Prevent.md)
