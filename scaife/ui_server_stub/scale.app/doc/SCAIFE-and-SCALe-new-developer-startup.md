---
title: 'SCAIFE and SCALe : New Developer Startup'
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

SCAIFE and SCALe : New Developer Startup
==================

[This blogpost](https://insights.sei.cmu.edu/blog/release-scaife-system-version-100-provides-full-gui-based-static-analysis-adjudication-system-meta-alert-classification/) gives a high-level overview about SCAIFE’s purpose and architecture. SCAIFE uses SCALe as one of its 5 modules. The modules communicate with each other via API calls behind the scenes.

The majority of SCAIFE and SCALe are developed in Python and Ruby/Rails. The UI contains JavaScript as well. These projects also utilize Mongo and SQLite as back-end databases.

SEI-only:

SCAIFE is composed of code developed in 3 code repositories:

- [SCALe Repository](https://bitbucket.cc.cert.org/bitbucket/projects/SCAL/repos/scale.app/browse)

  Without a CERT BitBucket account, you can still access the [scaife-scale](https://github.com/cmu-sei/SCALe/tree/scaife-scale) branch of `scale.app` on GitHub. It contains just slightly-old SCALe code, from last month.

- rapidclass_scripts: https://bitbucket.cc.cert.org/bitbucket/projects/SCAL/repos/rapidclass_scripts/browse

- scaife: https://bitbucket.cc.cert.org/bitbucket/projects/SCAL/repos/scaife/browse


## Running the system

1. In order to run SCALe locally (on a Linux VM) from a terminal install docker and docker-compose (`sudo apt install docker`; `sudo apt install docker-compose`). Then clone the GitHub repository, and switch to the scaife-scale branch (don’t use the default ‘main’ branch). Then, startup SCALe as follows, from the scaife directory:

`docker-compose -f docker-compose.yml up --build scale`

Next, in your VM’s web browser, go to the following file (substitute your own local path for the purple0font text): `file:///<YOUR_LOCAL_PATH>/scaife/ui_server_stub/scale.app/public/doc/scale2/Welcome.html`

Then, select “Quick Start Demo” from the index, and follow the instructions to create your first SCALe project. (For your first login, hit the "Sign Up" button, and provide suitable values for the fields.)

Please follow the documentation within [SCAIFE Docker Wisdom](SCAIFE-Docker-Wisdom.md) for more information on docker networking and containers.

2. While you can manually add and modify entries within the SCALe UI, a much faster (and error-free) way to build comprehensive projects for testing is to use the available scripts bundled within the SCALe server. These are accessible via:

   1. Docker exec into the running SCALe container - `docker exec -it scale sh`
   2. Now move into the automation directory - `cd scripts/automation`
   3. Run the appropriate script for your needs, for example - `./create_manual_test_project_1_dos2unix_rosecheckers.py`

3. Information on running entire suites or individual tests locally within each container is also available in [SCAIFE Docker Wisdom](SCAIFE-Docker-Wisdom.md)

4. [SCAIFE Docker Wisdom](SCAIFE-Docker-Wisdom.md) also has information on viewing log files (which are helpful for debugging) within a particular container.

## Developing the system (Hotfixes)

When doing development on a server, modifying any server's code requires the server's container to be taken down and re-built, as in:

```
    docker-compose up --build datahub
```

A 'hotfix' server is one that immediately applies any changes you make to its source code files, without requiring a restart.

For development purposes, you can configure the SCALe container & server to accept hotfixes.  To do this, edit the scaife/docker_compose.override.yml file:

```
    services:
      scale:
        volumes:
          - ${HOME}/.m2:/home/scale/.m2
    # comment out this line:
    #     - ./ui_server_stub/scale.app:/scale.app
    # and add the following lines:
          - ./ui_server_stub/scale.app/app:/scale.app/app
          - ./ui_server_stub/scale.app/test:/scale.app/test
          - ./ui_server_stub/scale.app/scripts:/scale.app/scripts
```

Unless you explicitly specify the docker-compose files to use, a `docker-compose` command will use this file (along with the `docker-compose.yml` file to launch SCALe, and so it will create a somewhat-shared container.

This means that the SCALe container shares the contents of the app, test, and scripts with the host. A SCALe container running a server will detect changes in these files and apply them into its running server. So you can edit Ruby or python code without having to rebuild the container or restart scale.

WARNING: Sharing the entire `scale.app` folder (the line that is commented out). This can cause considerable slowdowns.

## Setting up the system (On a Mac)
# Setting Up SCALe and SCAIFE locally

**Reminder of how to generate ssh keys (private and public)**: [SSH keys](https://support.atlassian.com/bitbucket-cloud/docs/set-up-an-ssh-key/). You may need to add your public SSH key to the [CERT Bitbucket](https://bitbucket.cc.cert.org/bitbucket/plugins/servlet/ssh/account/keys)

**Make sure your credentials are working for the Bitbucket Repos and Bamboo Builds.**

Follow the same general directions as the above section on running the system locally (on a Linux VM)

SEI developers only:
After running `git submodule update --init`, the scale.app repository clones successfully, and the rapidclass repository within the stats_server_stub directory clones correctly, but the rapidclass repository within the datahub_server_stub directory may be empty, with the exception of the .git file. You may need to `git checkout dh_dev` for this to work.

**Preferred method for installing Docker**: [Docker installation](https://docs.docker.com/docker-for-mac/install/). Here is documentation for docker: https://docs.docker.com


**Proxy Issue Solutions:** Sometimes proxy settings can get finicky. Regarding proxy issues,
	1. First proxy-fixing method: [Proxy Method 1](https://wiki-int.sei.cmu.edu/confluence/display/ITCollab/How+to+force+programs+to+use+the+SEI+proxy). See sections "Mac Notes" and "Mac without tampering with Homebrew (WIP)"

	2. Receive/download the shell file, sei_proxy.sh, and after downloading, you may have to do:
`source ~[path to sei_proxy.sh]`

	3. Within the Docker setup for Macs: manually set up proxies for Docker, via its preferences page. Open the Docker app, click on the settings cog, navigate to Resources, and then Proxies.
	- Use the Web Server (HTTP) Proxy as: http://cloudproxy.sei.cmu.edu:80
	- Use the Secure Web Server (HTTPS) as: http://cloudproxy.sei.cmu.edu:80
	- Use the Bypass proxy settings for these hosts & domains as: 127.0.0.1,localhost,.local,.cc.cert.org,.sei.cmu.edu

	4. After building the 11 containers and starting it up, you will have access to the SCALe web app and the SCAIFE/SCALe HTML manual via the web browser as before. Some users note that the web browser has the label file://localhost:8083, but you should change this to http://localhost:8083 in the browser (i.e. replace file with http).

**More Notes**

- Some users recommend/note a random thing about docker-compose: it really improves the output if you set the following environment variables:
`export COMPOSE_DOCKER_CLI_BUILD=1`
`export DOCKER_BUILDKIT=1`

- In response to the above docker-compose environments, other users note that Docker-compose changed the way they output during a build. The above env vars work great as long as you are using a terminal, but not so great if you are using something like Jupyter or Emacs. Setting the first env var to 0 gets you the old behavior.

## Running Demos for SCALe and SCAIFE

Startup the full (11 containers) SCAIFE system, in the scaife directory and run this command in a terminal: `docker-compose -f docker-compose.yml up --build`

You will know the build is complete when you see continuous scrolling of log data that the containers are producing. This will appear as vertical column lines, various log messages, and scale text in color. The servers that are communicating are in colored text. This indicates that SCAIFE is finish building and now running.

Once it’s started up, you will have access to the SCALe web app and the SCAIFE/SCALe HTML manual via the web browser as before.
In your browser, please open these tabs (usually you will want at least 2 open: the web app in one tab and one SCAIFE/SCALe manual page in another tab):
•	http://localhost:8083 - the SCALe web app (SCALe GUI interface)
•	http://127.0.0.1:8083/doc/scale2/Welcome.html - SCALe/SCAIFE manual index focused on SCALe

Alternatively, if you don’t have the scale container running, you can create HTML pages from markdown and then view all the SCALe/SCAIFE manual pages after running the following command, from the scale.app directory: `./scripts/builddocs.sh`
Then, in your browser, load a URL with your local filepath  `file://<YOUR_MACHINE_FILEPATH_TO_SCAIFE>/scaife/ui_server_stub/scale.app/doc/scale2/Welcome.html`
•	http://127.0.0.1:8083/doc/scale2/SCAIFE-Welcome.html - SCALe/SCAIFE manual index focused on SCAIFE
•	http://127.0.0.1:8083/doc/scale2/SCAIFE-Docker-Wisdom.html - a bunch of info on SCAIFE containers and running automated tests with the containers. It has a lot of useful info and commands, for working with SCAIFE containers. It needs to be organized with an index and broken into a bunch of short separate pages, but for now it’s worth skimming to see the type of content, then searching control-F for key words when you need info (e.g., “selenium” for how to run a single or all Selenium tests on a container locally, or “mongo” for how to get a mongo command line for one of the containers with a mongo database)

Run the demos, to get a quick-start understanding of SCALe alone and then the full SCAIFE system:
•	SCALe demo: On the SCALe manual index page at `file://<YOUR_MACHINE_FILEPATH_TO_SCAIFE>/scaife/ui_server_stub/scale.app/doc/scale2/Welcome.html`
o	select “Quick Start Demo” from the SCALe-focused index, and follow the instructions to create your first SCALe project. (To login, use the hardcoded initial username “scale“ and password “Change_me!“.)
•	SCAIFE demo:
o	Select “DataHub” (SCAIFE-DataHub.html) from the SCAIFE-focused index
	Run through steps of “Creating a Test Project” and “Adding Audit Data” (for the latter, make sure to do steps 10 and 11, which require you to open another hyperlinked tab [SCAIFE-Statistics.html](http://127.0.0.1:8083/doc/scale2/SCAIFE-Statistics.html) and then create and run a classifier.

For running the SCALe demo, some users had an issue logging in with the given credentials in the current guide (may need to create your own username and password/signing up). Also, I had consistent errors in trying to export a table of the audit, but exporting a database version worked using the SCALe demo instructions. Alternatively you could do this: first, `docker-compose down` to restart the servers, then in that same terminal, run `docker-compose -f docker-compose.yml up --build` to rebuild the containers. In a separate terminal simultaneously, verify that the stats and scale server are running, before running `docker-compose exec scale scripts/automation/create_manual_test_project_1_dos2unix_rosecheckers.py` . You should see the SCALe homepage has one individual project called dos2unix/rosecheckers project. Then click export database.


## Debugging Test Suite Auto Adjudications

[SCAIFE-Debugging-Test-Suite-Auto-Adjudications.md](SCAIFE-Debugging-Test-Suite-Auto-Adjudications.md)

## Important Relationships

Many entity associations exist within the system, and there are several ways to consider these relationships, but generally:

```
datahub_db

package
  alert (datahub_db.alert)
    tool_id
    code_language
    verdict ("DI_C: CWE-789 TRUE")
    checker_id
  code_languages
  test_suite
  tools

project
  meta_alert (datahub_db.meta_alert)
    condition_id
    filepath
    auto_verdict ("DI_C: CWE-789 TRUE")
  taxonomies (CERT, CWE, etc.)
    conditions (CWE-122, INT30-C, etc.)
      platforms
      languages
      conditions
  source_file
    defect_info
  source_function


checker (datahub_db.checker)
checker_condition
checker_mapping

cross_taxonomy_test_suite_mapping
  test_suite_type
  condition
  related_condition
  source_file

tools
  code_languages
  language_platforms
  checkers
```


## Debugging SCALe

Unfortunately, the SCALe server container cannot be debugged. This is because the 'thin' Ruby server that SCALe relies on runs with standard input disabled.  However, you can debug SCALe by running a second SCALe server inside the container (on port 8093). Here's how to do it:

1. Launch SCALe as you normally do. For example: `docker-compose up --build scale`

2. Do whatever normal setup you wish to do with SCALe. This includes accessing it from your web browser, or creating a project. For example: `docker-compose exec scale ./scripts/automation/create_basic_project.py`)


3. Add `binding.pry` to the Ruby code you wish to debug. This effectively sets a breakpoint.  For example, in `scale.app/app/controllers/alert_conditions.controller.rb`:

```
    def LogDetermination(display, meta_alert_id, project_id)
      # Add a breakpoint here:
      binding.pry
      ... rest of code ...
```

4. Launch a second SCALe server on the container at port 8093:

    `docker-compose exec scale bundle exec thin start --port 8093`

You can now access this debuggable server from your browser at `http://localhost:8093`.

5. Trigger your breakpoint. For this example, use your browser at `http://localhost:8093`, select the project created from step 2, and change the verdict of any alert condition to be True.

You will get debugger output in the terminal with the second SCALe server and be able to interact with it there.  For more information about how to debug Ruby code with `pry`, see https://www.honeybadger.io/blog/debugging-ruby-with-pry/
