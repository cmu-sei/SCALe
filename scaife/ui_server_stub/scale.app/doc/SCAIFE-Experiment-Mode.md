---
title: 'SCAIFE : Experiment Mode'
---

[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Source Code Analysis Integrated Framework Environment (SCAIFE)](SCAIFE-Welcome.md)
<!-- <legal> -->
<!-- Copyright 2021 Carnegie Mellon University. -->
<!--  -->
<!-- This material is based upon work funded and supported by the -->
<!-- Department of Defense under Contract No. FA8702-15-D-0002 with -->
<!-- Carnegie Mellon University for the operation of the Software -->
<!-- Engineering Institute, a federally funded research and development -->
<!-- center. -->
<!--  -->
<!-- The view, opinions, and/or findings contained in this material are -->
<!-- those of the author(s) and should not be construed as an official -->
<!-- Government position, policy, or decision, unless designated by other -->
<!-- documentation. -->
<!--  -->
<!-- References herein to any specific commercial product, process, or -->
<!-- service by trade name, trade mark, manufacturer, or otherwise, does -->
<!-- not necessarily constitute or imply its endorsement, recommendation, -->
<!-- or favoring by Carnegie Mellon University or its Software Engineering -->
<!-- Institute. -->
<!--  -->
<!-- NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING -->
<!-- INSTITUTE MATERIAL IS FURNISHED ON AN 'AS-IS' BASIS. CARNEGIE MELLON -->
<!-- UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR -->
<!-- IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF -->
<!-- FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS -->
<!-- OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT -->
<!-- MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, -->
<!-- TRADEMARK, OR COPYRIGHT INFRINGEMENT. -->
<!--  -->
<!-- [DISTRIBUTION STATEMENT A] This material has been approved for public -->
<!-- release and unlimited distribution.  Please see Copyright notice for -->
<!-- non-US Government use and distribution. -->
<!--  -->
<!-- This work is licensed under a Creative Commons Attribution-ShareAlike -->
<!-- 4.0 International License. -->
<!--  -->
<!-- Carnegie Mellon® and CERT® are registered in the U.S. Patent and -->
<!-- Trademark Office by Carnegie Mellon University. -->
<!--   -->
<!-- DM20-0043 -->
<!-- </legal> -->


Purpose
=======

Performance measurements will be collected for the following processes when SCAIFE is run in experiment mode:

* Creating a classifier
* Running a classifier
* Generating semantic features
* Applying dimensionality reduction
* Running adaptive heuristics


The collected performance measurements include:

* Elapsed time (in hours, minutes, and seconds)
* CPU time (in hours, minutes, and seconds)
* Memory used (MB)
* Disk space used (MB)
* CPU per core used (%)
  
Running SCAIFE in Experiment Mode
=================================

When starting the Stats Module server, the "`--experiment`" flag can be used to optionally record performance measurements.

NOTE: The following example commands don't include volume-sharing, which you likely will want to do for backing up data/files outside of containers and for migrating SCALe projects to new versions of SCALe. See [Migrating-All-SCALe-Projects-to-Later-SCALe-Versions.md](Migrating-All-SCALe-Projects-to-Later-SCALe-Versions.md) for information about how to modify these commands to do volume-sharing. If you are restarting a paused container and don't want to rebuild it, don't include the `--build` parameter. See more information aobut SCAIFE Docker container use and commands in [SCAIFE-Docker-Wisdom.md](SCAIFE-Docker-Wisdom.md)

If run using Docker containers, you can start SCAIFE containers in experiment mode with this command:

  `docker-compose -f docker-compose.yml -f docker-compose.experiment.yml up -d --build`

To start only the Docker container `stats` and start it in experiment mode, you can use this command:

  `docker-compose -f docker-compose.yml -f docker-compose.experiment.yml up -d stats --build`


To run SCAIFE in experiment mode without using Docker containers, you can use this command:

  `python3 -m swagger_server --experiment`

------------------------------------------------------------------------







