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
<!-- <legal></legal> -->

# Information About the SCAIFE-SCALe Public Release (includes SCALe)

This release is for public distribution. In creating the release,
parts of SCAIFE were removed since the entire system is not publicly
releasable at this time. SCALe was developed as a separable module for
the SCAIFE system instantiation and used as the UI module within the
system. This release does not have the full set of five SCAIFE API
(.yaml) files described below, however the SCAIFE API .yaml files are
published on GitHub at https://github.com/cmu-sei/SCAIFE-API. Use
these files when instructions say to view the API in
swagger-editor. The tech manual with some additional instructions
beyond the SCAIFE/SCALe HTML manual (mentioned below) can be helpful
with getting started in SCALe. More specifically, the 'Partial Access'
method found here:
`https://resources.sei.cmu.edu/asset_files/UsersGuide/2020_012_001_644362.docx`
describes how to start SCALe as a UI module in SCAIFE when the other
servers are not available.

# SCAIFE/SCALe HTML manual

Much use, system design, and development information is provided in
the included SCAIFE/SCALe HTML manual. To view it, in your web browser
open this file location (first starting at SCAIFE home page, second
starting at SCALe home page):

* `scaife/ui_server_stub/scale.app/public/doc/scale2/SCAIFE-Welcome.html`
* `scaife/ui_server_stub/scale.app/public/doc/scale2/Welcome.html`


# SCAIFE APIs

This repository contains Swagger and non-Swagger files supporting the
SCAIFE API, instantiation of the API, and further development of the
API and instantiations of it. Additional instructions on instantiating
the APIs can be found here:
https://resources.sei.cmu.edu/library/asset-view.cfm?assetid=644354.

The directory 'scaife/helpers' contains helper scripts useful to
developers and testers during code development.

The file 'scaife/ABOUT' provides product and version information for a
particular SCAIFE system release. This is a release of code and a
system that instantiates the SCAIFE UI module's API. The SCAIFE system
version is not necessarily the same as the API for a particular SCAIFE
module. Each of the four non-SCALe SCAIFE modules has an API version
that is specified in its swagger/swagger.yaml file in a line
specifying 'version', as in the following line: version: '1.2.2'

The API definitions are available in the following 15 files (5
different `*_server_sub` directories) in the full SCAIFE system:

```
scaife/*_server_stub/swagger_server/swagger/swagger.yaml
scaife/*_server_stub/swagger_server/swagger/swagger.json
scaife/*_server_stub/swagger_server/templates/index.html
```

# Additional Info

## SCAIFE Presentation

More details about SCAIFE have been presented to the DoD National
Nuclear Security Administration (NNSA) Software Assurance Community of
Practice (SwA CoP). The presentation slides are location at:
https://resources.sei.cmu.edu/library/asset-view.cfm?assetid=645790. A
lot of content about SCAIFE, SCALe and other related topics are
available here:
https://resources.sei.cmu.edu/library/author.cfm?authorid=31216.



# SCAIFE/SCALe HTML manual

Much use, system design, and development information is provided in the included SCAIFE/SCALe HTML manual. To view it, in your web browser open this file location (first starting at SCAIFE home page, second starting at SCALe home page):

* `scaife/ui_server_stub/scale.app/public/doc/scale2/SCAIFE-Welcome.html`
* `scaife/ui_server_stub/scale.app/public/doc/scale2/Welcome.html`


# SCAIFE APIs

This repository contains Swagger and non-Swagger files supporting the SCAIFE API, instantiation of the API, and further development of the API and instantiations of it. Additional instructions on instantiating the APIs can be found here: https://resources.sei.cmu.edu/library/asset-view.cfm?assetid=644354.

We recently switched to use OpenAPI version 3 format (previously we used Swagger version 2 format) for the API definitions.


The directory "scaife/helpers" contains helper scripts useful to developers and testers during code development.

The file "scaife/ABOUT" provides product and version information for a particular SCAIFE system release. This is a release of code and a system that instantiates the SCAIFE API, e.g., a virtual machine for SCAIFE v 1.4.4. The SCAIFE system version is not necessarily the same as the API for a particular SCAIFE module. Each of the four non-SCALe SCAIFE modules has an API version that is specified in its swagger/swagger.yaml file in a line specifying "version", as in the following line:
version: "1.2.1"

The API definitions are available in the following 15 files (5 different `*_server_sub` directories):

