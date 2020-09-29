---
title: 'SCALe : User Roles'
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

SCALe : User Roles
===================

The SCALe process involves developers, analysts, auditors, and
administrators. The number of people performing each role is variable.
For example, the SCALe process can be done by a single person performing
all roles or by a large organization with teams of people for each role.

### Developers

Developers are responsible for fixing any
[vulnerabilities](Terms-and-Definitions.md#vulnerability)
found in the software, and they serve as the foremost authorities on the
software's
[implementation](Terms-and-Definitions.md#implementation).
They also are responsible for providing the source code (to be
analyzed) to the SCALe app.

### Analysts

Analysts are responsible for running appropriate [static analysis](Terms-and-Definitions.md#static-analysis)
tools on the software. They may rely on the developers for wisdom about
properly building the software. Analysts are responsible for providing
tool output to the SCALe app.

### Auditors

Auditors evaluate alerts by evaluating code flaw conditions they are mapped to,
where a condition might be a particular CWE (e.g., CWE-190) or violation of a
CERT secure coding rule (e.g., INT31-C) or might even simply be a tool vendor's
definition of the checker type associated with the alert. An auditor makes an
evaluation determination for a code flaw condition, for that filepath and line
number, and it gets associated by SCALe with the tool's alert and one of its
mapped conditions, also known as an alertCondition. In this role, they are the
primary users of the SCALe app. To correctly evaluate alertConditions, auditors must be
familiar with the SEI CERT Coding Standards. These are available on
the web, and the
[C](http://www.cert.org/secure-coding/publications/books/cert-c-coding-standard-second-edition.cfm){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)
and [Java](http://www.cert.org/secure-coding/publications/books/cert-oracle-secure-coding-standard-for-java.cfm){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)
standards have been published by Addison-Wesley. CERT also offers
courses in [C and C++](http://www.sei.cmu.edu/training/P63.cfm){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) and Java
for secure coding.

### Administrator

The administrator is responsible for installing and maintaining the
SCALe app as well as any tools required by the analysts. The host
running the SCALe app need not be directly accessed by anyone except the
administrator.



------------------------------------------------------------------------

[![](attachments/arrow_left.png)](System-Requirements.md)
[![](attachments/arrow_up.png)](Welcome.md)
[![](attachments/arrow_right.png)](Installing-SCALe.md)
