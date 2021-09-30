---
title: 'SCALe : Coverity Prevent Usage Notes'
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

SCALe : Coverity Prevent Usage Notes
=====================================

  ------------------------------ --------------
  **Supported Languages**        C, C++, Java
  **Supported Versions**         TODO
  **Supported Output Formats**   JSON
  ------------------------------ --------------

Coverity Analysis
-----------------

For analyzing C/C++ code, we recommend that you invoke your Coverity
analysis with the following parameters:

```
cov-analyze --dir <coverity_output_dir> --aggressiveness-level medium --all
```

For Java code, we recommend the following invocation:

```
cov-analyze-java --dir <coverity_output_dir> --all
```

Formatting Output For SCALe
---------------------------

SCALe expects output from Coverity in a JSON-encoded format. Once your
analysis is complete, run the following command to prepare output for
SCALe:

```
cov-format-errors --dir <coverity_output_dir> --json-output-v2 coverity_results.json
```
