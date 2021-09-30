---
title: 'SCALe : Fortify Usage Notes'
---
 [SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Introduction](Introduction.md) / [Static Analysis Tool Support](Static-Analysis-Tool-Support.md)
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

SCALe : Fortify Usage Notes
============================

  ------------------------------ --------------
  **Supported Languages**        C, C++, Java
  **Supported Versions**         TODO
  **Supported Output Formats**   XML
  ------------------------------ --------------

Formatting Output For SCALe
---------------------------

SCALe expects output from Fortify in an XML-encoded format. In
particular, the output should be formatted according to the "Developer
Workbook" template, as defined in the Fortify tool suite. This output
can be prepared from the Fortify Auditing Workbench UI, or by using the
following sequence of commands. This sequence assumes you have your
analysis results saved into the file **results.fpr**. It produces an XML
file named **fortify\_results.xml** in the current directory. You must
modify the first command to correctly assign the root directory of your
Fortify installation to the environment variable `FORTIFY_HOME:`

```sh
export FORTIFY_HOME=/your/path/to/fortify/HP_Fortify_SCA_and_Apps_4.10
ReportGenerator -format xml -f fortify_results.xml -source results.fpr -template $FORTIFY_HOME/Core/config/reports/DeveloperWorkbook.xml
```

If you have produced an FVDL file, you can feed that directly to
SCALe, without using the above command.
