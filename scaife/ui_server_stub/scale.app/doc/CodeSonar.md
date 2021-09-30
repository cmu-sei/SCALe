---
title: 'SCALe : CodeSonar'
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

SCALe : CodeSonar
=================

*NOTE: These instructions were provided by a third-party, and the SEI has not verified or validated them.*
*NOTE: SCALe expects CodeSonar output in the standardized SARIF format, but these instructions provide output in an XML format that is specific to CodeSonar.*

Introduction
------------

CodeSonar is a proprietary static analysis tool released by Grammatech.

This document assumes that you have a CodeSonar hub running.

Run a Scan
----------

The basic command to launch a scan is:

```sh
codesonar analyze path/to/project-name host:port command
```

The full options are:
```sh
codesonar analyze /path/to/pfiles-name
  [-project [/[ancestors/]]proj-name] [-no-services] [-foreground] [-clean] [-clean-backend] [-force-base-hub-analysis]
  [-name analysis-name] [-preset preset-name] [-conf-file extra-conf-path] [-launchd-group ldgroup] [-launchd-key ldkey]
  [-watch-pid pid] [-watch-all-pids]
  [-auth authtype] [-hubuser username] [-hubpwfile pwfile] [-hubcert certfile] [-hubkey privatekeyfile]
  [[protocol://]host:port] [command]
```

CodeSonar has a way of determining the host and port if not specified.

For example, this command scans the dos2unix project:

```sh
codesonar analyze dos2unix make
```

Cleaning CodeSonar Projects
---------------------------

This command

```sh
codesonar analyze dos2unix -clean make
```

is useful in case the scan needs to be re-run.


Produce XML Report
------------------

Go to the CodeSonar home page (http://localhost:7340 for a default setup).  Click on your (scanned) project. This will bring you to the url: http://localhost:7340/analysis/7.html (The actual analysis number can vary, depending on the scan....it is 7 in this example.)

If the project is small, you can export the XML directly from the browser. To generate the full XML  point your web browser to http://localhost:7340/analysis/7-allwarnings.xml. (Again, the actual analysis number is 7 here, but can be different for your project.)  The generic url would be:

```
(generic url: <protocol>://<host>:<port>/analysis/<analysis-number>-allwarnings.xml)
```

This will display a web page of the XML report output. Save the page as an XML file.


If the project is large, then your web browser might not fetch or render the file properly. In that case, you can use the `curl` command:

```
curl http://user:xpass@localhost:7340/analysis/<analysis-number>-allwarnings.xml > output.xml
```

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Cppcheck.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](CCSM.md)
