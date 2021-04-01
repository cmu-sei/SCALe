---
title: 'SCALe : B::Lint'
---
 [SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Audit Instructions](Audit-Instructions.md) / [Static Analysis Tools](Static-Analysis-Tools.md)
<!-- <legal> -->
<!-- SCALe version r.6.5.5.1.A -->
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

SCALe : B::Lint
===============

B::Lint is an open-source static analysis tool.

To run B::Lint on a Perl codebase, ensure all necessary include paths
are defined in the `PERL5LIB` environment variable. The following
command analyzes all `.pl` files in the current directory:

```sh
perl -MO=Lint -all *.pl 2>&1 > blint.txt
```

If Perl files exist in multiple directories, specify them all on the
command line.

Formatting Output For SCALe
---------------------------

The resulting file needs to be processed, to be correctly handled by
SCALe. The following commands process the file:

```sh
perl -pi -e 's/::/_/g;' blint.txt
perl -p -e 's/\|/BAR/g;' blint.txt > blint_results.txt
```



------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Perl-Critic.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](Cascading-Determinations-from-Old-Codebase-to-New-Codebase.md)
