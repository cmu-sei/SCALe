---
title: 'SCALe : Parasoft C/C++Test'
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

SCALe : Parasoft C/C++Test
===========================

C/C++Test is a proprietary static analysis tool from Parasoft. It
provides full support for the CERT C Coding Standard. It is documented on [Parasoft's website](https://docs.parasoft.com/display/CPPDESKE1040){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)

The GUI tool is based on Eclipse.

Building
--------

A project that has its own build file (such as a makefile) should be
built from the command line first. This informs C/C++Test of compiler
options. The best recommendation is to embed the `cpptestscan` command
into the build process.

For example, a codebase that is built using make and GCC can be built
with the following command:

```sh
make all  CC="cpptestscan --cpptestscanOutputFile=`pwd`/cpptestscan.bdf --cpptestscanProjectName=$PROJECT gcc"
```

A simpler way to build the system is to prefix the build with
the `cpptestscan` command:

```sh
cpptestscan make all
```

More documentation is
available [here](https://docs.parasoft.com/display/CPPDESKE1040/Creating+a+Project+Using+an+Existing+Build+System){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).

Analysis
---------

In Eclipse, create a new C++test project from existing data file.

Create a custom test configuration (the example test configuration is
sufficient). This can be done using `Parasoft->Test Configurations`. The
new test configuration should include the CERT rules. Under
`User Defined / Static Analysis`. Then select `Static` tab and check
`SEI CERT C` (and uncheck other rules).

To test the project, select it in the `Test Case Explorer` view., and
then select `Parasoft → Test Using` the new configuration.

Report
------

Under the `Quality Tasks` view, select `Report` (which may be a toolbar
button or hidden in the rightmost menu).

In the new Report wizard, select `Preferences`. Then
under `Change Format`, select `XML SATE`.

Then, in the wizard, provide a path, which should end with a
(non-existing) XML file. Then select `Apply`.

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](LDRA.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](Understand.md)
