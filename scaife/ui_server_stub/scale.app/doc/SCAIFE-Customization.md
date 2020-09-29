---
title: 'SCAIFE : Customization'
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

The SCAIFE manual (documentation) copyright covers all pages of the SCAIFE/SCALe manual with filenames that start with text 'SCAIFE' and that copyright is [here](SCAIFE-MANUAL-copyright.md).

The non-SCALe part of the SCAIFE _system_ has limited distribution that is different than the SCALe distribution. [Click here to see the SCAIFE system copyright.](SCAIFE-SYSTEM-copyright.md)

The SCAIFE API definition has its own distribution that is different than the SCAIFE system, SCAIFE manual, and SCALe distribution. The SCAIFE _API_ definition copyright is [here](SCAIFE-API-copyright.md)

Customizing SCAIFE
==================

Network Configuration
---------------------

Each Swagger server has an associated Mongo server to store its back-end
data.

All servers currently access each other through a Docker network, using
the following hosts and ports:

| Server       | Host         | Port | Mongo Host           | Mongo Port |
|--------------+--------------+------+----------------------+------------|
| SCALe        | scale        | 8083 |                      |            |
| datahub      | datahub      | 8084 | mongodb_datahub      |      28084 |
| priority     | priority     | 8085 | mongodb_priority     |      28085 |
| stats        | stats        | 8086 | mongodb_stats        |      28086 |
| registration | registration | 8087 | mongodb_registration |      28087 |

The following file is used to indicate configuration info for running SCAIFE:

 * `scaife/ui_server_stub/scale.app/config/scaife_servers.yml`
 The file contains test & development information for how SCALe can connect to the SCAIFE servers. If you change the setup, you will need to change these lines to reflect their new network locations:

```ruby
    datahub: 'datahub:8084'
    priority: 'priority:8085'
    stats: 'stats:8086'
    registration: 'registration:8087'
```

 * `<module_server_stub>/swagger_server/servers.conf`

These are the configuration files for the swagger servers when running
SCAIFE. The DEFAULT section will be used by the server running the application.
All additional external servers are specified using an alias
prefixed by the following options:

| STATS | Stats |
| DH | Datahub |
| PRI | Prioritization |
| UI ] User Interface (including SCALe) |

The 'db_host' and '<server prefix>_DATABASE' sections provide connection
information to the MongoDB server. You can change the host, and port to
connect to MongoDB under these sections.  If the connection requires
login credentials, username and password may also be specified.

The Stats server tox integration tests rely on a running DataHub
instance. Therefore the Stats server's database section
also specifies the host and port of the DataHub module's MongoDB
server, under the DH_DATABASE section.

Containers
----------

If you run SCAIFE without using Docker containers, you can ignore the following files:

 *  Dockerfile

Instructs each container to expose its port.

If you run SCAIFE without using docker-compose, you can ignore the following files:

 *  docker-compose.yml

Provides names for each host and which ports to expose.  Note that docker commands that don't involve docker-compose don't use this file. It is only used by docker-compose.

 * docker-compose.override.yml

 This file currently has no host/port information. If you add host/port information here, then it will override the information in docker-compose.yml


API Modifications
-----------------

The API definitions are available in the following files (Note that on the SCAIFE VM, `scaife` is at `/home/vagrant/Desktop/scaife`.):

```sh
scaife/*_server_stub/swagger_server/swagger/swagger.yaml
scaife/*_server_stub/swagger_server/swagger/swagger.json
scaife/*_server_stub/swagger_server/templates/index.html
```

It is possible to edit the `swagger.yaml` file using a standard browser like Emacs or Vim, but the best tool for editing the API is to use `Swagger-Editor`. You can install run the image from DockerHub as follows:
Run the following commands:
```
docker pull swaggerapi/swagger-editor
docker run -it --rm -p 80:8080 swaggerapi/swagger-editor
```

This will run a disposable Swagger Editor (in detached mode) on port 80 on your machine, so you can open it by navigating to http://localhost in your browser.  You can then look at a `.yaml` or `.json` file on your host by selecting `File->Import File` in the web interface. Or you can share a folder containing your file to the server and tell the server to start with this file. For example, to view the Datahub's `yaml` file, you could use this command:
```
docker run -it --rm -p 80:8080  -v ${PWD}:/scaife  -e SWAGGER_FILE=/scaife/datahub_server_stub/swagger_server/swagger/swagger.yaml   swaggerapi/swagger-editor
```
* See https://github.com/swagger-api/swagger-editor for more detail

If you wish to change the API, you should edit the YAML files, and then use the following scripts to regenerate the JSON and HTML files, and update the YAML files:

```sh
python3 ../helpers/api_json_and_html_generator.py swagger_server/swagger ${HOME}/swagger-codegen -v <THREE-INTEGER-API-VERSION-WITH-DOT-SEPARATORS> -li ../ABOUT
python3 ../helpers/api_html_formatter.py swagger_server/swagger/swagger.yaml swagger_server/templates/index.html
```

The <THREE-INTEGER-API-VERSION-WITH-DOT-SEPARATORS> is the current version of SCAIFE, and is available in the scaife/ABOUT file.

These scripts depend on [swagger-codegen](https://github.com/swagger-api/swagger-codegen). If you are using the SCAIFE VM, this is already installed. Otherwise you will have to install it yourself. It depends on Maven and Java, and is built using these commands:

```sh
mvn clean package
java -jar modules/swagger-codegen-cli/target/swagger-codegen-cli.jar help generate
```

In that case, you will also have to replace ${HOME} in the previous command with the actual installation location of swagger-codegen.

Copyright Information
===================

This is a listing of copyright files that must be manually updated should the legal information change. All pathnames originate from the scaife directory:

 * scaife/ABOUT
 * scaife/ui_server_stub/scale.app/ABOUT

Contains copyright information that goes into every source file

 * scaife.copyright.html
 * ui_server_stub/scale.app/doc/SCAIFE-SYSTEM-copyright.md

SCAIFE System copyright

 * scaife.api_doc_copyright.html
 * ui_server_stub/scale.app/doc/SCAIFE-API-copyright.md

SCAIFE API copyright

 * ui_server_stub/scale.app/doc/SCAIFE-MANUAL-copyright.md

SCAIFE manual (documentation) copyright

 * ui_server_stub/scale.app/COPYRIGHT
 * ui_server_stub/scale.app/doc/SCALe-copyright.md

SCALe copyright

 * *_server_stub/swagger_server/template/index.html

2-line copyright info embedded in API web pages

Updating Copyrights
-------------------

If you need to change the legal information, you should change it in the files listed above. You should also run the scripts to regenerate the HTML, JSON, and YAML files listed in the "API Modifications" section.  You should also run the following command:

```sh
cd ~/Desktop/scaife
./ui_server_stub/scale.app/package.py -c
```

Note that this script requires Python 2 (whereas most SCAIFE scripts use Python 3).

This command scans all source files for a <legal> and </legal> tags. It replaces whatever is between them with a suitable copyright message.

All source files should have copyright messages, encased in <legal></legal> tags. You can also use this script to find any source  files that lack these tags, and would not get suitable copyright messages, using this command:

```sh
./ui_server_stub/scale.app/package.py -c -w
```

Finally, if you make any changes to this manual, including copyright messages, you should run this command to regenerate the SCAIFE manual HTML pages:

```sh
cd ~/Desktop/scaife/ui_server_stub/scale.app
./scripts/builddocs.sh
```

------------------------------------------------------------------------
