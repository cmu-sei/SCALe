---
title: 'SCALe : Tips for SCALe performance improvement'
---
[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Installing SCALe](Installing-SCALe.md)
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

SCALe : Tips for SCALe performance improvement
===============================================

Most of SCALe's development historically has been performed as part of
research projects, instantiating new features for the research work in a
software prototype built for experimentation but not for performance.

This page lists tips for SCALe users to improve its performance (e.g.,
page display rate, project creation, time to export).

Increasing memory (on the host machine and/or on VMs) is often helpful
for performance improvement.

On virtual machines we distribute (or that you create), the
initially-allocated memory may be small (e.g., currently the SCAIFE System VM distributions use 24 GB memory, but in the past we have
distributed SCALe VMs with 1-4 GB memory). Instructions how to increase
VM memory:

-   <http://kb.mit.edu/confluence/pages/viewpage.action?pageId=148602892>{.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)
-   <https://pubs.vmware.com/vsphere-4-esx-vcenter/index.jsp?topic=/com.vmware.vsphere.webaccess.doc_40/configuring_virtual_machine_options_and_resources/t_edit_memory_configuration.html>{.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)

Faster host machine CPUs, memory, and disk transfer rates often help.

Examining performance bottlenecks on your own machines (e.g., is memory
at max use? cpu? etc.) may help you to determine what can help SCALe
performance on your own machine. To do that, you can run the SCALe app
under a profiler
like <https://github.com/MiniProfiler/rack-mini-profiler>{.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)

Some processes, e.g. fused view creation, may be less efficient than
optimal, and modifications to the code could help with that.

Contributions to SCALe code that helps performance improvement (and that
helps with bug-fixes and new features) are welcome. Please contact us to
contribute code.
