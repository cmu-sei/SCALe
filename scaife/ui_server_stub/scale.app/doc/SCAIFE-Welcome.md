---
title: 'SCAIFE : Source Code Analysis Integrated Framework Environment (SCAIFE)'
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

SCAIFE : Source Code Analysis Integrated Framework Environment (SCAIFE)
=========================================

Welcome to the SCAIFE documentation!

-   [Purpose](#purpose)
-   [SCAIFE Overview](#scaife-overview)


Purpose
-------

The purpose of this document is to provide usage information for new
SCAIFE users, whether individuals or organizations. This document is meant
to be read electronically (although no Internet connectivity is required),
so we use hyperlinks to direct readers to other parts of the document.


SCAIFE Overview
---------------

Source Code Analysis Integrated Framework Environment (SCAIFE) is a multi-server architecture
with an application programming interface (API) and an open-source prototype that enables
static analysis alert classification and prioritization. It is designed so a wide variety of
static analysis tools can integrate with the system using the API definition. The SCAIFE
architecture shown below includes five types of servers:

1.  [Registration Module](SCAIFE-Registration.md)
1.  [DataHub Module](SCAIFE-DataHub.md)
1.  [Statistics (Stats) Module](SCAIFE-Statistics.md)
1.  [Prioritization Module](SCAIFE-Prioritization.md)
1.  [User Interface (UI) Module](SCAIFE-UserInterface.md)
1.  [Customizing SCAIFE](SCAIFE-Customization.md)
1.  [Extending SCAIFE manual](SCAIFE-Editing-Manual.md)
1.  [Managing SCAIFE servers](SCAIFE-Server-Management.md)
1.  [Automated Distribution of SCAIFE](SCAIFE-Automated-Distribution.md)


![](attachments/SCAIFE_architecture.png)

------------------------------------------------------------------------
