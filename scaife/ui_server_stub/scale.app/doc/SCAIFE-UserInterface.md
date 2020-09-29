---
title: 'SCAIFE : User Interface (UI) Module'
---

[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Source Code Analysis Integrated Framework Environment (SCAIFE)](SCAIFE-Welcome.md)
<!-- <legal> -->
<!-- SCAIFE System version 1.2.2 -->
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
<!-- [DISTRIBUTION STATEMENT F] Further dissemination only as directed by -->
<!-- OSD/ASD R&E (determination date: 2019-12-11) or higher DoD authority. -->
<!--  -->
<!-- Notice to DoD Subcontractors: This document may contain Covered -->
<!-- Defense Information (CDI).  Handling of this information is subject to -->
<!-- the controls identified in DFARS 252.204-7012 – SAFEGUARDING COVERED -->
<!-- DEFENSE INFORMATION AND CYBER INCIDENT REPORTING -->
<!--  -->
<!-- This Software includes and/or makes use of Third-Party Software -->
<!-- subject to its own license. -->
<!--  -->
<!-- This material includes field names used in the Software Assurance -->
<!-- Marketplace (SWAMP), a service that provides continuous software -->
<!-- assurance capabilities to developers and researchers at -->
<!-- https://www.mir-swamp.org/#.  Copyright © 2012-2020 The Morgridge -->
<!-- Institute for Research, Inc. All rights reserved.” -->
<!--  -->
<!-- This material includes field names used in the Software Assurance Tool -->
<!-- (SwAT), a tool that is used by analysts to analyze static analysis -->
<!-- alerts from multiple static analysis -->
<!-- tools. https://www.cerdec.army.mil/ Combat Capabilities Development -->
<!-- Command (CCDC) C5ISR Center. All rights reserved. -->
<!--  -->
<!-- DM19-1273 -->
<!-- </legal> -->

The SCAIFE manual (documentation) copyright covers all pages of the SCAIFE/SCALe manual with filenames that start with text 'SCAIFE' and that copyright is [here](SCAIFE-MANUAL-copyright.md).

The non-SCALe part of the SCAIFE _system_ has limited distribution that is different than the SCALe distribution. [Click here to see the SCAIFE system copyright.](SCAIFE-SYSTEM-copyright.md)

The SCAIFE API definition has its own distribution that is different than the SCAIFE system, SCAIFE manual, and SCALe distribution. The SCAIFE _API_ definition copyright is [here](SCAIFE-API-copyright.md)

SCAIFE : User Interface (UI) Module
=====================

- [Overview](#overview)
- [SCAIFE Prototype UI Module](#scaife-prototype-ui-module)
  - [Uploads](#scale-uploads)
    - [Languages](#scale-upload-languages)
    - [Tools](#scale-upload-tools)
    - [Taxonomies](#scale-upload-taxonomies)

Overview
--------

Any static analysis tool that displays alert data in a GUI front
end--including tool aggregators like SCALe, SWAMP, or SwAT, can
instantiate SCAIFE API calls to become a User Interface (UI) module. The
User Interface (UI) Module will be used to interact with the other
servers in the architecture to perform alert classification and advance
prioritization.


SCAIFE Prototype UI Module
--------------------------

[SCALe](Welcome.md) is one instantiation of a SCAIFE UI module. We've
modified the previous version of SCALe for (optional) SCAIFE
integration.

### Uploads

Components in SCALe can be uploaded to SCAIFE so that they can be shared
across projects. These are typically from within a project context but
can also be uploaded independently of a particular project.

Note that several constructs in SCAIFE are associated with "platforms",
namely checkers and conditions. The values for these "platforms" (think
operating systems) currently have no direct association with the
"platform" (think code languages) as seen in the SCALe database. For
more information on how SCALe represents languages, tools, and
taxonomies (and their association with "platforms"), see [Notes on
Languages vs Platforms](Notes-on-Languages-vs-Platforms.md).

#### Languages

SCALe initializes its local language information from a JSON data file
[`languages.json`](#languages.json).

Language uploads and mappings:
The user selects which languages and versions to upload or map and then
commences the upload to the SCAIFE DataHub. If the user is working from within a project
context, language versions must first be selected for that project before
uploading.

The association between a SCAIFE code language and a SCALe code
language is generally predicated on having an identical "name" and
"version" -- this might not apply if the user manually maps a SCALe
language to a pre-existing SCAIFE language.

#### Tools

SCALe initializes its local tool information from a JSON data file
[`tools.json`](#languages.json).

Prior to uploading a tool to SCAIFE, certain language requirements must
be met for that tool. If uploading from outside of a project context,
SCALe requires **all versions** of the language types that a tool might
possibly support. From within a project context, however, SCALe requires
**at least one** version of each language type that was actually
detected during the analysis run of that tool.

The association between a SCAIFE analysis tool and a SCALe
analysis tool is generally predicated on having an identical "name",
"version", and "type" -- this might not apply if the user manually maps
a SCALe tool to a pre-existing SCAIFE tool.

#### Taxonomies

SCALe initializes its local taxonomy information from a JSON data file
[`taxonomies.json`](#taxonomies.json).

Taxonomy uploads and mappings: 
The user selects which taxonomies and versions to upload or map and
then commences the upload to the SCAIFE DataHub. If the user is working from within a project
context, taxonomy versions must first be selected for that project before
uploading.
Taxonomy types required for a project can be inferred through the
results of the analysis run for that project.

The association between a SCAIFE taxonomy and a SCALe taxonomy
is generally predicated on having an identical "name" and "version" --
this might not apply if the user manually maps a SCALe taxonomy to a
pre-existing SCAIFE taxonomy.
