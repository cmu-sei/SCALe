---
title: 'SCALe : Perl::Critic'
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

SCALe : Perl::Critic
====================

Perl::Critic is an open-source static analysis tool. Perl::Critic's
different categories of alerts
are documented [on Perl::Critic's website](http://search.cpan.org/~thaljef/Perl-Critic-1.125/lib/Perl/Critic/PolicySummary.pod){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).

Here is the command to run Perl::Critic on all files ending in `.pl` in
the current directory:

```sh
perlcritic --severity 1 --force --verbose "^^ %p ^^ %f ^^ %l ^^ %m / %e / %s ^^\n" *.pl > perlcritic.txt
```

If your Perl files exist in multiple directories, you'll want to specify
them all on the command line. Providing a directory name should cause
Perl::Critic to analyze all Perl files in that directory and its
subdirectories.

Formatting Output For SCALe
---------------------------

The resulting file needs to be sanitized to be correctly handled by
SCALe. These commands sanitize the file:

```sh
perl -pi -e 's/::/_/g;' perlcritic.txt
perl -p -e 's/\|/BAR/g;' perlcritic.txt > perlcritic_results.txt
```
------------------------------------------------------------------------

[![](attachments/arrow_left.png)](FindBugs-SpotBugs.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](B-Lint.md)
