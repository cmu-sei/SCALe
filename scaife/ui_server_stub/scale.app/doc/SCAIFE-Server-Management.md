---
title: 'SCAIFE : Server Management (SCAIFE)'
---

[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Source Code Analysis Integrated Framework Environment (SCAIFE)](SCAIFE-Welcome.md)
<!-- <legal> -->
<!-- SCAIFE System version 1.2.2 -->
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
<!-- [DISTRIBUTION STATEMENT F] Further dissemination only as directed by -->
<!-- OSD/ASD R&E (determination date: 2019-12-11) or higher DoD authority. -->
<!--  -->
<!-- Notice to DoD Subcontractors: This document may contain Covered -->
<!-- Defense Information (CDI).  Handling of this information is subject to -->
<!-- the controls identified in DFARS 252.204-7012 – SAFEGUARDING COVERED -->
<!-- DEFENSE INFORMATION AND CYBER INCIDENT REPORTING -->
<!--  -->
<!-- This Software includes and/or makes use of Third-Party Software -->
<!-- subject to its own license. -->
<!--  -->
<!-- This material includes field names used in the Software Assurance -->
<!-- Marketplace (SWAMP), a service that provides continuous software -->
<!-- assurance capabilities to developers and researchers at -->
<!-- https://www.mir-swamp.org/#.  Copyright © 2012-2020 The Morgridge -->
<!-- Institute for Research, Inc. All rights reserved.” -->
<!--  -->
<!-- This material includes field names used in the Software Assurance Tool -->
<!-- (SwAT), a tool that is used by analysts to analyze static analysis -->
<!-- alerts from multiple static analysis -->
<!-- tools. https://www.cerdec.army.mil/ Combat Capabilities Development -->
<!-- Command (CCDC) C5ISR Center. All rights reserved. -->
<!--  -->
<!-- DM19-1273 -->
<!-- </legal> -->

Make a Backup
-------------

You should create a backup of SCAIFE, using these commands:

```sh
cd ~/Desktop
zip -r scaife_backup scaife
```

This will be useful if you ever need to reset SCAIFE.


Managing the SCAIFE servers
-----------------

SCAIFE consists of a handful of servers.

## For SCAIFE distributed as code that the user brings up as independent containers

An 'independent' container is a container that mounts no volumes. That is, it shares no files with the host, and any files it creates or modifies disappear when the container is removed.

You need a Linux machine (or VM) that has:

1. around 10 GB extra space (2.5 GB for the expanded files, 6.5GB virtual space for the containers but prior to any activity they use less than 1GB on our test machine, per docker ps --size)
2. docker installed, from the Docker website https://www.docker.com/resources/what-container (Docker Community Edition, Docker version 19.03.8, build afacb8b7f0 is a tested and working version installed on an Ubuntu version 20.0 LTS (Note that it’s best to download the latest stable version for your machine directly from Docker’s own website, not to use the default installed docker version on the Linux operating system.


In the `scaife` directory, run the following command to start the SCAIFE containers:
```
docker-compose -f docker-compose.yml up --build
```
* **WARNING 1: The above command MUST include the "-f docker-compose.yml" part, even though that is an unusual requirement.** This is because the file 'scaife/docker-compose.yml' is used by our 'docker-compose' setup in an usual way.
* **WARNING 2: The above command will not work if you are using dependent containers.**


Note that by default, docker-compose scans both the `docker-compose.yml` and `docker-compose.override.yml` files. The `-f` has the unconventional effect of forcing docker-compose to ignore the `docker-compose-override.yml` file. See  https://docs.docker.com/compose/reference/overview for more information.

## For SCAIFE distributed as code that the user brings up as dependent container

A 'dependent' container is a container that shares one or more volumes with its host. This is useful for letting a container produce data that can outlive the container.

Note that when a dependent container runs on a Linux host and shares volumes with the host, any files created within the container will typically have the ownership and permissions mask of the container's user (which is usually root).For example, if a container runs a Python program from a shared volume, such as `scale.app/package.py`, the Python compiler might create a file like `scale.app/package.pyc` and place it on the shared volume, and owned by root. These files can be removed on the host only by the root user. But they can also be removed in the container by running the toplevel `./clean.sh` script. See https://medium.com/@nielssj/docker-volumes-and-file-system-permissions-772c1aee23ca for more background on containers and file permissions.

You need the same machine requirements as specified above for independent containers.

To start up dependent containers, in the `scaife` directory, run the following commands:
```
docker-compose build
for SERVER in registration priority datahub stats scale; do
    docker-compose run ${SERVER} ./init.sh
docker-compose up
```
These commands will work for independent containers as well, but you can omit the middle two lines, running just the first and last lines to bring up independent containers.


## For SCAIFE distributed on a VM

One common mechanism for distributing SCAIFE is as a Vagrant-built VM that hosts each server as a Docker container. Once the VM has been booted up, these commands can be used to control all of the SCAIFE servers:

```sh
cd ~/Desktop/scaife

# To run SCAIFE:
docker-compose up

# To pause SCAIFE:
docker-compose stop

# To resume SCAIFE:
docker-compose start

# To stop SCAIFE:
docker-compose down
```

The "docker-compose down" command will remove the Mongo containers, eliminating their data. Do not use this command if you wish to retain the Mongo data.
Use the command "docker-compose stop" instead, to retain data.

## Additional Server Management

Cleaning up SCAIFE
------------------

If you wish to clean up the SCAIFE data, without cleaning up any code modifications you might have done, you can use this procedure.

```sh
cd ~/Desktop/scaife
# First take down servers
docker-compose down

# Remove data left over by containers
./clean.sh

# Re-initialize scale container:
docker-compose run scale ./init.sh

# Restore containers
docker-compose up
```

If you are not using Docker containers, replace the docker commands with appropriate commands to start or stop the servers.

To Restore from Backup
-------------

To restore SCAIFE from backup:

```sh
cd ~/Desktop
rm -rf scaife
unzip scaife_backup.zip
cd scaife
```

Testing SCALe's Web Interface
---------------

SCALe comes with a series of tests for testing its Web interface. These tests are written in Java and use Selenium to interact wwith a specific version of Firefox, along with Maven to control the testing. These tests can be run headless inside SCALe's container.

Unfortunately, Maven does not respect environment variables that indicate if the machine is behind a proxy. If you run these tests on a host that is behind a proxy, you must specify Maven's proxy settings using the file `~/.m2/settings.xml`. For details about teaching Maven about your proxy, see https://maven.apache.org/guides/mini/guide-proxies.html.  (You will also need to adjust your proxy settings for the `Vagrantfile`.)

In order to run SCALe's selenium tests inside a container, this file must also exist in the container's filesystem. Therefore, docker-compose mounts your hosts `~/.m2` folder into its own filesystem.  This means that if your host can access the internet, SCALe container can too.

------------------------------------------------------------------------
