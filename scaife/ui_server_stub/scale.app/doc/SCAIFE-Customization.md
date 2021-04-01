---
title: 'SCAIFE : Customization'
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


Auto-Generated SCAIFE Server and Client Code from API Definition
-----------------

Using the `swagger-codegen` tool, you can automatically generate client and server code from the API definition files. The server code includes stubs, and you will need to fill in code within the function itself. The client code provides function calls you can make in appropriate places in your code, and you will need to initialize variables, assign to them, or provide data for any function parameters.

Next: information about how to auto-generate SCAIFE client code from the SCAIFE API definition files, then mark it.

First, install  `swagger-codegen`. Then, switch to the directory where it's installed and auto-generate client code in your language of choice for one (of the five) swagger APIs , e.g. for Java code for the DataHub (some filepaths below are specific to a machine, so substitute your own filepaths, for example where you see `/home/lflynn/scale/epp/` below you should substitute your own filepath):

```
cd ~/opt/swagger/swagger-codegen

java -jar modules/swagger-codegen-cli/target/swagger-codegen-cli.jar generate -i  /home/lflynn/scale/epp/scaife/datahub_server_stub/swagger_server/swagger/swagger.yaml -l java -o /home/lflynn/temp/swagger-api-client/swagger-java-datahub-client
```

After auto-generating the code for as many of the five modules as needed, add the SCAIFE API markings file (make sure the markings file is updated as described in another section of this page, to contain the correct text, version, and year) to the base directory (in the example above, that is `swagger-java-client`).

Then, make a tarball starting from the base directory. E.g.,

`tar -czvf swagger-api-java-client-code.tar.gz swagger-api-client`



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
