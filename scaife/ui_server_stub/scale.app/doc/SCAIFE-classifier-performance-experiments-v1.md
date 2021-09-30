---
title: SCAIFE-classifier-performance-experiments-v1.md
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


SCAIFE : Creating and Running a Classification Performance Experiment
=========================================

Below are instructions on how to create an experiment to be used to evaluate classification performance.

### Extract SCAIFE Code Archive, then Place and Extract Separate Config and Experiment Data Files

* A. If SCAIFE was provided as a code archive, extract the code from the tarball (e.g., using command `tar -xvf FILENAME.tar.gz`) or zipfile (e.g., using command `unzip FILENAME.zip`).
* B. If a separate "experiment configurations" file was provided (separate from the SCAIFE code tarball or other type of SCAIFE release):
   * Copy the configurations file to your machine's directory named `~/.configs` (Note: The `~` represents the user's home directory, so for example a directory to copy the configurations file to could be named `/home/lflynn/.configs`. Also, directories that start with a "`.`" (a filename that starts with a period) are usually hidden directories that do not appear in normal listings of a directory (e.g., `ls` command) but will show if hidden files and directories are specified (e.g., `ls -alt`).
   * If the configurations file is in archive format (e.g., ends with `.zip` or `.tar.gz`) then extract it. The extracted configuration file or files will end in `.json`.
* C. If a separate "experiments project creation data" file was provided (separate from the SCAIFE code tarball):
   * Copy the "experiments project creation data" file to the following directory on your machine `${HOME}/.experiment_data` . You could also use this path: `~/.experiment_data`.
      * Note: The `~` represents the user's home directory, so for example a directory to copy the "experiments project creation data" file to could be named `/home/lflynn/.experiment_data`. Also, directories that start with a "`.`" (a filename that starts with a period) are usually hidden directories that do not appear in normal listings of a directory (e.g., `ls` command) but will show if hidden files and directories are specified (e.g., `ls -alt`).
   * If the "experiments project creation data" file is in archive format (e.g., ends with `.zip` or `.tar.gz`) then extract it. The extracted "experiments project creation data" directories will have one directory per experiment project, and each will have a subdirectory named `source` (this holds a code archive) and `analysis` (this holds static analysis tool output, for flaw-finding static analysis tools and in some cases also for code metrics tools).
* D. Note: Possibly when SCAIFE is rebuilt (as part of steps 12-13 below), the files in `~/.configs` and/or `~/.experiment_data` may be deleted. (We will fix that in the future, if the current release still does that.) In that case, after the `docker-compose down` command in step 12, you will need to repeat steps B and/or C above, prior to relaunching SCAIFE (the second `docker-compose` command in step 12) and prior to running the next experiment.

### Launch SCAIFE and Log In

1. Launch SCAIFE in experiment mode from the `scaife` directory: 
    - In a terminal type: `docker-compose down ; docker-compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.test.yml -f docker-compose.experiment.yml up --build`
    - OR (Do not do the following, if you used the previous command) In a terminal type: `docker-compose -f docker-compose.yml -f docker-compose.experiment.yml up --build`
2. Go to `localhost:8083` in a browser. Create an account on SCALe and login.
3. Connect to SCAIFE, registering a new account.
   
### Create a New Experiment
4. Click the "New Experiment" button, or go to `localhost:8083/experiments` in the browser window.
5. CAUTION: Complete the `Adjudicator Information` section **using only the specified FAKE data**. (In the future, we plan to have different testing where testers complete the `Adjudicator Information` information section about the tester who will be adjudicating the experiment project.)
*FOR THE SEPTEMBER 2021 SCAIFE RELEASE FOR CLASSIFICATION PERFORMANCE TESTING, ONLY ENTER **FAKE** DATA, AS FOLLOWS!!*
   * Name "NameX"
   * Organization "OrgX"
   * experience level coding "2. medium"
   * number years experience in each of the languages "5"
   * self-identified experience adjudicating static analysis warnings "2. medium"
   * number of years experience adjudicating static analysis warning: "1"
   
6. Complete the `Experiment Configuration` information.
   - `Select Experiment`: Choose the name of the experiment the adjudicator will be running.
   - The rest of the fields will auto-populate based on the selected experiment name.
   - Select only experiments with the following letter and number combination strings: c`NUMBER`, r`NUMBER`, and fhc`NUMBER` (where the "`NUMBER`" represents an integer). 
7. Submit the form by clicking the `Create Experiment` button at the bottom of the page.
   - Clicking this button will create the SCALe and SCAIFE projects needed to complete the experiment.
     - **NOTE**: Creating the experiment will create two new projects in SCALe and SCAIFE. The naming format for these projects is below:
        - ``` (Experiment <experiment_creation_timestamp>) <name_of_experiment_config>``` 
   - Once the projects are created, a classifier will be created based off of the experiment projects.  That classifier will be run on the project which will be manually adjudicated.
   - The project page for the project that is to be manually adjudicated will be presented when the classifier is finished running.
   - After the list of static analysis results comes up in your GUI, in the top (shaded-blue) "`filter`" area of the GUI, set `Verdict` filtering to `Unknown`, and then select the dark blue `Filter` button.

