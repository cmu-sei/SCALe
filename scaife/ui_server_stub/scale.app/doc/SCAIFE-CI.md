---
title: 'SCAIFE : CI'
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

The SCAIFE manual (documentation) copyright covers all pages of the SCAIFE/SCALe manual with filenames that start with text 'SCAIFE' and that copyright is [here](SCAIFE-MANUAL-copyright.md).

The non-SCALe part of the SCAIFE _system_ has limited distribution that is different than the SCALe distribution. [Click here to see the SCAIFE system copyright.](SCAIFE-SYSTEM-copyright.md)

The SCAIFE API definition has its own distribution that is different than the SCAIFE system, SCAIFE manual, and SCALe distribution. The SCAIFE _API_ definition copyright is [here](SCAIFE-API-copyright.md)

Continuous Integration
=============

-   [Overview](#overview)
-   [Configuring a package for CI](#configuring-a-package-for-ci)
-   [Using the DataHub Module CI API](#using-the-datahub-ci-api)
-   [Proxy Configuration](#proxy-configuration)

Overview
--------

The DataHub Module API provides a CI endpoint that automates analysis using SCAIFE if a package is configured to utilize CI integration.  Configuring a package for CI integration means that the DataHub Module will directly connect to a git-based Version Control System (VCS) to analyze the source code used in the SCAIFE application.  After running static analysis on the source code the results are sent to the DataHub API to begin automated processing with SCAIFE.

Configuring a Package for CI
--------

To configure a package to be used in a CI workflow a package must be configured with the following additional information.

1. The username of the git user that can access the VCS repository.
2. The git access token for the specified user.
3. The url of the source code repository containing.

When a package is configured as a CI package, the source code repository will be initially cloned by the DataHub Module for future analysis by the SCAIFE system when integrating with a CI server.

Using the DataHub Module CI API
--------

To use SCAIFE with a CI build system, the following data must be provided as a POST request to the DataHub CI endpoint:

1. x_access_token - Token that contains information about the user.
2. package_id - The id of the SCAIFE package.
3. tool_id - The id of the SCAIFE tool matching the static analysis results.
4. git_commit_hash - The current git commit hash that is triggering the CI build.
5. tool_output - The results of the static analysis performed in a previous CI build step.

Proxy Configuration
--------

When using a proxy the DataHub Module must be explicity configured with the proxy connection information in order to access a git-based repository for cloning and updating.  To configure a proxy, edit the servers.conf file located at
`scaife/datahub_server_stub/swagger_server/servers.conf` by uncommenting the proxy setting and modifying the url to match your specific proxy connection information. 
