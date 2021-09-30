---
title: 'SCALe : Find-Security-Bugs'
---
 [SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Audit Instructions](Audit-Instructions.md) / [Static Analysis Tools](Static-Analysis-Tools.md)
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

SCALe : Find-Security-Bugs
===========================

This is a plugin for FindBugs that focuses on specialized security
issues.

### Maven Integration

Find-security-bugs is already integrated with Maven. To run it on a
Maven project, you must integrate it into the toplevel `pom.xml` file.
To do this, follow the
instructions [here](https://github.com/h3xstream/find-sec-bugs/wiki/Maven-configuration){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png). The
directory tree becomes peppered with `findbugsXml.xml` files. Then, in
the toplevel directory, execute this command:

 ```sh
 find . -name findbugsXml.xml -print -exec convertXmlToText -html:dplain.xsl {} \; > project.txt
 ```

The file `dplain.xml` lives in the new\_scale directory that you checked
out earlier, and `convertXmlToText` lives in FindBugs' `bin` directory.

Once you have text output, here are instructions for [Converting Text Output to ORG files](Command-Line-Project-Creation.md).
For these your tool is 'findsecbugs'.
