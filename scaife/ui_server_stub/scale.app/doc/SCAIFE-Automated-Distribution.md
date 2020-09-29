---
title: 'SCAIFE : Source Code Analysis Integrated Framework Environment (SCAIFE)'
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

Automated Distribution of SCAIFE
=========================================

Considerations of size
---------------------

The SCAIFE VM has a Vagrantfile that sets it to have 24GB memory and a 200GB disk specification.
As of 8/1/2019:

2.7 GB OVA file previous to import to VMWare
6.54 GB in VMWare (and that’s before importing Juliet test suites and SA+metrics output, plus prior to starting servers which will have copies of all that at 3 or more servers.)

Review and possibly update the Bill of Materials (BOM)
---------------------
Do a brief review of `scaife/Bill_of_Materials.md` and quickly add/remove info if necessary. For now, only do fast updates if there's been an additional third-party software package update that you know of.
(We are not spending much effort on updating it for now. At some point in the future we will automate the process, which will include automated collection during deployment of third-party software.)
For now we point readers to updated information in the scaife/Vagrantfile and to the 5 Dockerfiles for lists of explicitly-added third-party packages, in addition to the previously-documented third-party software
from a previous (effort-intensive) manual process of gathering data.
No edits should be made below (as of 5/8/20) what's currently line 16, since everything below that line only describes what was in SCAIFE System release version 2.1.3.

