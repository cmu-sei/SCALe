---
title: 'SCALe : Static Analysis Tool Support'
---
[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Introduction](Introduction.md)
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

SCALe : Static Analysis Tool Support
=====================================

The intent of this document is to provide an overview of the static
analysis tools supported by SCALe. The goal is not to explain the gory
details of running each tool. Rather, the goal is to describe how each
tool is connected to SCALe. For in-depth tool usage information, refer
to your tool-specific documentation.

Static Analysis Tool Integration
--------------------------------

SCALe models external static analysis tools in a simple fashion. A tool
is seen as a collection of **checkers**, entities that detect certain
phenomena in a program. For example, a checker might detect null pointer
dereferences in a C program. The list of checkers for a given static
analysis tool is determined by studying the documentation for the tool
and running the tool on reference code bases. Every checker is assigned
a unique name within SCALe and is associated with a CERT Secure Coding
rule, such that behavior detected by the checker constitutes possible
violation of this rule. A specific instance of behavior detected by a
checker is called a **alert**.

Each static analysis tool has its own output format. The SCALe software
includes scripts for translating various tool outputs into a common
format. However, this translation process has some constraints. SCALe is
not guaranteed to support every output format for every version of every
tool. In the following sections, we'll delineate these constraints, for
each supported tool.
