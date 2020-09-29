---
title: 'SCALe : Notes on Languages vs Platforms'
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

SCALe : Notes on Languages vs Platforms
=======================================

-   [Overview](#overview)
-   [Languages](#languages)
-   [Tools](#tools)
-   [Taxonomies](#taxonomies)

## Overview

Historically SCALe has treated the concepts of a "code language" and a
"platform" in a fuzzy fashion -- platforms and languages are certainly
related, but not exactly the same. The main reason for this is the fact
that many tools are capable of analyzing both C and C++ at the same time
even though they are different languages. So the "platform" of "c" was
shorthand for representing both of these related languages.

SCALe now treats C and C++ as their own distinct languages, even if a
particular tool is handling both. But languages also have versions now.

So now, "platform" is a shorthand representation of a single language
family covering all versions of that language. On a practical level it
is used in the back-end processing for locating filenames on the
filesystem. It can be used to make certain inferences in the SCALe DB as
well, but that useage isn't as fundamental.

Languages, Tools, and Taxonomies all have an association with one or
more platforms/languages, but in different ways. The most important
connection is between Languages and Tools and their definitions in
their respective JSON files that are used to initialize the SCALe
database. Taxonomies will be explained separately. The sections below
offer more detail.

## Languages

The primary definition of a "platform" is specified in the
[`languages.json`](#languages.json) configuration file. Each language
has a name, platform, and known versions. 'C' is 'c', 'C++' is 'cpp',
'JavaScript' is 'js', and so on. The platform is present in the SCALe
database `Languages` table for each version of a language.

## Tools

Tools are defined in the [`tools.json`](#tools.json) configuration
file. Tools also have versions associated with them as well as
languages/language groups. The languages defined for a tool in this
file must correspond to languages defined in
[`languages.json`](#languages.json). It is through this correlation
that tools get associated with platforms. Each version of a tool in
the SCALe database `Tools` table has a platform string. It can
represent multiple platforms and is a JSON encoded list, for example,
`["c", "cpp"]`.

In later processing of the analysis output of one of these tools, it can
be ascertained which language families (or "platforms") were actually
detected during the analysis. These associations do not include
versions of any particular language, however. This information can be
used to determine upload requirements of languages to SCAIFE prior to
uploading a tool used in a project.

## Taxonomies

Taxonomies are defined in the [`taxonomies.json`](#taxonomies.json)
file. They have a much less formal relationship to platforms, and
therefore to languages. The CERT taxonomies and conditions are very much
tied to specific languages, but the MITRE CWEs taxonomy conditions
generally apply to multiple languages. Consequently, the `platform`
column in the extra fields of a particular condition entry is not
guaranteed to refer to any particular platform in the sense it is
defined in the `Languages` table.

The relationship is not essential. While processing the analysis
output of a tool, the conditions (and therefore taxonomies)
associated with an alert can be ascertained. So within a project,
SCAIFE upload requirements for taxonomies can be determined prior to
uploading the project.

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](DB-Design-for-per-project-SQLite-files-in-backup.md)
[![](attachments/arrow_up.png)](Welcome.md)
[![](attachments/arrow_right.png)](Adding-a-Tool-to-SCALe.md)