```
scaife/*_server_stub/swagger_server/swagger/swagger.yaml
scaife/*_server_stub/swagger_server/swagger/swagger.json
scaife/*_server_stub/swagger_server/templates/index.html
```

# Additional Info
More details about SCAIFE have been presented to the DoD National Nuclear Security Administration (NNSA) Software Assurance Community of Practice (SwA CoP). The presentation slides are location at: https://resources.sei.cmu.edu/library/asset-view.cfm?assetid=645790. The SCAIFE project Principal Investigator, Lori Flynn, has published a lot of content about SCAIFE, SCALe and other related topics, here: https://resources.sei.cmu.edu/library/author.cfm?authorid=31216.


## Installation Instructions (Code for Intended External Container User, plus manual, copyrights, API files)
SCAIFE can be installed as containers on Linux and Mac machines. So far, we have only tested installs on Linux and Mac machines,
so we don't know if Windows container installs would work.

You need a Linux or Mac machine (or VM) that has:
* around 10 GB extra space (2.5 GB for the expanded files, 6.5GB virtual space for the containers but prior to any activity they use less than 1GB on our test machine, per ```docker ps --size```)
* a connection to the internet, during the time that the docker containers are built with the docker-compose installation command below
* docker installed, from the Docker website https://www.docker.com/resources/what-container (Docker Community Edition, Docker version 19.03.8, build afacb8b7f0 is a tested and working version installed on an Ubuntu version 20.0 LTS (Note that it’s best to download the latest stable version for your machine directly from Docker’s own website, not to use the default installed docker version on the Linux operating system.)
* curl installed (e.g., for machines that can install using apt, ```sudo apt-get install curl``` would install curl). curl is used in command lines or scripts to transfer data. For more information about curl, see https://curl.haxx.se/  )
* docker-compose installed. For instance, on a Linux machine with Curl installed, the following command can be used:
```
curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

### Steps to install (works for full SCAIFE system or GitHub-style SCALe release)

1. Unzip and decrypt the file using the decryption passphrase provided by SEI.
2. Untar the tarball (e.g., with command ```tar -xvf```)
3. Start up the docker containers for SCAIFE by:
**	changing directories to the ```scaife``` directory (base directory of the untarred download)
**	If you have the full SCAIFE system release (not only the GitHub style SCALe code): In the ```scaife``` directory, run the following command to start *all* the SCAIFE containers:
```
docker-compose -f docker-compose.yml up --build
```
**	If starting only SCALe (e.g., with a GitHub style SCALe release), then from the ```scaife``` directory, run the following command to start only the SCALe container:
```
docker-compose -f docker-compose.yml up --build scale
```

### More Information for GitHub-style SCALe releases


#### Information about SCAIFE-SCALe GitHub-style releases

This release is for public distribution. In creating the release, parts of SCAIFE were removed since the entire system is not publicly releasable at this time. SCALe was developed as a separable module for the SCAIFE system instantiation and used as the UI module within the system. This release does not have the full set of five SCAIFE API (.yaml) files described below, however the SCAIFE API .yaml files are published on GitHub at https://github.com/cmu-sei/SCAIFE-API. Use these files when instructions say to view the API in swagger-editor. The tech manual with some additional instructions beyond the SCAIFE/SCALe HTML manual (mentioned below) can be helpful with getting started in SCALe. More specifically, the "Partial Access" method found here: `https://resources.sei.cmu.edu/asset_files/UsersGuide/2020_012_001_644362.docx` describes how to start SCALe as a UI module in SCAIFE when the other servers are not available. Note: The HTML manual, the technical manual, and other documents we previously published may have references to the `model_api` directory, that recently changed to the `scaife` directory and should be interchanged where appropriate.


#### Stop the SCALe Container

1. Run the following command:
```
docker-compose stop scale
```

#### Test the SCALe Container

1. SCALe has several test scripts in its scale.app/bin directory. To run the Python tests, use this command:
Command to run a test in a SCALe container docker-compose run scale ./bin/test-python


#### Open a Terminal in the Container

1. To start a bash shell to examine an independent SCALe container, run:
```
docker-compose exec scale /bin/bash
```
Accessing the bash shell, allows the user to perform actions in the container like viewing the contents of the SQLite DB. Below is an example command to run inside the shell to view all tables within the development database. ">" represents the terminal pointer and is not a part of the command.

```
> sqlite db/development.sqlite3 # Open the SQLite DB
> .tables # List all the tables
``` 


