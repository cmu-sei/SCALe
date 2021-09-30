---
title: 'SCALe : Audit Instructions'
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

SCALe : Audit Instructions
===========================

These instructions assume that you have a source codebase that is
suitable for SCALe. A suitable codebase must be analyzable by the
tools supported by SCALe. These tools require that the codebase must be
compiled. Code that is missing internal libraries or headers cannot be
analyzed in SCALe until these missing components are supplied.

While compilation is a requirement, the codebase does not need to link
properly or run properly. Many static analyzers, including Coverity and
Fortify, require access to a functioning build of the source. These
analyzers rely on compiler processes invoked during the build (for
example, GCC) to parse the source. Some tools process the source
directly, but often with lower quality results.

The steps for analyzing a codebase through SCALe are as follows.

### 1. Perform a Test Build

A test build is simply a compilation of the codebase. You build it using
whatever instructions are provided by the codebase's developers. The
instructions could be as simple as typing `make` into a UNIX terminal.
The test build should occur on a platform with the same specifications
that the analysis tools live on. For instance, if your analysis tools
live on Xubuntu 18, perform the test build on an Xubuntu 18
platform.

The test build is critical to ensuring that you have a complete,
compilable codebase that is ready for analysis. Once the test build is
completed, you can discard it. You will build it again while running the
analysis tools over the code anyway.

### 2. Run the [Static Analysis Tools](Static-Analysis-Tools.md) associated with your source codebase's platform.

### 3. Upload your codebase and analysis tool output to the SCALe web app.
Useful howto info in [Upload Source Code and Analysis Outputs (part of quick-start demo)](Upload-Source-Code-and-Analysis-Outputs.md) and [Upload output from Static Analyzers (both alerts from general flaw-finder tools and metrics from code metrics tools)](#uploading-output-from-static-analyzers-both-alerts-from-general-flaw-finder-tools-and-metrics-from-code-metrics-tools).

You can do the uploading once you have useful text output from your
analysis tools. The web app can build the database internally, given the
source code and alert tool output.

Here are a few alternatives for performing the audit without using the
web app:

-   [CSV file](CSV-file.md), for MS Excel lovers
-   [ORG files](Emacs-ORG-files.md), for Emacs lovers
-   [SQL Dump](SQL-Dump.md), for brave Emacs
    users

### 4. If the codebase has undergone a previous SCALe audit (perhaps as an earlier version), you will want to apply its previous determinations.

See [Cascading Determinations from Old Codebase to New
Codebase](Cascading-Determinations-from-Old-Codebase-to-New-Codebase.md)
for how to do this.

If your codebase has never gone through a SCALe audit before, you may
skip this step.

### 5.  [Validate the SCALe AlertConditions](Validating-SCALe-AlertConditions.md)

### 6. [Construct the SCALe Audit Report](Building-an-Audit-Report.md)

In fact, you can begin the report before completing the previous steps.
See this section for details.

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Export-Analysis-Results-from-the-Web-Application.md)
[![](attachments/arrow_up.png)](Welcome.md)
[![](attachments/arrow_right.png)](Static-Analysis-Tools.md)