Assuming you are working with the code in a repository (that's how we code at the SEI, and hopefully you do that also), then Update the file in the release branch (git commit and push).
Eventually, you will create a PR and merge the update (and other release branch updates, per below) with your development branch (called `dev-branch`, within the SEI repositories, but for our GitHub publications we use the `scaife-scale` branch as of September 2020).
If you are external to the SEI, we would be grateful if you would share new features and bugfixes you develop, by submitting a PR to our GitHub  `scaife-scale` branch of `scale.app` at https://github.com/cmu-sei/SCALe

Detail: The current BoM is in the code repository and released within container tarballs. The BoM is also in deployed VMs, located at:  `~/Desktop/scaife/Bill_of_Materials.md`.

Update Markings and About Files
-------

Determine if current SEI markings apply or if they need to be updated by SEI Contracts (or if you are external to the SEI, update the markings/copyright appropriately for files you have modified). Update them (year and or total markings) as needed,
using your favorite text editor and possibly a script (for changing only year). Make sure that the copyright year and the version strings are correct. (Within the internal SEI Secure Coding wiki, there are details about SCALe version numbering,
which incorporate the development branch. For example:
* `minnow` branch used for SCALe versions compatible with SCAIFE have an `r` in the branch version
* Current version numbers have three integers joined by dots (`##.##.##`). They consist of left-to-right: a major number (for major new features), minor number (added feature(s)), and bugfix(es)

For SEI new releases, consult Lori for the correct version number for SCAIFE, for
(1) the version number of minnow-SCALe within SCAIFE; (2) the overall SCAIFE System version number; AND (3) the SCAIFE API version numbers (5 API version numbers, they may all be different, for more information see Section 'Update API' below).
Here are the files with markings that will need to be updated:

`scaife/ABOUT`  (This file contains all the other copyright files, formatted, AND the version numbers. Check carefully that all are updated appropriately.)
If the release will be on a release VM, then the "`scale_name`" extension should be "`.vm`". Else, if the release will be code intended for external users to start Docker containers (not released on a VM) then the  "`scale_name`" extension should be "`.codecntr`".
This file should have raw text for all 4 copyrights under "legal", "legal-api", "legal-manual", and "legal-scale"
`scaife/ui_server_stub/scale.app/ABOUT`
If the release will be on a release VM, then the "`scale_name`" extension should be "`.vm`". Else, if the release will be code intended for external users to start Docker containers (not released on a VM) then the  "`scale_name`" extension should be "`.codecntr`".
This file should have raw text for the SCALe copyright under "legal"
`scaife/ui_server_stub/scale.app/doc/SCALe-copyright.md`

If only the release version needs to be changed, this file should not be manually edited. (Later in the release process, either with the `Vagrantfile` or manually you will run `package.py` which will provide the correct version from the `scaife/ABOUT` file)
However, if the markings file needs to be substituted, then this file should be manually edited. When doing that, make sure to include the text (`{{SCAIFE_VERSION}}` and `{{SCALE_VERSION}}` as appropriate) so it can automatically be updated with new version numbers from the ABOUT file, for this and future releases.
```
scaife/ui_server_stub/scale.app/COPYRIGHT (this is the raw text version of scaife/ui_server_stub/scale.app/doc/SCALe-copyright.md  )
scaife/ui_server_stub/scale.app/doc/SCAIFE-API-copyright.md
scaife/ui_server_stub/scale.app/doc/SCAIFE-MANUAL-copyright.md
scaife/ui_server_stub/scale.app/doc/SCAIFE-SYSTEM-copyright.md
```
These files should also be inspected and updated as needed. They have an HTML-ified copyright notice:

```
scaife/ui_server_stub/scale.app/doc/Welcome.md
scaife/ui_server_stub/scale.app/doc/SCAIFE-Welcome.md and all other doc/SCAIFE-*.md files
scaife/ui_server_stub/scale.app/doc/Introduction.md
scaife/ui_server_stub/scale.app/doc/control/html.template
scaife/ui_server_stub/scale.app/app/views/layouts/_footer.html.erb
```
Update the files in the release branch (git commit and push).

Eventually, if working with the code in a repository, you will create a pull request (PR) and merge the updates (and other release branch updates, per below) with development branches (for developers within the SEI, those include `dev-branch` and `minnow`).

Update API
-------

Someone must update the API version in the 5 scaife `swagger.yaml` files in the scaife repository.

That person should check what the API version was (in the 5 `swagger.yaml` files in the `scaife` repository, located at  `scaife/*_server_stub/swagger_server/swagger/swagger.yaml` ) in the last published (API or  SCAIFE system) release.
Do that by checking in the Bitbucket code repository in the development branch. For each `swagger.yaml` file, navigate to the `swagger.yaml` file in your repository (e.g., within SEI that's BitBucket viewed via your web browser), then select `History`
drop-down  at the top of the page. Look for any commits since the last release date. Use the commit messages to understand if there was a bugfix or feature added for the particular commit (usually it's one or the other),
or even a major change requiring an update to the first number)
If you are an external-to-SEI organization, please add something to the version ID that specifies it is your branch (not the SEI main branch, which otherwise might have identical version IDs).


The code (or .yaml file!) releaser is responsible for checking the 5 files, and comparing current numbers to the last-released number.
If any of the 5 swagger.yaml files have changed since the last publication/release, then that file should have its number incremented. (Related to a release JIRA issue, there should be one or more release branches with that JIRA issue number, and that person should
`git commit` and `git push` those edits, then PR-accept those changes into the development branch of `scaife`, which within the SEI is `dev-branch`.
EVEN IF none of the version numbers have changed, the HTML, JSON, and updated YAML files should be regenerated to use the latest copyright and date information. ESPECIALLY if any of those 5 .yaml files has a version number that incremented since the last publication, definitely the HTML and .json files (and, if applicable, the aggregated .yaml file) must be modified to use that version number.

`scaife/ABOUT` should be changed (see Update Markings section above) to contain the new version number of SCAIFE (change as usual according to if there have been any bugfixes, any feature additions, and any major version changes) and also the
appropriate SCALe version number
Use the 2 automated scripts to create the correct updated JSON, HTML, and YAML files (5 of each filetype). (Btw, there's some info about the scripts in SCAIFE manual pages.) This makes a total of 15 newly-regenerated API files (5 YAML, 5 JSON, and 5 HTML)
Git commit the 5 newly-regenerated `swagger.yaml` API files to the `scaife` repository in the correct directories (Then, make a PR and merge these changes to `dev-branch` of `scaife`)
After updating the `scaife/ABOUT` file, then from the `scaife` directory, run the following commands to update the API files  (substitute your own machine's filepaths for the filepaths below, e.g., on the VM the filepath to `codegen` is `/home/vagrant/swagger-codegen`) with the
updated API version ID (substitute below):

```
python helpers/api_json_and_html_generator.py datahub_server_stub/swagger_server/swagger ~/opt/swagger/swagger-codegen -v 1.1.2 -li /home/lflynn/scale/epp/scaife/ABOUT
python helpers/api_html_formatter.py datahub_server_stub/swagger_server/swagger/swagger.yaml datahub_server_stub/swagger_server/templates/index.html
python helpers/api_json_and_html_generator.py priority_server_stub/swagger_server/swagger ~/opt/swagger/swagger-codegen -v 1.0.0 -li /home/lflynn/scale/epp/scaife/ABOUT
python helpers/api_html_formatter.py priority_server_stub/swagger_server/swagger/swagger.yaml priority_server_stub/swagger_server/templates/index.html
python helpers/api_json_and_html_generator.py registration_server_stub/swagger_server/swagger ~/opt/swagger/swagger-codegen -v 1.0.0 -li /home/lflynn/scale/epp/scaife/ABOUT
python helpers/api_html_formatter.py registration_server_stub/swagger_server/swagger/swagger.yaml registration_server_stub/swagger_server/templates/index.html
python helpers/api_json_and_html_generator.py stats_server_stub/swagger_server/swagger ~/opt/swagger/swagger-codegen -v 1.0.1 -li /home/lflynn/scale/epp/scaife/ABOUT
python helpers/api_html_formatter.py stats_server_stub/swagger_server/swagger/swagger.yaml stats_server_stub/swagger_server/templates/index.html
python helpers/api_json_and_html_generator.py ui_server_stub/swagger_server/swagger ~/opt/swagger/swagger-codegen -v 1.0.1 -li /home/lflynn/scale/epp/scaife/ABOUT
python helpers/api_html_formatter.py ui_server_stub/swagger_server/swagger/swagger.yaml stats_server_stub/swagger_server/templates/index.html
```

Next: Update each of the 5 `setup.py` files to its proper API version, as determined above

These files are located in `scaife/*_server_stub/setup.py`

Commit 10 files in the release branch:

`git commit` and `git push` newly-created `swagger.yaml` files. (but not the HTML or JSON api files)
`git commit` and `push` newly-edited `setup.py` files

Eventually, you will create a PR and merge the updates (and other release branch updates, per below) with your development branches (within SEI, `dev-branch` and `scale.app`).

For after 7/23/20: Optionally, you can use the third automated script to remove examples (some auto-generated, some manually-generated). DO NOT COMMIT EDITS to the code repository AFTER REMOVING THE EXAMPLES.
Despite the fact that the examples currently cause problems with auto-generated JSON files, the examples are useful for developers. When we have time and funding, we plan to correct the examples.

```
python helpers/remove_yaml_examples.py datahub_server_stub/swagger_server/swagger/swagger.yaml
python helpers/remove_yaml_examples.py priority_server_stub/swagger_server/swagger/swagger.yaml
python helpers/remove_yaml_examples.py registration_server_stub/swagger_server/swagger/swagger.yaml
python helpers/remove_yaml_examples.py stats_server_stub/swagger_server/swagger/swagger.yaml
python helpers/remove_yaml_examples.py stats_server_stub/swagger_server/swagger/swagger.yaml
```
Verify README files
-------
Verify that the `scale.app/README.md`  and `scaife/README.md` files are correct:

* Verify that their `Installation Instructions` and `Relevant Known Issues` sections are accurate.
* Add any JIRA "bugfix" issues that identify "relevant known issues".
* Remove fixed bugs
* Update version
* Update the `README` files in the release branches (`git commit` and `push`).

Eventually, you will create a PR and merge the updates (and other release branch updates, per below) with your development branches (for SEI developers, these include `dev-branch` and `scale.app`).

First, prep the code and tag repos for the release
-------

1. If within the SEI, create a new JIRA issue for the release.
1. create new branches (of `scaife`, `scale.app`, and `rapidclass_scripts` branches `stats_dev` and `dh_dev`) from the JIRA issue for the release
1. Using the release branches:
    * Review and possibly update the Bill of Materials (BOM), per section above
    * Update Markings and `ABOUT` Files, per section above
    * Update API, per section above
    * Verify README files, per section above
1. Make sure you have `git push`-ed all the above changes you were supposed to push to the release branches. (The next steps are possibly error-prone, so it's important to have pushed your changes so far in case you need to revert back to them.)
1. In a completely fresh empty directory outside of any previous clone or copy of the repository (including different from anything used in the steps immediately above):
    * Make a fresh clone (or copy if you don't have direct repository access) of the ``scaife`` repository
        * If you have access to the repositories, do ``git submodule update --init`` to get the submodules in the appropriate directories (for SEI developers, ``scale.app`` (using ``minnow`` branch, in ``scaife/ui_server_stub``) and ``rapidclass_scripts`` (``stats_dev`` and ``dh_dev branches``)
    * Caution: The following step will alter files in the directory, in addition to finding missing legal tags. Do this with a temporary copy or clone of the code.
    * Perform the following step in the ``scaife`` directory, to find missing legal tags and add them, using the following method:
        * run `python2 ui_server_stub/scale.app/package.py -w`  to identify any missing legal markings (In addition to identifying missing tags, the script substitutes for `<legal></legal>` tags and removes proprietary mappings. ).
        * manually fix any files it identifies as lacking legal tags
        * `git commit` and `git push` only the added legal tags to the release branches. CAUTION: Do not commit/push files with the legal markings substitutions!
1. make pull requests and merge to main development branches (`dev-branch`, `minnow`, `stats_dev`, and `dh_dev`)
1. Git tag all 4 SCAIFE development branches with the SCAIFE release version and a message saying which SCALe release version. For the rapidclass and scaife branches that looks like this command: `git tag -a 1.1.1 -m "SCAIFE v 1.1.1 release SCALe v r.6.1.1.1.A"`
For the `stats_dev` and `dh_dev`, the tag respectively for that release would be `stats-1.1.1` and `dh-1.1.1`  Then, `git commit` and `push` the tag (which by default doesn't get pushed) using `git push --tags`.
For SCALe use a command like: `git tag -a r.6.1.1.1.A  -m  "SCAIFE v 1.1.1 release SCALe v r.6.1.1.1.A"`   Verify the new tag is there locally and remotely with `git tag -n` and also `git ls-remote --tags`
1. In a fresh (empty) base directory `~/temp`, make a fresh clone of `scaife` (`dev_branch`) and then do `git submodule update --init`  to get the submodules in the appropriate directories (for SEI developers,
`scale.app` (using `minnow` branch, in `scaife/ui_server_stub`) and `rapidclass_scripts` (`stats_dev` and `dh_dev` branches). The clone should checkout the main branch under the `scaife` directory which is `dev-branch`. Verify this by running `git status` under the `scaife` directory.
NOTE: The submodules may initialize in a DETACHED HEAD state. In this case you will need to checkout each of the submodule default branches individually. 
To do so, change to the location of the submodule and checkout the default branch with the command `git checkout <default-branch>`:

    | Submodule Location                                             | Default Branch |
    | :------------------------------------------------------------: | :------------: |
    | `scaife/ui_server_stub/scale.app`                              | `minnow`       |
    | `scaife/stats_server_stub/swagger_server/rapidclass_scripts`   | `stats_dev`    |
    | `scaife/datahub_server_stub/swagger_server/rapidclass_scripts` | `dh_dev`       |

1. run `package.py` as described below to remove proprietary mappings (unless specified as an argument) and code, download a CWE PDF, create the SCAIFE/SCALe HTML manual, and make an initial tarball of all of it:
    * If the user will run the containers **offline**:
        * If they run the containers offline, then when the user is using the SCALe interface, when they select the SEI coding standards (or a hyperlinked CERT coding rule from the SCALe GUI alertConditions list), they will open the static version of the SEI CERT coding standards that were exported for release, and included in the release.
        * Each exported coding standard can be downloaded as a ZIP file of Confluence docs. Unzip a coding standard's exported file into public/doc, which should produce a single folder (e.g., c) with the exported HTML files for that standard. Do that for all the standards (C, C++, Java, Perl, Android).
        * Command to run (from the scaife directory), with example parameters, and you should substitute your own path to that directory in the following command (see additional examples below):
`python2 ui_server_stub/scale.app/package.py --target=scaife-offline --top-dir=<absolute-path-to-scaife-release-directory>/scaife --dependent`
    * If the user will run the containers **online** (meaning, internet-connected),  and you should substitute your own path to that directory in the following command (see additional examples below):
        * In this case, when the user is using the SCALe interface, when they select the SEI coding standards (or a hyperlinked CERT coding rule from the SCALe GUI alertConditions list), they will open the SEI CERT coding standards wiki online. This means they will be able to see the latest and greatest coding standards versions.
        * Command to run (from the scaife directory), with example parameters: `python2 ui_server_stub/scale.app/package.py --target=scaife-online  --top-dir=<path-to-scaife-release-directory>/scaife  --dependent`
        * Example: `python2 ui_server_stub/scale.app/package.py --target=scaife-<offline-or-online> --top-dir=/home/lflynn/temp/scaife --dependent`


Second, use that tarball to create a SCAIFE VM.
---------------

This series of steps assumes you still have the tarball from the previous section, and it still lives in the packages directory in which it was created. To create a SCAIFE VM from this tarball, do the following:

1. In the `scaife` directory, run `vagrant up`. The scaife directory should have the Vagrantfile and a new packages directory with the tarball created from the previous section.
1. Put a copy of the `SCAIFE-SYSTEM-copyright.html` (Dist F) file on the `~/Desktop`
1. Add Juliet codebase and open-source static analysis tool output to the VM, in the `~/Desktop` directory
1. Run the following script to create `cppcheckConsolidated.xml`:
`./ui_server_stub/scale.app/scripts/helper_scripts/cat_tool_output.py cppcheck ../juliet/analysis/cppcheck ../juliet/analysis/cppcheckConsolidated.xml`
1. Make the following UI tweaks to the VM:
    * The VM should launch a terminal and browser when it starts up:
        * `Settings -> Session and Startup → Application Autostart`
        * Add `"Terminal Emulator" /usr/bin/xfce4-terminal`
        * Add `"Web Browser" /usr/bin/firefox`
    * Add launchers for terminal emulator and web browser to `Desktop`:
        * In start menu select "Web Browser", then drag it to root window (eg desktop). Do the same for "Terminal Emulator".
    * Firefox should have two tabs open: One for its homepage: file://localhost:8083, and one for the SCAIFE welcome documentation file://home/vagrant/Desktop/scaife/ui_server_stub/scale.app/public/doc/scale2/SCAIFE-Welcome.html.
        * The SCALe homepage will only appear if SCALe is running. If you reboot, you will need to restart them. To do this, in the scaife directory in a terminal, type `docker-compose up`.
        * Opening the SCALe homepage will prompt for the user and password. After entering those in, allow Firefox to remember them.
        * Once both tabs are open, select `Preferences -> Home -> Use Current Pages`
    * The file chooser that appears whenever you upload files in Firefox should have the folders for dos2unix and microjuliet added. To do this:
        * Create a new project in SCALe. When prompted to upload a source code archive, select 'Browse', which brings up the filechooser.
        * Traverse to `scaife/ui_server_stub/scale.app/demo/dos2unix`.  Then drag the path to the left sidebar.
        * Do the same for `scaife/ui_server_stub/scale.app/demo/micro_juliet_v1.2_cppcheck_b`
        * Afterwards, go back to the homepage and delete the project.
    * Verify you can view the SCAIFE/SCALe HTML manual and that at minimum the following items look ok:
        * in your VM's Firefox browser, view file `scaife/ui_server_stub/scale.app/public/doc/scale2/Welcome.html`
        * view the SCALe copyright page in the HTML manual (make sure it has reasonable text) via the VM browser, at file `scaife/ui_server_stub/scale.app/public/doc/scale2/SCALe-copyright.html`
            * Make sure copyright year is this year
            * make sure there are no "`{{SCALE_VERSION}}`" strings left
        * make sure link to SCALe copyright page works from the top and the index is listed at `scaife/ui_server_stub/scale.app/public/doc/scale2/Welcome.html`
        * verify the SCAIFE HTML pages are properly marked.
            * SCAIFE pages start here: `scaife/ui_server_stub/scale.app/public/doc/scale2/SCAIFE-Welcome.html`
                * There's a list (currently 8) of additional SCAIFE pages from this page
            * Make sure the following file ( `scaife/ui_server_stub/scale.app/public/doc/scale2/SCAIFE-SYSTEM-copyright.html` ) does not have the string "`{{SCAIFE_VERSION}}`"
            * At top section, click to see these 3 copyrights from the following hyperlinked text:
                * "here"
                * "Click here to see the SCAIFE system copyright."
                * The SCAIFE API definition copyright is "here"
            * In footer section, click on hyperlinked text, for both of the following:
                 * "`©Copyright for SCALe`" and
                 * "`©Copyright for SCAIFE documentation not SCAIFE system`"
         * verify some non-SCAIFE HTML pages (like the manual index) don't have the same SCAIFE top section with copyright
    * Verify that you see the legal markings (legal tags substituted) in several files (variety from `scaife`, `rapidclass_scripts`, and `scale.app`)

1. Test the vagrant VM.
    * Explanation: Some software is installed on the VM, others in containers, and the VM user has to be able to make these edits and recreate API files, plus make code edits and re-run tox tests, plus run swagger-ui to do curl testing using the API files.
    * NOTE: Tests below should be done in 2 cases:
        * Anytime the Vagrantfile is updated.
        * Prior to every VM release, very close to the release day, to make sure that the functionality still works on the deployed VM. (Someday hopefully we will have automated tests for these, that automatically test deployed VM.)
    * First take the VM down, either within the VM itself (do a shutdown). Or do vagrant halt in the host.
    * Launch Virtualbox, and select `Export Appliance`. This produces an archive of the VM that can be released, if all tests pass.
    * Relaunch the VM, either in Virtualbox's GUI, or vagrant up in the host.
    * At minimum, run all of the tests in the following list and they must pass. NOTE: The tox tests (top of the list) must be run using independent containers, but all the other tests must be run using dependent containers:
        * Tox tests:
            * If you already have any containers running, then stop the containers from the scaife directory with command `docker-compose down` before proceeding.
            * Run all tox tests, they must all pass. Note that, unlike subsequent tests, the tox tests require the containers to not be running. This is because most of them must be launched in a special test mode.  The tox tests themselves run in the various containers rather than the VM itself.
            * Run the tox tests on independent Swagger containers, as follows:
                * Build and run an independent container: `docker-compose -f docker-compose.yml up --build`
                * Command to test that swagger server is running: `wget -q -O - localhost:$PORT/status --header="x_request_token: deadbeef"`
                   * This command should produce:
```
{
"message": "$SERVER Server is Running Properly",
"request_id": "deadbeat"
}
```
Each Swagger server has some tox  regression tests. These command will test each Swagger server (except for stats). The tests can be run while the production servers are still running:
```
docker-compose  -f docker-compose.yml  run  registration  tox
docker-compose  -f docker-compose.yml  run  priority      tox
docker-compose  -f docker-compose.yml  run  datahub       tox
```
                   The Stats server is more complicated. To run its tox tests, you need to take down both stats and datahub servers. Then these commands will test Stats:
```
docker-compose  -f docker-compose.yml  -f docker-compose.test.yml  up -d  datahub
docker-compose  -f docker-compose.yml  up  -d stats
docker exec stats  ./wait_for_pulsar.sh pulsar
docker exec stats  tox
```
                   The test fails if and only if you see ERROR or FAIL: Examples:
```
Test case for get_projects ... ok
Test case for upload_codebase_for_package ... FAIL
```
        * Prep for all the rest of the tests, which require dependent containers that can be started once and stay up for the rest of the tests:
            * In the VM's terminal, stop the independent containers (`docker-compose down` in the `scaife` directory before proceeding.
            * In the VM's terminal, restart SCAIFE with dependent containers (`docker-compose up` in the `scaife` directory)
        * Check that SCALe can connect to SCAIFE registration server from SCALe homepage in browser.
        * Open the SCALe / SCAIFE HTML manual from the SCALe homepage, and verify that one page looks good. (The pages should look the same as they did in the tarball)
        * Test editing and rebuilding the SCALe/SCAIFE HTML manual:
            * Edit the file
              `/home/vagrant/Desktop/scaife/ui_server_stub/scale.app/doc/Introduction.md`
              (e.g., add a line "Hello World")
            * Run `docker-compose exec scale ./scripts/builddocs.sh`
              to generate the updated HTML pages
            * View the SCALe/SCAIFE HTML manual in the VM's browser
              (Firefox), and verify that this file now contains your
              edit at filepath:
              `file:///home/vagrant/Desktop/scaife/ui_server_stub/scale.app/public/doc/scale2/Introduction.html`
        * Run these 2 automated python scripts, then check from the
          SCALe GUI that the projects have been created and for each,
          that confidence values show in the alertConditions list:
            * `docker-compose exec scale ./scripts/automation/create_manual_test_project_1_microjuliet_cppcheck.py`
            * `docker-compose exec scale ./scripts/automation/create_manual_test_project_1_dos2unix_rosecheckers.py`
        * Test editing and rebuilding the Swagger APIs:
            * Edit the `swagger.yaml` files for each of the 5
              modules. Change something unimportant, like adding a
              comment in each file.
            * Then, regenerate fresh API files (HTML, YAML,
              JSON). This is accomplished by executing the following
              two commands in order for each module:
                 * `python3 helpers/api_json_and_html_generator.py datahub_server_stub/swagger_server/swagger /home/vagrant/swagger-codegen -v 1.1.2 -li /home/vagrant/Desktop/scaife/ABOUT`
                 * `python3 helpers/api_html_formatter.py datahub_server_stub/swagger_server/swagger/swagger.yaml datahub_server_stub/swagger_server/templates/index.html`
            * Verify that your changes appears in the following files
              (again for all 5 modules):
                * The code-generated HTML API files at:
                  `/home/vagrant/Desktop/scaife/datahub_server_stub/swagger_server/templates/index.html`.
                * The code-generated JSON API files should be at
                  filepath location:
                  `/home/vagrant/Desktop/scaife/datahub_server_stub/swagger_server/swagger/swagger.json`.
                * the fixed-up YAML API files should be at filepath
                  location (substitute module for '*'):
                  `/home/vagrant/Desktop/scaife/*_server_stub/swagger_server/swagger/swagger.yaml`
            * Open your VM's browser (Firefox) up to each of the HTML
              files. The easiest way is to go to
              `file:///home/vagrant` and then trace down to the
              appropriate file: `Desktop`, `scaife`,
              `..._server_stub`, `swagger_server`, `swagger`,
              `swagger.yaml`
            * Use the swagger-editor to view the files as well. To do
              this, first start the swagger-editor container, with the
              command:
                 * `docker run -it --rm -p 80:8080 swaggerapi/swagger-editor`

              Then point your VM's browser (Firefox) to
              http://localhost, and select File->Import File. Then
              select each `yaml` file.
            * Use swagger-ui to view each of the `json` and `yaml`
              files. To do this, open your VM's browser (Firefox) to
              http://localhost:8084/ui (for Datahub). The other
              servers use ports 8085 (priority), 8086 (stats), and
              8087 (registration). For this step you can ignore SCALe,
              as it has no swagger-ui.
       * Run a curl command received by the datahub, via the
         `swagger-ui` installed on one of the containers, or else via
         `swagger-editor` installed directly on the VM per
         instructions in the
         [SCAIFE-Customization.md](SCAIFE-Customization.md) page,
         within the VM.
            * Use the same steps above to verify that each module's
              `.yaml`, `.json` and `.html` files have the changes you
              made. That is, inspect them using your VM's browser
              (Firefox), along with swagger-editor and swagger-ui.
   * If the current testing is being done just prior to a release:
     Once you have all the below tests working, have others on the
     team also test the VM (The VM needs to be tested and approved by
     Lori before release, within the SEI)
   * Before deploying the VM, you should remove the shared /vagrant
     directory, as its host location will be specific to your host.

Creation of SCAIFE Code Distribution Specific to External Docker Container Use
---------------
1. create new JIRA issue for the release
1. create new branches (of `scaife, scale.app`, and `rapidclass_scripts` branches `stats_dev` and `dh_dev`) from the JIRA issue for the release
1. Using the release branches:
    * Review and possibly update the Bill of Materials (BOM), per section above
    * Update Markings and `ABOUT` Files, per section above
    * Update API, per section above
    * Verify README files, per section above
1. Make sure you have git pushed all the above changes you were supposed to push to the release branches.
(The next steps are possibly error-prone, so it's important to have pushed your changes so far in case you need to revert back to them.)
1. In a completely fresh empty directory outside of any previous clone or copy of the repository (including different from anything used in the steps immediately above):
    * Make a fresh clone (or copy if you don't have direct repository access) of the ``scaife`` repository
        * If you have access to the repositories, do ``git submodule update --init`` to get the submodules in the appropriate directories (for SEI developers, ``scale.app`` (using ``minnow`` branch, in ``scaife/ui_server_stub``) and ``rapidclass_scripts`` (``stats_dev`` and ``dh_dev branches``)
    * Caution: The following step will alter files in the directory, in addition to finding missing legal tags. Do this with a temporary copy or clone of the code.
    * Perform the following step in the ``scaife`` directory, to find missing legal tags and add them, using the following method:
        * run `python2 ui_server_stub/scale.app/package.py -w`  to identify any missing legal markings (In addition to identifying missing tags, the script substitutes for `<legal></legal>` tags and removes proprietary mappings. ).
        * manually fix any files it identifies as lacking legal tags
        * `git commit` and `git push` only the added legal tags to the release branches. CAUTION: Do not commit/push files with the legal markings substitutions!
1. make pull requests and merge to main development branches (dev-branch, minnow, stats_dev, and dh_dev)
1. Git tag all 4 SCAIFE development branches with the SCAIFE release version and a message saying which SCALe release version. For the `rapidclass_scripts` and `scaife` branches that looks like this command:
`git tag -a 1.1.1 -m "SCAIFE v 1.1.1 release SCALe v r.6.1.1.1.A"`  For the `stats_dev` and `dh_dev`, the tag respectively for that release would be `stats-1.1.1` and `dh-1.1.1`  Then, `git commit` and `push` the tag
(which by default doesn't get pushed) using `git push --tags` For SCALe use a command like: `git tag -a r.6.1.1.1.A  -m  "SCAIFE v 1.1.1 release SCALe v r.6.1.1.1.A"`   Verify the new tag is there locally and remotely with `git tag -n` and also `git ls-remote --tags`
1. In a fresh (empty) directory, clone ``scaife`` (`dev_branch`) and then do `git submodule update --init`  to get the submodules in the appropriate directories (for SEI developers, `scale.app` (using `minnow` branch, in `scaife/ui_server_stub`) and
`rapidclass_scripts` (`stats_dev` and `dh_dev` branches)
1. run `package.py` as described below, remove proprietary mappings (unless specified as an argument) and code, download a CWE PDF, create the SCAIFE/SCALe HTML manual, and make a tarball of all of it)
    * If the user will run the containers offline:
       * DETAIL: The user will need to be online when they build the containers, that is not a problem. The use case scenario here is that the user builds the containers while internet-connected, then disconnects their machine from the internet and still needs to run SCAIFE.
       * If they run the containers offline, then when the user is using the SCALe interface, when they select the SEI coding standards (or a hyperlinked CERT coding rule from the SCALe GUI alertConditions list),
they will open the static version of the SEI CERT coding standards that were exported for release, and included in the release. NOTE: SEI developers will have access to such exports, but in some releases they will not be included.
       * Each exported coding standard can be downloaded as a ZIP file of Confluence docs. Unzip a coding standard's exported file into public/doc, which should produce a single folder (e.g., c) with the exported HTML files for that standard. Do that for all the standards (C, C++, Java, Perl, Android).
       * Command to run (from the scaife directory), with example parameters, and you should substitute your own path to that directory in the following command:
`python2 ui_server_stub/scale.app/package.py --target=scaife-offline --top-dir=/home/lflynn/temp/code-release-for-containers/scaife  --dependent`
    * If the user will run the containers online (meaning, internet-connected),  and you should substitute your own path to that directory in the following command:
       * In this case, when the user is using the SCALe interface, when they select the SEI coding standards (or a hyperlinked CERT coding rule from the SCALe GUI alertConditions list), they will open the SEI CERT coding standards wiki online.
       This means they will be able to see the latest and greatest coding standards versions.
       * Command to run (from the `scaife` directory), with example parameters,: `python2 ui_server_stub/scale.app/package.py --target=scaife-online  --top-dir=/home/lflynn/temp/code-release-for-containers/scaife  --dependent`
    * After completed running  packages.py, check the following:
       * verify you can view the SCAIFE/SCALe HTML manual, view the copyright page in the HTML manual, the SCAIFE HTML pages are properly marked, etc.
       * verify that you see the legal markings (legal tags substituted) in several files (variety from `scaife`, `rapidclass_scripts`, and `scale.app`)
1. For SEI developers: upload the unencrypted file to `\\ad.sei.cmu.edu\dfs\Groups\CERT\SecureCoding\scale\releases`
1. For SEI developers: Then, encrypt the tarball and upload it to SEI toolshare FTP site, send notification to correct recipients, document that distribution release in the CSF Sharepoint spreadsheet, and notify SEI management and administrators about
the release accomplishment.

------------------------------------------------------------------------