## Installation Instructions for VM Releases

If the SCALe web app is provided via a virtual machine (VM), then the SCALe app will be configured to run automatically when the machine boots, except for VMs with Docker containers. Instructions for starting the Docker containers on those types of VMs are provided in the HTML manual at scale.app/public/doc/scale2/SCAIFE-Server-Management.html (markdown version at scale.app/doc/SCAIFE-Server-Management.md ).

Less relevant but possibly useful: Some information (but not all) that is SCALe-specific about installing SCALe (e.g., changing the user login name and password) that may be useful is located here: scale.app/public/doc/scale2/Installing-SCALe.html (markdown version at scale.app/doc/SCAIFE-Server-Management.md ).

### SCAIFE System version 1.0.0 (a Previous Version) Release VM with Containers

The SCAIFE System version 1.0.0 Release VM includes Docker containers. Installers will find the following information useful:
The release VM is distributed in an approximately 10 GB OVA file.
Once imported (e.g., as a VMWare VM), the VM is approximately 20 GB. The VM itself is set to expand dynamically up to 200 GB disk size, so installers should be careful to make sure that their host machine has sufficient space. (Please keep in mind that the host machine must also have spare disk space for itself, separate from the VM.)
The VM is set to 24 GB RAM memory, and users should increase that if their host machine has sufficient memory. (However, keep in mind that the host machine must also have memory for itself separate from the VM.)

## Swagger_server Details for SCAIFE
CORS support is included in main.py to help with testing in the browser using local instances of the server and UI.
-- Install CORS prior to running the server:
```
sudo -E pip install flask-cors
```
The default ports have been changed so that instances of SCALe will not collide with running these servers.
DataHub Module - localhost:8084
Prioritization Module - localhost:8085
Statistics Module - localhost:8086
Registration Module - localhost:8087

Server configuration information is provided in the ```scaife/*/Dockerfile```(s) and in the ```scaife/ui_server_stub/scale.app/config/scaife_servers.yml``` file

--Templates folder contains any HTML files or templates needed to render content by the controller. It contains the HTML code generated by codegen to provide instructions on how the API works (```<server_name>_api.html```).

--Static folder contains static content, like CSS or JS files to display the templates.

--Upload_Files folder stores files sent to the server that will not be stored in the database, but need to be accessible in the server.

--Test/Test_Input folder contains open-source output (output from running an open-source tool on an open-source codebase) that can be used in testing the functionality of SCAIFE.

## CI Integration

SCAIFE supports integration with Continuous Integration (CI) servers via interaction with the DataHub Module API and can be configured to directly connect with a git-based Version Control System (VCS).  This allows for source code to be easily updated and analyzed without the need to upload the source code using the CI API endpoint.  See the DataHub Module API definition for API usage or read the SCAIFE/SCALe HTML manual ``scaife/ui_server_stub/scale.app/public/doc/scale2/SCAIFE-CI.html` (markdown version [here](ui_server_stub/scale.app/doc/SCAIFE-CI.md), for complete CI details.

## Notes:

``Rapidclass_scripts`` Integration:
The directories ``datahub_server_stub`` and ``stats_server_stub`` include functionality from the repository "rapidclass_scripts". Both modules include ``rapidclass_scripts`` as submodules. To include ``rapidclass_scripts`` in the repository perform the following commands:

```
git submodule init

cd scaife/datahub_server_stub/rapidclass_scripts
git submodule update --init

cd scaife/stats_server_stub/rapidclass_scripts
git submodule update --init
```

``rapidclass_scripts`` is an instance of the ``rapidclass_scripts`` repository and these branches are associated with the server stubs:

   ``scaife`` branches --> ``dev-branch`` for all swagger modules
   ``rapidclass_scripts`` --> ``stats_dev``  for the Stats module
   ``rapidclass_scripts`` --> ``dh_dev``  for the DataHub module


Similarly, the SCALe tool (SCAIFE-compatible version) is included as a separable module within the SCAIFE system. The ``scale.app`` repository is included as a submodule. Similarly:

```
cd scaife/ui_server_stub/scale.app
git submodule update --init
```





## Relevant Known Issues

1. Not all of the SCAIFE-connected functionality is integrated. Although this version enables specification of adaptive heuristic type, the adaptive heuristic dataflows are partially and not fully implemented in this SCAIFE release. The current version does not yet download projects and packages from the SCAIFE DataHub to SCALe (however, the current version does upload them from SCALe to the SCAIFE DataHub).

1. The SCALe/SCAIFE HTML manual has many out-of-date screenshots and some out-of-date instructions. Current collaborators receive special instructions directing them to the relevant HTML pages for use and testing, which we believe have sufficient updates (or are completely up-to-date). In future releases, the HTML manual will be further updated. In the future we hope to automate updating screenshots in the manual as part of the auto-deployment process.

1. The user-uploaded fields can be used in prioritization formulas, but cannot be viewed in the SCALe GUI. 

1. During the SCALe quick start demonstration, the following superfluous error is generated in the web app console: `.../scale.app/archive/backup/6/analysis/...out: no such file or directory.

