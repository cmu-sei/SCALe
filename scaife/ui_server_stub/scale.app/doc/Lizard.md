---
title: 'SCALe : Lizard'
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

SCALe : Lizard
===============

The Lizard code metrics tool is open-source and cost-free, with the
github project location at <https://github.com/terryyin/lizard>{.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)

We provide a version of Lizard with the SCALe distribution in the
`scale.app/scripts/lizard directory`)

Use our `scale.app/scripts/lizard_metrics.py` script to run the provided
version of Lizard on the codebase you are analyzing, to output a .csv
file with all the needed fields for SCALe's output uploader.

`usage: lizard_metrics.py [-h] [-p PATHNAME]`

`Gathers metrics via Lizard`

`optional arguments:`

`  -h, --help show this help message and exit`

`  -p PATHNAME, --pathName PATHNAME           `

Path in which to begin gathering metrics

Lizard can be used on C, C++14, C\#, Java, Python, JavaScript, [and many more languages (follow hyperlink for details).](https://github.com/terryyin/lizard){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](CCSM.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](Microsoft-Visual-Studio-Static-Analyzer.md)
