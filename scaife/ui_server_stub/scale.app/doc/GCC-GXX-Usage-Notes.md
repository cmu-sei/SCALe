---
title: 'SCALe : GCC/G++ Usage Notes'
---

[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Introduction](Introduction.md) / [Static Analysis Tool Support](Static-Analysis-Tool-Support.md)
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

SCALe : GCC/G++ Usage Notes
============================

  ------------------------------ ------------------------------------------------------------------------
  **Supported Languages**        C, C++
  **Supported Versions**         TODO
  **Supported Output Formats**   GCC/G++ output with `-fmessage-length=0`
  ------------------------------ ------------------------------------------------------------------------

SCALe accepts warnings from GCC and G++.   To produce a complete set of
warnings, we recommend that you add the following flags to your compiler
invocations.

For GCC

```
-std=c99 -O2 -fmessage-length=0 -Wall -Wextra -Wpointer-arith  -Wstrict-prototypes -Wformat-security
```

For G++

```
-std=c++98 -O2 -fmessage-length=0 -Wall -Wextra -Wpointer-arith -Wformat-security
```

Adding these compiler arguments requires some knowledge of the
underlying build system. For example, adding these arguments may require
modifications to a Makefile.

Also, these arguments specify a C/C++ standard (-std=c99 and -std=c++98,
respectively). If your source code is not compliant with these
standards, you may have to exclude these arguments.
