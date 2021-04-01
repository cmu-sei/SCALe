---
title: 'SCALe : Building an Audit Report'
---
 [SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Audit Instructions](Audit-Instructions.md)
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

SCALe : Building an Audit Report
=================================

The SCALe audit report summarizes the findings of an audit. It is
intended to be readable by the owners of a codebase that has undergone
an audit. These owners might be the developers or maintainers of the
codebase, but need not be. Except for Chapter 3, the report assumes no
knowledge of coding. Section 3 describes coding mistakes in detail, but
its purpose is to provide credibility.

The audit report is accompanied by two tables, packaged as Excel
spreadsheets. The first table identifies all the confirmed violations
(true positives) found in the audit, and (for auditors using [what we
call 'method \#2 for alertCondition validation](Validating-SCALe-AlertConditions.md)')
the second table identifies all the suspicious alertConditions (assumed
true, but not inspected by a human). The format of these spreadsheets is
documented in Section 4 of the report. Alternatively (for auditors using
[what we call 'method \#1 for alertCondition validation](Validating-SCALe-AlertConditions.md)')
, the second table could include all alertConditions defined as
expected-true-positive according to the classifier.

Both a [template](attachments/SCALe_Audit_Report.docx) and
an [example](attachments/Jasper_SCALe_Audit_Report.docx) report are available.
To use the template, replace all sections of text between "&lt;" and
"&gt;" symbols where the text only contains capital letters (and
possibly also one or more spaces and/or punctuation marks), e.g.,
"&lt;CAPITAL LETTERS, POSSIBLE PUNCTUATION, AND POSSIBLE SPACES&gt;".
Examine the template's (MS Word) comments for additional editing
instructions.

A report comes with a spreadsheet of alerts.
A [template spreadsheet](attachments/SCALe_Audit_Report_Template.xlsx) is
available. To use this template, do the following:

1.  Export the SCALe project as a CSV file from the web app.
2.  Import this CSV file into Excel
3.  Open the template file in Excel, and go to the *raw* worksheet.
4.  Replace the data in the raw worksheet with the new project data.
    (This seems to work well only if you delete all but the first line,
    then cut the SCALe project data and paste it to the raw worksheet,
    selecting only cell A2)
5.  Select one of the other worksheets, and then Pivot Table Tools -&gt;
    Refresh All
6.  All the charts should update with the new data.
7.  In the /raw/ worksheet, remove the 'flag', 'previous', and 'link'
    columns.
8.  The table is now ready for the client.

Many chapters in the report include statistics about the audited
codebase. See "[Source Code
Statistics](Source-Code-Statistics.md)" for what each
statistic means and how to obtain it.

-   [1.  Introduction](#introduction)
    -   [Code Size Metrics](#code-size-metrics)
-   [2. Findings](#findings)
    -   [Violations by Priority](#violations-by-priority)
    -   [Violations by Tool](#violations-by-tool)
    -   [Violations by CERT Rule](#violations-by-cert-rule)
    -   [Audit Summary Statistics](#audit-summary-statistics)
-   [3. Analysis of Findings](#analysis-of-findings)
-   [4. AlertCondition Findings](#alert-findings)
-   [5. Procedure](#procedure)

The ideal SCALe audit report is like the ideal hamburger; it consists of
5 sections:

### 1. Introduction

This is the hamburger bun. It is starchy and dry, but important in
holding the report together.

This chapter introduces the codebase. It provides some simple statistics
about the size of the codebase being audited. The purpose of this
chapter is to outline precisely what code was audited and what code was
ignored. Many codebases depend on libraries, which are provided in
binary form. This enables the codebase to be built, but the libraries
cannot be audited themselves unless their source code is also provided.
In theory, any library can contain vulnerabilities that would compromise
a system; consequently, every attached library should be audited. In
practice, this is usually impractical. Consequently, this chapter
indicates any un-audited libraries or ignored code.

This chapter can be written any time after the code has been built
successfully. It contains the following table:

#### Code Size Metrics

This is a table which lists the following statistics:

-   Codebase
-   Files
-   Distribution
-   kLoC
-   ksigLoC
-   Source

### 2. Findings

This is the actual meat in the hamburger; it provides the most nutrition
and flavor.

This section summarizes the audit alertConditions that turned out to be true
or probable. It consists mostly of graphs that detail which CERT rules
were violated, which tools found the violations, and how severe the
violations actually were. It also compares the codebase's metrics (how
many violations, code size, etc.) against the average metrics for all
codebases submitted to SCALe. This should give the codebase owners a
rough idea of the quality of their code.

This section cannot be written until the rest of the audit is complete.
It contains the following tables and charts:

#### Violations by Priority

A vertical bar chart that counts True and Suspicious alertConditions (on Y
axis) indexed by priority (X axis). The highest priority (27) is nearest
the origin, this represents the most critical alertConditions that are
easiest to fix. True vs. Suspicious alertConditions are indicated by colors
in the bar lines.

#### Violations by Tool

An exploded pie chart that counts True and Suspicious alerts. The
pie colors indicate static analysis tools, so this chart indicates which
tools are the most useful. (Typically all tools contribute to the
alerts reported.)

#### Violations by CERT Rule

A horizontal bar chart that counts True and Suspicious alerts
associated with the title of each CERT rule, and sorted from least
alerts to most. In the bars, different colors represent distinct SA
tools.

#### Audit Summary Statistics

A table that provides audit statistics. There are three rows in the
table. The first row indicates statistics for the codebase being
audited. The second row indicates mean values for all audited codebases
(in the same programming language), and the third row indicates standard
deviations for all audited codebases (in the same language). This gives
clients an idea of how their code compares to other codebases that we
have audited. The columns are:

-   Codebase
-   Files
-   kLoC
-   ksigLoC
-   Rules
-   True
-   Suspicious  (for auditors using [what we call 'method \#2 for alertCondition validation](Validating-SCALe-AlertConditions.md)')
-   The additional basic, supplemental, and any other (e.g.,
    organization-defined and using Flag) determinations  (for auditors
    using [what we call 'method \#1 for alertCondition validation](Validating-SCALe-AlertConditions.md)')
-   File Density
-   Line Density

### 3. Analysis of Findings

This is the cheese in the burger. It may be small, but enhances the
flavor.

This section consists of blurbs. The number of blurbs averages 5, but
can be more or less if desired. Each blurb should examine a single
alertCondition and justify why the auditor considered it to be a true positive.
The purpose of this section is to convince the codebase owners that the
report is credible; it showcases real vulnerabilities. Ideally, the
alerts examined should be the most severe ones found. Each blurb
should indicate a violation of a different secure coding rule to
showcase the breadth of the analysis.

Each blurb should contain the following information:

-   An excerpt of the vulnerable code, large enough to illustrate the
    vulnerability
-   Location of the code (path, file, line numbers)
-   Condition (e.g., CWE instance or CERT Secure Coding rule being
    violated)
-   Justification of the alert; e.g., a brief explanation of why
    the code violates the rule or is an instance of that CWE
-   Consequence of condition (e.g., violating the CERT coding rule or
    being an instance of the CWE); that is, how the vulnerability could
    be exploited
-   Remediation; that is, how to fix the code

We recommend that every auditor who marks an alertCondition as true produce a
blurb about the alertCondition. Thus the job of writing this chapter simply
consists of assembling significant blurbs. The blurbs also have a
beneficial side effect; they allow auditors to re-examine the alertCondition
and ensure they made no mistakes in their evaluation. Auditors will
often want to share alertConditions with each other to verify their
accuracy, and producing a blurb makes an alertCondition easy to share and
review. Blurbs produced by junior auditors make it easy for senior
auditors to guide them in auditing code correctly.

### 4. AlertCondition Findings

This is the other bun in the burger. A necessary component to hold the
report together, but not much flavor.

This chapter describes the contents of the spreadsheets that come
attached to the report.

This chapter can be written before the audit begins. In fact, it can
often be copied verbatim from a previous audit report, such as
the [example audit report](attachments/Jasper_SCALe_Audit_Report.docx). If you
copy this chapter from a previous report, you should review it in case
any material has become outdated.

### 5. Procedure

This is the lettuce and tomato in the burger. It's good for you and
provides texture, but it has little flavor and you keep it in for good
health.

This chapter describes the background of SCALe and code flaw taxonomies
used in the audit, e.g., CWEs and the CERT Coding standards. It also
includes a summary of details for each static analysis tool.

This chapter can be written before the audit begins. In fact, it can
often be copied verbatim from a previous audit report, such as
the [example audit report](attachments/Jasper_SCALe_Audit_Report.docx). If you
copy this chapter from a previous report, you should review it in case
any material has become outdated.

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Validating-SCALe-AlertConditions.md)
[![](attachments/arrow_up.png)](Audit-Instructions.md)
[![](attachments/arrow_right.png)](Web-App-Design.md)

Attachments:
------------

![](images/icons/bullet_blue.gif) [TEMPLATE\_SCALe Audit Report.docx](attachments/SCALe_Audit_Report.docx)
(application/vnd.openxmlformats-officedocument.wordprocessingml.document)\
![](images/icons/bullet_blue.gif) [SCALe chart open source.xlsx](attachments/SCALe_chart_open_source.xlsx)(application/vnd.openxmlformats-officedocument.spreadsheetml.sheet)\
![](images/icons/bullet_blue.gif) [Jasper SCALe Audit Report.docx](attachments/Jasper_SCALe_Audit_Report.docx)
(application/vnd.openxmlformats-officedocument.wordprocessingml.document)\
![](images/icons/bullet_blue.gif) [SCALe chart open source.xlsx](attachments/SCALe_Audit_Report_Template.xlsx)
(application/vnd.openxmlformats-officedocument.spreadsheetml.sheet)\