### Perform Manual Adjudications
8. Perform manual adjudications as desired.
   - See [Inspect-AlertConditions-to-Adjudicate-for-Conditions](Inspect-alertConditions-to-Adjudicate-for-Conditions.md) for instructions on how to perform manual adjudications of meta-alerts.
   - **NOTE**: As meta-alerts are manually adjudicated, SCAIFE will automatically rerun/retrain the classifier, utilizing any adaptive heuristics that were included in the experiment configuration.
9. The experiment will end if the project reaches the maximum number of manual adjudications designated for the experiment, or if  the `End Experiment` button that is located directly above the adjudication pane is clicked.
   - When you hit the `End Experiment` button, the browser will notify you when the experiment data has finished exporting.
   - If the experiment automatically ends (after reaching the maximum number of manual adjudications), it will show a red bar at the top of the GUI which states that the experiment has finished. It tells the analyst to stop adjudicating and to check the export directory (`~/.exports`) for the three exported files. It may take awhile for the three files to export, particularly with large codebases. DO NOT STOP or RESTART ANY OF THE DOCKER CONTAINERS until all three files have been exported. Also, please BE CAREFUL TO SAVE THOSE END-OF-EXPERIMENT FILES SOMEPLACE SAFE THAT WILL REMAIN AROUND, SO YOU CAN SHARE INFORMATION ABOUT CLASSIFICATION PERFORMANCE WITH THE SEI RESEARCH TEAM.

### Export Experiment Data
10. Once the experiment has ended, three files will be generated on the local host in the  `$HOME/.exports` shared volume.  The three files will be named as such, where the name of the experiment will be substituted in:
      1. `scale_<name-of-experiment>.json`
      2. `datahub_<name-of-experiment>.json`
      3. `stats_<name-of-experiment>.json`
11. Retrieve this data and send it to the Software Engineering Institute.
    * If you suspect you may have accidentally entered real adjudicator/org info in the experiment configuration fields:
      1. Inspect each file and search for sensitive information, such as name, organization name, etc. In the text editor of your choice, substitue the sensitive information with non-sensitive information.
      2. Compresss the exported files and send it via DoD SAFE.
    * If the experiment was completed using a codebase that was not provided by the SEI, contact the SEI for a data sanitizing script. SEI will provide a python script that should be run on the exported files. The resulting files will be sanitized using a SHA-256 hash with a salt on possibly-sensitive data fields. More details about the sanitizer can be found in the [SCALe/SCAIFE manual Sanitizer documentation](Sanitizer.md).
   
### PRIOR TO EACH NEW EXPERIMENT: Refresh SCAIFE 
12. to prepare the server for any additional experiments, completely restart SCAIFE as follows.
    - In a terminal type: `docker-compose down ; docker-compose -f docker-compose.yml -f docker-compose.experiment.yml up --build SCAIFE`
13. **Optional** - Delete the projects created in SCALe that were associated with this experiment.
      1. Go to `localhost:8083` and log into SCALe.
      2. The experiment projects created in SCALe for this experiment will be there.  For each project associated with the experiment, click the delete button.
      


---
### Optional Use of Your Own Configuration File and Experiments Project Creation Data

After completing steps A-C, and just prior to the "Launch SCAIFE and Log In" step 1 above, you can set things up so you can run experiments using your own project creation datasets. To do this, follow these instructions:

   * Run static analysis tools (e.g., TOOL1 and TOOL2) on your codebase "CodebaseX". _Use static analysis (SA) tools that work with SCAIFE/SCALe already, or else do the setup required to make a new static analysis tool work with SCALe/SCAIFE (how to do that is described elsewhere in the SCAIFE/SCALe manual)._ 
   * Copy `scaife/datahub_server_stub/swagger_server/experiments/experiment_configs/default_experiment_configs.json` to your machine's directory named `~/.configs` (Note: The `~` represents the user's home directory, so for example a directory to copy the configurations file to could be named `/home/lflynn/.configs`. Also, directories that start with a "`.`" (a filename that starts with a period) are usually hidden directories that do not appear in normal listings of a directory (e.g., `ls` command) but will show if hidden files and directories are specified (e.g., `ls -alt`).
   * Edit the `~/.configs/default_experiment_configs.json` file (which contains information about a handful of experiments, currently) to create a new experiment entry for your data. You should copy one of the existing project entries and paste it, then edit it to specify the local file locations of your codebase archive (`.zip` or `.tar.gz` file) and your static analysis tool output files. Also, specify the toolname of your tool in the experiment section of the configuration file, after looking up the tool's information in `scaife/ui_server_stub/scale.app/scripts/tools.json`. Note that tool IDs are the order of the tool in the `tools.json` file, and tool names and versions are listed in the fields in the `tools.json` file.

### Related to step 5, for the future only and *not* for now.

AT SOME POINT IN THE FUTURE (**NOT FOR THE SEPTEMBER 2021 SCAIFE RELEASE**), WE MAY GATHER REAL DATA. 
WE ARE NOT DOING THAT YET, HOWEVER. 
**CAUTION: Do not enter real data, at this time!!!**
At some future time (not now!!), the data gathered will be as follows:

   - `Name`:  Full Name of adjudicator
   - `Organization`: Name of adjudicator's organization
   - `Coding Experience`: How much experience adjudicator has with related coding language
   - `Years Coding`: How many years adjudicator has coded with related coding language
   - `Adjudication Experient`: How much experience adjudicator has with adjudicating static analysis warnings.
   - `Years Adjudication`: How many years adjudicator has adjudicated static analysis warnings

   
