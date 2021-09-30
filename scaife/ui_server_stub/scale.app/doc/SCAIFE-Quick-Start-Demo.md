---
title: 'SCAIFE : SCAIFE Quick Start Demo'
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


SCALe : SCAIFE Quick Start Demo
============================================

This demo walks the user through starting up the full SCAIFE system, creating a project via the GUI, creating a SCAIFE account and logging in, uploading the project to the SCAIFE DataHub, specifying a classifier, creating the classifier, running it on the project, then viewing the static analysis meta-alert classification results in the SCAIFE GUI.

Instructions that only apply for SEI developers/testers will be prefaced by "For SEI developer/testers only" and those limited instructions end at the next vertical space.

To run the SCAIFE quick-start demo, proceed as follows:


## Setting up the system to run the demo

(This section is for SEI developer/testers only)

In a Linux (VM or direct on host) or Mac environment, SEI folks should set this up by first cloning the SCAIFE repository e.g., in a terminal:

`git clone ssh://git@bitbucket.cc.cert.org:7999/scal/scaife.git`

Then, in the scaife directory, SEI folks should get the submodules for scale.app and the (two!) submodules for rapidclass_scripts by running this command (it will take awhile, maybe 5 or more minutes):

`git submodule update --init`

## Running the system

Startup the full SCAIFE system. In the scaife directory run this command in a terminal: 

`docker-compose -f docker-compose.yml up --build`

After the build is complete, you will see continuous scrolling of log data that the containers are producing. This will appear as vertical column lines, various log messages, and scale text in color. The colored text are the servers that are communicating, indicating that SCAIFE is finished building and is now running.

**Note:**
Before running the SCAIFE quick-start demo, you should have run the SCALe demo first. SCALe demo can be found at [SCALe-Quick-Start-Demo-for-Auditors](SCALe-Quick-Start-Demo-for-Auditors.md).

## SCAIFE quick-start demo

Once SCAIFE is started up, open the following 2 tabs in your browser:

1. SCALe web application GUI:

    	- http://localhost:8083/users/unauthorized

In the SCALe web application GUI, click on `SCALe Login` and enter your credentials. If you’re doing this for the first time, select `SCALe Login`, then `Sign Up`, and then create a username and password.

Next, click on the `SCAIFE login` and click `Sign up`, and create a username and password for that.

2. SCALe/SCAIFE manual index focused on SCAIFE

    	- http://localhost:8083/doc/scale2/SCAIFE-Welcome.html
	
    	- Select “DataHub” [SCAIFE-DataHub](SCAIFE-DataHub.md) from this SCAIFE-focused index

- In [SCAIFE-DataHub](SCAIFE-DataHub.md), run through steps of the sections ["Creating a Test Project"](./SCAIFE-DataHub.md#creating-a-test-project) and [Adding Audit Data AKA Adjudications True and False](./SCAIFE-DataHub.md#adding-audit-data-aka-adjudications-true-and-false). For the latter, make sure to do steps 10 and 11, which require you to open another hyperlinked tab [SCAIFE-Statistics](SCAIFE-Statistics.md) and then create and run a classifier.


## After completing the SCAIFE quick-start demo:

- Read through the [SCAIFE-Statistics](SCAIFE-Statistics.md) manual page's section "Classifier Metrics" at [SCAIFE-Statistics](SCAIFE-Statistics.md).

- You may want to run the SCAIFE CI demo test next. Refer to [SCAIFE-CI](SCAIFE-CI.md).

Please develop and test using containers. For example, on the [SCAIFE-Statistics](SCAIFE-Statistics.md) in Section "Performance Measurements" there are different instructions on  whether you use containers or not. Use the instructions for containers, under the heading "Performance Measurements".
