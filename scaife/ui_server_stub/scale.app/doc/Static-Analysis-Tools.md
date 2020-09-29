---
title: 'SCALe : Static Analysis Tools'
---
[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Audit Instructions](Audit-Instructions.md)
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

SCALe : Static Analysis Tools
==============================

When auditing a codebase, you should use all the tools (listed below)
that you possess and that are supported by your operating system. You
may use tools on multiple operating systems if the code you are testing
is portable. For example, if you have a C codebase that compiles under
both Windows and Linux, you may use tools listed under both platforms.

Each platform supports multiple tools. For each flaw-finding tool, there
is a section that instructs precisely how to run the tool. These
instructions should produce a file containing the tool's alerts
(for general flaw-finding tools). An output file containing code metrics
is required for using output from the code metrics tools.

In the following pages, we provide a number of commands to use for in
the flaw-finding tools for Windows and Linux platforms. We assume that
the `$SCALE_HOME` environment variable refers to the path where the
SCALe app is installed. Tools that are installed in nonstandard
locations occasionally require commands that include their path. We
assume you have environment variables specifying their install path in
these commands. For example, Fortify comes with a program
called `ReportGenerator`, and so we assume `$FORTIFY_HOME` is set so
that you can invoke `$FORTIFY_HOME/bin/ReportGenerator` on Linux.

The tools and platforms integrated into SCALe are as follows:

Linux + GCC
-----------

These flaw-finding tools can be used on both C and C++ programs that are
built using the GNU Compiler Collection on Linux:

-   [GCC](GCC-Warnings.md)
-   [G++](GCC-Warnings.md)
-   [CERT Rosecheckers](CERT-Rosecheckers.md)
-   [FlexeLint](PC-Lint-FlexeLint.md)
-   [Coverity Prevent](Coverity-Prevent.md)
-   [Fortify SCA](Fortify-SCA.md)
-   [Cppcheck](Cppcheck.md)

These code metrics tools can be used:

-   [CCSM](CCSM.md)
-   [Lizard](Lizard.md) (Lizard can be used on C, C++14,
    C#, Java, Python, JavaScript, etc.)

Windows + Microsoft Visual Studio
---------------------------------

These flaw-finding tools can be used on both C and C++ programs that are
built using Microsoft Visual Studio on Windows:

-   [Microsoft Visual Studio Static Analyzer](Microsoft-Visual-Studio-Static-Analyzer.md)
-   [PC-lint](PC-Lint-FlexeLint.md)
-   [Fortify SCA](Fortify-SCA.md)
-   [Coverity Prevent](Coverity-Prevent.md)
-   [LDRA](LDRA.md)
-   [Cppcheck](Cppcheck.md)
-   [Parasoft C/C++Test](Parasoft.md)

These code metrics tools can be used:

-    [Understand](Understand.md) (Understand can be used
     on C/C++, C\#, Java, Python, ADA, etc.)

Java
----

These flaw-finding tools can be used for Java programs. We assume they
can be built using Oracle's JDK on Linux:

-   [Eclipse](Eclipse.md)
-   [FindBugs™](FindBugs-SpotBugs.md)
-   [SpotBugs](FindBugs-SpotBugs.md)
-   [Fortify SCA](Fortify-SCA.md)
-   [Coverity Prevent](Coverity-Prevent.md)

These code metrics tools can be used:

-   [Lizard](Lizard.md)(Lizard can be used on C, C++14, C\#, Java, Python, JavaScript, etc.)
-   [Understand](Understand.md) (Understand can be used on C/C++, C\#, Java, Python, ADA etc.)

Perl
----

These flaw-finding tools operate on Perl source code.

-   [Perl::Critic](Perl-Critic.md)
-   [B::Lint](B-Lint.md)

 Currently there are no Perl code metrics tools integrated with SCALe.
In the future, these code metrics tools could potentially be added:

-   [Perl Metrics Simple](http://search.cpan.org/~matisse/Perl-Metrics-Simple-0.18/lib/Perl/Metrics/Simple.pm){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)
-   [Perl Metrics Lite](https://metacpan.org/pod/Perl::Metrics::Lite){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)


To follow the list of tools, use these navigation buttons:

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Audit-Instructions.md)
[![](attachments/arrow_up.png)](Audit-Instructions.md)
[![](attachments/arrow_right.png)](GCC-Warnings.md)