1. The `digest_alerts.py` script in SCALe does not follow symlinks in source directories.

1. In SCALe, some of the links in the exported secure coding rule documentation point to online pages, and will fail on a machine with no Internet connection.

1. SCALe language, taxonomy, and tool mappings to SCAIFE languages, taxonomies, and tools cannot currently be deleted since mappings are shared across all projects. The database must be re-initialized for this currently.

1. SCALe language, taxonomy, and tool IDs are assigned during database initialization based on the order they appear in scripts/taxonomies.json, scripts/languages.json, and scripts/tool.json. If new taxonomies, languages, tools, or versions thereof are added, it will potentially skew these ID assignments which might affect project imports.

1. Currently only one user-uploaded data file can be used in SCALe, to add new fields (beyond the default fields) and per-meta-alert values that can be used in prioritization schemes. In the future, handling multiple files (for a single project and for multiple projects) will be enabled.

1. Handling of the Juliet Java and STONESOUP test suite data needs some updates for SCALe and the full SCAIFE system to be able to use all the data. (Previous versions of SCAIFE rapidlcass_scripts code has been able to do that, so the updates needed are not extensive and will be included in a near-future release.)

1. Test suite projects are not currently editable within SCALe.

1. Different Fortify versions should use different checker sets in SCALe, but currently they don't.

1. "SPECIAL" checkers in SCALe currently may not be always handled correctly.

1. Some SCALe GUI features may not work on browsers other than Firefox (e.g., Chrome or Microsoft Edge).

1. No field for the checker mappings CSV currently exist in SCALe, though that is required for one of the API calls involving the  SCAIFE UI Module.

1. SCALe (but not the rest of SCAIFE) currently uses Python version 2, but Python version 2 is not officially supported anymore. We have modified most of the SCALe Python code so it works with both Python 3 and Python 2. In the future, SCALe updates to Python 3 need to be completed. 

1. The fix_path.py code in SCALe should be revised to run more efficiently.

1. The SCAIFE authentication system will be refactored in the future, to enhance SCAIFE modularity.

1. Scalability, performance (latency, memory use, disk use, processing) improvements, security hardening, and business continuity improvements would be needed to transition the SCAIFE system from research system to widely-usable tool.

1. There is a bug we have detected (yet to be fixed) that occasionally causes a silent SCAIFE failure when meta-alert/alert filepaths don't match filepaths in the source code archive

1. insert_classifiers.py shouldn't add all AHs and AHPOs to every classifier

1. When the SCAIFE containers are started in test mode, this SCALe script fails when run
```
python scaife/ui_server_stub/scale.app/scripts/automation/create_manual_test_project.1.rosecheckers.py
```
Note this failure does not occur when the SCAIFE containers are started in normal mode.

1. In SCALe, manually-created alertConditions are not fully functional (e.g., they do not export into an exported SCALe database). For current work with this research project, we are not using manually-created alertConditions, so this is a low priority bugfix.

1. Confidence values do not get updated when a classifier based on one project is run on another project.

1. Once loaded to the SCAIFE DataHub, some of the subsequent modifications on a project are not recognized when trying to run a classifier using that project. (We are working to implement full data updates flowing through the SCAIFE system.)

1. Currently, if multiple combinations of a `tool_name + tool_version` (e.g., `cppcheck 1.00`, `1.66`, `1.83`, etc.) exist in SCAIFE, an error occurs if only one `tool_name + tool_version` is added to a Package.  To create a Package in SCAIFE, every combination of that `tool_name + tool_version` must be added to the Package if multiple versions of that tool were uploaded to SCAIFE. Requiring all those combinations in a Package is a bug we plan to fix.

1. The Selenium sanitizer test currently fails. It needs updates in the reference database, since we've integrated new static analysis tools to work with SCALe.

