---
title: 'SCALe : Terms and Definitions'
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

SCALe : Terms and Definitions
==============================

## Analyzer
Mechanism that diagnoses coding flaws in software programs.


**NOTE** Analyzers may include static analysis tools, tools within a compiler
suite, or tools in other contexts. [ISO/IEC 9899:2011]
ISO/IEC. *Programming Languages—C, 3rd ed* (ISO/IEC 9899:2011). Geneva,
Switzerland: ISO, 2011.

## Alert
A warning from a flaw-finding static analysis tool, specific to 1. a particular code
location (line number and filepath); 2. a checker ID (a type of flaw that
the tool looks for, where the combination of all checker IDs in a tool define
the tool's internal taxonomy for code flaws); and 3. a unique message and/or unique set of 
secondary messages. Secondary messages are information provided by some tools about control-flow, 
data-flow, and/or type-flow that can lead to the code flaw at the alert's line number that 
the alert's primary message and checker ID warn about.

## Condition
A constraint or property of validity with which code should comply. Flaw-finding static
analysis tools try to detect if code violates conditions.

## alertCondition
A single alert combined with information about only one of the
externally-defined taxonomy conditions the SA tool's checker maps
to. An example of an externally-defined taxonomy condition: CWE-190 is
a condition from the CWE taxonomy, and CWEs are defined externally to
any SA tool. In SCALe versions 3.0 and newer, in 'Unfused view', each
row of the 'alertCondition List' shows an alertCondition and the total
count shown is the count of alertConditions. (Detail: Since we use a
database table named Displays to store one row per
alertCondition. There are filters in the GUI for viewing and
prioritizing according to "Display (d) ID".)

## Display
A display is the representation of an alertCondition in the SCALe 'alertCondition List'.
Each display has a unique Display (d) ID.

## Meta-Alert
A construct used in SCALe versions 3.0 and newer to link alerts that
are mapped to the same 1) code location (line number and filepath);
and 2) code flaw condition (specifically, a condition from a taxonomy
external to any particular static analysis tool). For example, CWE-190
is a condition from the CWE taxonomy. In SCALe versions 3.0 and newer,
determinations (e.g., true and false) are made at a meta-alert level.
Note that each alert in SCALe versions 3.0 and newer has a meta-alert,
even when only one alert maps to that code location and code flaw
condition. In Fused view, the total count shown is the count of
meta-alerts.

## Fused alertConditions
In SCALe versions 3.0 and newer, this refers to what a user sees on
the GUI when multiple alerts map to a meta-alert, and the view
selected is 'fused view'. In 'Fused view', each top-level (not
expanded) row of the 'alertCondition List' shows a meta-alert. It
shows the meta-alert ID if the meta-alert is linked to multiple
alerts, and in such a case that meta-alert can be selected and the
view expanded to show the list of alerts it is mapped to. Detail: Each
individual expanded row shows the DisplayID for that alert, which is
unique per alertCondition (Each of these alerts can separately be
selected provide a new view, showing each of the alertConditions for
that alert). In the 'unfused view', alerts are not fused, and every
row of the 'alertCondition List' shows an alertCondition.

## implementation
Particular set of software, running in a particular translation
environment under particular control options, that performs translation
of programs for, and supports execution of functions in, a particular
execution environment. [ISO/IEC 9899:2011]

## MSVS
Microsoft Visual Studio. A Windows IDE whose C/C++ support is
[integrated](Microsoft-Visual-Studio-Static-Analyzer.md) in SCALe.

## SCALe
Source Code Analysis Lab, an application and process for detecting
vulnerabilities in source code using multiple static analyzers.

## static analysis
Any process for assessing code without executing it. [ISO/IEC TS
17961] ISO/IEC TS 17961. *Information Technology—Programming Languages,
Their Environments and System Software Interfaces—C Secure Coding
Rules.* Geneva, Switzerland: ISO, 2012.

## vulnerability
Set of conditions that allows an attacker to violate an explicit or
implicit security policy. [ISO/IEC TS 17961:2013]

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Manual-Project-Creation.md)
 [![](attachments/arrow_up.png)](Welcome.md)
