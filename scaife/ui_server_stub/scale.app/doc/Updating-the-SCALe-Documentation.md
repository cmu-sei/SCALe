---
title: 'SCALe : Updating the SCALe Documentation'
---
 [SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md)
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

SCALe : Updating the SCALe Documentation
=========================================

If code changes are made, the SCALe documentation needs to be updated to reflect
the changes.

1.	Create/edit the appropriate markdown files in scale.app/doc
2.	Rebuild the documentation using a tool for converting markdown to HTML like
		[Pandoc](http://pandoc.org){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).
		`scale.app/scripts/builddocs.sh` is provided to build the documentation with
		Pandoc (version 2.6 or greater).

Building the SCALe Documentation with Pandoc
--------------------------------------------
1.	Install [Pandoc](http://pandoc.org){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)
		version 2.6 or greater.
2.	Run `scale.app/scripts/builddocs.sh`
3.	The HTML formatted documentation will be generated in
		`scale.app/public/doc/scale2`
