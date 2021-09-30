---
title: 'SCALe : Microsoft Visual Studio Static Analyzer'
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

SCALe : Microsoft Visual Studio Static Analyzer
===============================================

Microsoft Visual Studio (henceforth known as MSVS) comes with a static
analyzer for C/C++ code.   MSVS's different categories of alerts
are documented  [on
MSDN](https://msdn.microsoft.com/en-US/library/a5b9aa09.aspx){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).

To harvest the warnings from MSVS's static analyzer on a project (that
already builds correctly under MSVS), first import a
`.sln` (solution) file into MSVS. Then
select `Build → Run Code Analysis on Solution` or press `Alt-F11`.

Formatting Output For SCALe
---------------------------

Once MSVS has finished its analysis, select all of its output,
right-click, and select `Copy`. Then paste
into Notepad (or any other text editor) and save the text output to a
file.

CAUTION: This output provides warnings about a different set of code
flaws than the output from running MSVS normally. (This output is not a
superset!) To also obtain warnings for the MSVS compiler's (additional)
checkers, output from running MSVS normally is also needed. SCALe
includes mappings between MSVS compiler checkers and CERT rules (from
MSVS compiler standard runs), as well as mappings between MSVS's Static
Analyzer Tool and CERT rules.

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Lizard.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](PC-Lint-FlexeLint.md)
