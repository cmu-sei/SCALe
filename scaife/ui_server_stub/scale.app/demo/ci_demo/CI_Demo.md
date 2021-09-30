---
title: 'SCAIFE : CI Demo Walkthrough'
---
<!-- <legal> -->
<!-- SCALe version r.6.7.0.0.A -->
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

SCAIFE : CI Demo Walkthrough
=============

One version of this walkthrough demonstrates how to integrate SCAIFE [with a CI server](#demo-with-ci-server), using the Datahub Module's CI API. Also, instructions and artifacts are provided to demonstrate the CI integration [without using a dedicated CI server](#demo-without-using-a-ci-server).  A sample CI demo project is provided for this purpose.  The sample CI demo project is located here.  `scaife/ui_server_stub/scale.app/demo/ci_demo`

Instructions that only apply for SEI developers/testers will be prefaced by "For SEI developer/testers only" and those limited instructions end at the next vertical space.

The `ci_demo` folder contains a sample of a preconfigured source code repository.  This repository contains a set of source code files, and a separate set of modified files that will be used to demonstrate the interaction between a CI server and the SCAIFE system.  Also included are sample CI automation scripts, and other files that can be used when following the demo without a CI server.

Below, there are four different types of demos you can run:

1. If you have a CI system and want to fully exercise the demo, follow the [Prerequisites](#prerequisites) section below, followed by the [Demo with a CI server](#demo-with-ci-server) section. 
2. If you only have a few minutes, do the fastest demo, where a script does most of the steps for you: Follow the [Demo with Completely Automated Demo Script](#demo-with-completely-automated-demo-script) section steps. The script uses the preset data like that discussed in the [Demo without using a CI Server](#demo-without-using-a-ci-server) section and the Rosecheckers output that is provided for each version of source code. 
3. To exercise the fastest non-scripted demo requiring the smallest amount of effort, use the preset data in the [Demo without using a CI Server](#demo-without-using-a-ci-server) section and follow [*Approach 1*](#approach-1) using the Rosecheckers output that is provided for each version of source code. 
4. To exercise the second-fastest non-scripted demo requiring a bit more effort than (3), use the preset data in the [Demo without using a CI Server](#demo-without-using-a-ci-server) section and follow [*Approach 2*](#approach-2) using the Rosecheckers output that is provided for each version of source code. 


### Prerequisites

1. Ability to create a new git-based source code repository based on the sample project. (If you are doing demo type 2, the script will do that for you.)

2. If you are doing demo type 1 (from list above), ability to create a corresponding CI server project for the source code repository created for prerequisite 1.

3. If you are doing one of the demo types 1, 3, or 4 (from list above), do the following:

   - Configure the DataHub server to access the git repository

     To do this, edit the `docker-compose.yml` file under the Scaife directory by setting “USECERT:” to the server name of git or the BitBucket server. For example, one of the SEI-used server names is `bitbucket.cc.cert.org`. This will allow datahub to authenticate with BitBucket.
          *Note: The SCAIFE system only supports CI integration with a git-based repository with user/access token based authentication or without authentication.  See the [SCAIFE-CI](SCAIFE-CI.md) documentation for full details on configuring the datahub module for use with CI Integration.* (The previous link works from the HTML page. Instead use [SCAIFE-CI.md](../../doc/SCAIFE-CI.md), from the markdown page.)

   - Proxy Configuration

     When using a proxy the DataHub Module must be explicity configured with the proxy connection information in order to access a git-based repository for cloning and updating. To configure a proxy, edit the `servers.conf` file located at `scaife/datahub_server_stub/swagger_server/servers.conf` by setting `“use_proxy:”` to `“yes”` and modifying the URL to match your specific proxy connection information. For SEI developers/testers, use `proxy_connection: http://proxy.sei.cmu.edu:8080`.

4. A running instance of the SCAIFE system.

   `docker-compose -f docker-compose.yml up --build`

   See [SCAIFE-Automated-Distribution](SCAIFE-Automated-Distribution.md) for detailed information on operating a running instance of SCAIFE. (The previous link works from the HTML page. Instead use [SCAIFE-Automated-Distribution.md](../../doc/SCAIFE-Automated-Distribution.md), from the markdown page.) Simple SCAIFE System startup information is also provided in the file `scaife/README.md`

5. The CERT Rosecheckers Static Analysis tool to perform static analysis on the sample source code.  This demo will use the containerized version of the tool.  The instructions for how to install and use the (cost-free, open-source) Rosecheckers, including the quickest-start method using the pre-built Docker container image, can be found here: https://github.com/cmu-sei/cert-rosecheckers

6. Knowledge of SCAIFE and SCALe terminology.  Specific terminology mentioned in this walk-through, such as *SCALe project* and *SCAIFE package*, can be found in the "Terms and Definitions" help page available from the Help menu of the SCALe application, or directly viewed in the documentation [Terms-and-Definitions](Terms-and-Definitions.md). (The previous link works from the HTML page. Instead use [Terms-and-Definitions.md](../../doc/Terms-and-Definitions.md), from the markdown page.)


### Demo With CI Server
#### Step By Step walkthrough

##### Configuring SCALe
1.  Prepare a new source code repository in your Version Control System (VCS) based on the provided sample project in the ci_demo directory called `toy`, and capture the git repository URL for later use when configuring SCALe.

For SEI only: there is a repository already set up internally that you can use: `https://bitbucket.cc.cert.org/bitbucket/scm/scal/toy2.git`

Generate an access token in the BitBucket server using the following steps:
In the Bitbucket server, click your avatar to open the user menu, then select `Manage account` item.
When the account settings page opens, in the sidebar select `Personal access tokens`.
In the Personal access tokens page, click the `Create a token` button.
In the Create a personal access token dialog, type in a name for the new token, and set permissions for it: `Read` for Projects, and `Read` for Repositories. Then, click `Create`.

When the new token is generated, copy it and place it somewhere safe - you will need your username (username, not token name) and that access token to put into your respective form fields when you're creating the CI project through SCALe.


2.  Using a browser, navigate to the SCALe application at `localhost:8083`. Click the `SCALe Login` button, then the `Sign Up` button and register a new user. 
![](attachments/scale-1.png)

3.  Click on the `Connect to SCAIFE` button and then click the `Sign Up` button to register a new user. 
![](attachments/connect.png) 
![](attachments/register.png)

4.  Select the button `New Project`.![](attachments/newproject.png)

5.  Select the radio button with `SCAIFE-CI` for Data Type.  Then select the button `Create Project`.![](attachments/new-project.png)

6.  Fill out the Project git repo URL, the git user id, and the git access token fields. You do not need to fill out anything else. Currently, for purposes of the demo, code languages, taxonomies, and tools will automatically be selected for the project and uploaded to SCAIFE. Press `Create`. 
![](attachments/createprojectdetail.png)


*Note: The default selections are:

    * `languages: C89, C++98`
    * `taxonomies: CERT C Rules, CWEs`
    * `tools: rosecheckers_oss`

7.  Copy the `Package` access token and the `rosecheckers_oss` tool id and save it for later use.![](attachments/createprojectcomplete.png)


##### Configuring SCAIFE with Docker

*These steps only pertain for when building SCAIFE in Docker
containers.*

If the source code for your analysis project is not in a public
repository and requires a username/`authentication_token`, the environment
variable `$USECERT` must be set to hostname of the git or BitBucket
repository. This can be done in several ways prior to building the
SCAIFE containers with `docker-compose`:

1. Set/export the environment variable `USECERT`, either:
  - prior to running docker-compose: `export USECERT=yourgithost.org`
  - on the same line: `USECERT=yourgithost.org docker-compose ...`
2. Edit the `docker-compose.yml` file and provide `yourgithost.org` as
   the value for the `USECERT:` argument in the datahub section.
3. Create a `.env` file in the SCAIFE build directory with the value
   `USECERT=yourgithost.org`.

*Note for SEI users: The git repository hostname is likely to be `bitbucket.cc.cert.org`*

##### Configuring the CI Server

The CI Server will be used to run the Rosecheckers static analysis tool, and then submit the output of the tool to be analyzed by SCAIFE when a commit is made to the source code repository.

1.  First, configure the CI Server to execute a build when code is committed to the code repository that was configured based on the sample 'toy' project provided in the ci_demo folder.
2.  Configure the CI server to run the rosecheckers tool to analyze the sample project, saving the output as rosecheckers.txt.  Using docker, the command would be similar to the following code:

**NOTE:** The following code sample may first require authentication to a registry before the rosecheckers container can be downloaded and executed.

**Code to authenticate**

`docker login --username ${bamboo.docker_user} -p ${bamboo.docker_token} docker.pkg.github.com`

**Code to download and execute Rosecheckers**

`docker run -v $(pwd):/app docker.pkg.github.com/cmu-sei/cert-rosecheckers/rosebud:latest sh -c "rosecheckers /app/*.c 2>&1" > rosecheckers.txt`

3. Configure CI server to submit the results from step 2 to the SCAIFE CI endpoint.  A sample script has been provided in the `script` directory called `sample_ci_script.sh`.  Modify this script, supplying the `TOKEN`, `TOOL_ID`, DataHub URL, and `git_commit_hash` values that have been gathered. See Approach 1 under [Demo without using a CI Server](#demo_without_using_a_ci_server) below for details on modifying this script.  (Note:  The `git_commit_hash` is provided by the CI system.)


```
#!/usr/bin/env bash

TOKEN="Paste your access token here"
TOOL_ID="Paste your tool ID here"
# Replace datahub_url with your datahub's url
SCAIFE_URL='http://datahub_url:8084/analyze'

#  Revision should be set to the git_commit_hash which triggered the build.  This is provided through a varible made available by the CI server.
# Example below is from the bamboo CI server from Atlassian.

REV="${bamboo.repository.revision.number}"

curl -X POST ${SCAIFE_URL} -H 'accept: application/json' \
  -H  "x_access_token: $TOKEN" \
  -H  'Content-Type: multipart/form-data' \
  -F "git_commit_hash=$REV" \
  -F "tool_id=$TOOL_ID" \
  -F "tool_output=@rosecheckers.txt;type=text/plain"

```

#####  Preparing the source code repository and triggering the build

1.  Use the files in the `toy` directory to make the initial commit to the source code repository that was created for this demo.
```
git commit -m "Initial ci demo commit"
git push
```

2.  This should trigger the build that was configured on the CI server.  The expected output from the first analysis of the source code should have the following output when successful.

*Note: Log output from the CI server.*

```
{
  "alerts_new": 162,
  "alerts_old": 0,
  "deletions": 0,
  "det_correlations": 0,
  "det_transfers": 0,
  "edits": 0,
  "meta_alerts_new": 50,
  "meta_alerts_old": 0
}
```

3.  Replace the files in the source code repository with the files in the `replacement_files` provided in the `ci_demo` folder.

4.  Add, commit, and push the new files to trigger the second and final build for this demo.

```
git add arr36-c-false-1.c arr36-c-true-1.c dcl31-c-true-1.c exp34-c-true-1.c
git commit -m "2nd version of code for CI demo"
git push
```

5. This will trigger the CI build a second time resulting in a cascading analysis which produces the following output captured by the CI server.

```
{
  "alerts_new": 161,
  "alerts_old": 162,
  "deletions": 2,
  "det_correlations": 48,
  "det_transfers": 0,
  "edits": 5,
  "meta_alerts_new": 49,
  "meta_alerts_old": 50
}
```

#### Conclusion

This concludes the SCAIFE CI Demo walkthrough version for an automated CI server.  The second analysis performed on the sample source codes shows that 5 edits and 2 deletions occurred, resulting in 1 less alert.

### Demo without using a CI Server

SCAIFE CI integration can be done without an actual CI server providing the automation.  The same DataHub Module API is used with or without a CI server to automate analysis of various static analyses.  The primary difference between this section of the demo and the previous is less automation.  Please follow the Prerequisites section above.  The prerequisites are the same except for lack of a CI server.


#### Step By Step walkthrough

1. Configure SCALe using the same steps in the [Configuring SCALe](#configuring-scale) section above.
2. Prepare the first code commit using the steps [above](#preparing-the-source-code-repository-and-triggering-the-build). Capture the git commit hash that is generated for use in Step 4 below.
3. Run the Rosecheckers static analysis tool on the `toy` source code using the same instructions from the [Configuring the CI Server section above](#configuring-the-ci-server).  Save the results in a file such as `rosecheckers1.txt`.

   If you are using the internally set-up SEI repository, https://bitbucket.cc.cert.org/bitbucket/scm/scal/toy2.git, the first and second git commit IDs you would use in the automated script are:

   first: `b86a9920ab37c4d5ef3723003490025817ba76a5`
   
   second: `3e42ab9d0ebcfeb2f9b53acd038ee3785d8917fc`


   To view these hashes in BitBucket, navigate to the `toy2` repository, then navigate to the `Commits` section on the sidebar.



**Note: Alternatively, the Rosecheckers static analysis for the sample project has been provided in the `scaife/ui_server_stub/scale.app/demo/ci_demo/non_ci_demo` folder.  The output of the Rosecheckers tool is named `rosecheckers1.txt` and `rosecheckers2.txt` which contains the necessary output matching the first and second commits of the sample `toy` project source code. These files can be substituted in place of the output of running the Rosecheckers tool.**

4. Submit the initial analysis to SCAIFE using the DataHub API. Analysis can be submitted to SCAIFE by using a sample script called `sample_ci_script.sh` described in Approach 1 below, or by interacting with the DataHub swagger API directly using Approach 2 below. NOTE: Analysis can be submitted to SCAIFE following (Step 3.)[Configuring the CI Server](#configuring-the-ci-server) from the CI Configuration section and substituting the necessary values.


##### Approach 1

* Modify the `sample_ci_script.sh` file provided in the `scaife/ui_server_stub/scale.app/demo/ci_demo/script` directory and replace the values for `TOKEN`, `TOOL_ID`, DataHub URL, and `git_commit_hash` with the values that have been gathered from previous steps.

Example modifications for the initial commit:

```
PKG_TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwYWNrYWdlX2lkIjoiNjEzYmExMDQ4ZjExYWY0Y2NkZTE3ZTkwIiwidXNlcm5hbWUiOiJSaG9uZGFCcm93biIsIm9yZ2FuaXphdGlvbl9pZCI6IjYxM2JhMGJjMTdlOGQ5MzNiYzI4NWNkNiIsInNlcnZlcl9rZXkiOiJkYXRhaHVia2V5IiwiY3JlYXRlZF9hdCI6MTYzMTI5Nzc5Nn0.sGVN4Fv7a-jPBK1eZhueo_xxnMSOYAMwm2o0rQSqoFI"

TOOL_ID="613ba0fc8f11af4ccde17da0"

DATAHUB_HOST="localhost"

SCAIFE_URL="http://${DATAHUB_HOST}:8084/analyze"

TOOL_OUTPUT="rosecheckers1.txt"
```

Set `DATAHUB_HOST` to `localhost` if running from host and `datahub` if running in Docker.

* Modify the `sample_ci_script.sh` file provided in the script directory and replace the values for `TOKEN`, `TOOL_ID`, DataHub URL, and `git_commit_hash` with the values that have been gathered from previous steps.

*Note: If using the provided Rosechecker tool output, make sure to replace the name of the `rosechecker.txt` file referenced in the script*

* Execute the script in a terminal to submit an analysis to the SCAIFE CI API.  The output from the Rosechecker's tool (e.g., `rosecheckers.txt`) should be in the same directory as the script, or adjust the filepath in the script accordingly.

Example:

`./sample_ci_script.sh b86a9920ab37c4d5ef3723003490025817ba76a5`


##### Approach 2

* Using a browser, navigate to the DataHub API Swagger URL. It will be similar to the following: `http://datahub_url:8084/ui` or `http://localhost:8084/ui/`. See Swagger Generated Server [README.md](../../../stats_server_stub/README.md) for more information about navigating to the datahub api Swagger URL.![](attachments/datahub-api1.png)
* Click on `/analyze` and then click `Try it out`.![](attachments/datahub-api2.png)
* Fill in the necessary values recorded in previous steps. For `x_access_token`, enter the package access token from when you created the project. Enter the `git_commit_hash`  commit hash generated in the initial commit, and `tool_id`. For `tool_output`, browse to the `rosechecker` output for the file upload field.![](attachments/datahub-api3.png)
* Click `Execute`, and view the results in the response.

Both approaches should produce the same result.

```
{
  "alerts_new": 162,
  "alerts_old": 0,
  "deletions": 0,
  "det_correlations": 0,
  "det_transfers": 0,
  "edits": 0,
  "meta_alerts_new": 50,
  "meta_alerts_old": 0
}
```

If you get a "Problem cloning from git repo" error, then DataHub has not authenticated with your git or BitBucket server.  In this case you will need to shut down SCAIFE and follow steps in "Prerequisites #3" subsection "(Configure the DataHub server to access the git repository)". Configure the DataHub server to access the git repository, start another instance of the SCAIFE system with `docker-compose -f docker-compose.yml up --build` and start the demo over again.


5. Replace the files in the source code repository with the files in the `replacement_files` folder provided in the ci_demo folder.

6. Commit, and push those changes.  Capture the git commit hash.

```
git add arr36-c-false-1.c arr36-c-true-1.c dcl31-c-true-1.c exp34-c-true-1.c
git commit -m "2nd version of code for demo without a CI server"
git push
```

7. Repeat Step 3 or use the `rosecheckers2.txt` output to capture static analysis results.  Capture the name of the Rosechecker tool output for the next step.

8. Repeat Step 4, using the new git commit hash and tool output.

9. Expected output:

```
{
  "alerts_new": 161,
  "alerts_old": 162,
  "deletions": 2,
  "det_correlations": 48,
  "det_transfers": 0,
  "edits": 5,
  "meta_alerts_new": 49,
  "meta_alerts_old": 50
}
```
##### Demo with Completely Automated Demo Script


### Introduction

There is an automated script in the DataHub container that will perform all necessary steps in any of the methods above which include the following:
  1. Creating a git repository local to the `datahub_url`
  2. Checking in the `dos2unix` test code with two revisions
  3. Creating a CI package configured to use the local repository, including uploading the `rosecheckers_oss` tool information to SCAIFE.
  4. Running both analyses with the required git commit hashes and respective `rosecheckers_oss` analysis outputs.
  5. Displaying the results.


Locate the automated script which can be found here, relative to the application directory inside the datahub docker container:
  ```
  ./scripts/ci_demo.py
  ```
In the host machine this corresponds to `scaife/datahub_server_stub/scripts/ci_demo.py`.

Get the SCAIFE `datahub` and `registration` docker containers up and running. Then launch the script in the container from the host machine:
  ```
  $ docker-compose exec datahub scripts/ci_demo.py
  ```
The script will prompt you to hit `<enter>` in between each step. First the local git repository in the DataHub container is created:
```
creating demo git repository

local git repository created.

The CI package creation will need the git url. The call to the datahub to
CI analyze will require the first git commit hash, second git commit
hash, and the two corresponding tool analysis outputs.

repo dir:        tmp/demo/demo_repo
old tool output: tmp/demo/rosecheckers_oss.old.txt
new tool output: tmp/demo/rosecheckers_oss.new.txt
old hash:        b2f4ef96337925bb8ce199e88ab40b833ca21811
new hash:        2d07c49ecef5d0e83610f87d3e2d7e2fd003f59d

Press <enter> to continue...
```
After pressing `<enter>` the script will create the CI-enabled demo package:

```
creating demo package

tool_name:        rosecheckers_oss
package name:     demo package/proj name 938180
tool id:          60dcb51c5b8b079280fa3f54
package CI token: eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwYWNrYWdlX2lkIjoiNjBkY2I2Mzk1YjhiMDc5MjgwZmE0MDRmIiwidXNlcm5hbWUiOiJ0ZXN0X3VzZXIiLCJvcmdhbml6YXRpb25faWQiOiI2MGRjYjQ4YzNlYTg5Yzk1MmE2ZDkzMjYiLCJzZXJ2ZXJfa2V5IjoiZGF0YWh1YmtleSIsImNyZWF0ZWRfYXQiOjE2MjUwNzczMDV9.r6k6c_2-edh25mQYYT-GGDD3ijXHjTwaGm5_TR7FK50

Demo package created and SCAIFE tool created/uploaded.

All the information required for making two calls to datahub CI
analyze is available now:
  - the package CI token
  - the tool ID
  - the two commit hashes
  - the two tool analysis outputs

Press <enter> to continue...
```
Now the script will run the first CI-triggered analysis, by calling the datahub with the package CI token and git commit hash corresponding to the first version of the test source code:
```
submitting initial analysis

initial analysis response:
{
    "alerts_new": 41,
    "alerts_old": 0,
    "deletions": 0,
    "det_correlations": 0,
    "det_transfers": 0,
    "edits": 0,
    "meta_alerts_new": 41,
    "meta_alerts_old": 0
}

There is not much to see on the initial analysis; all alerts and
meta-alerts were generated for the first time. There was therefore
nothing to cascade from an earlier analysis.

Press <enter> to continue...
```
Next, the script will call the analysis a second time, with the git commit hash for the second version of the test source code:

```
submitting second analysis

second analysis response:
{
    "alerts_new": 42,
    "alerts_old": 41,
    "deletions": 2,
    "det_correlations": 39,
    "det_transfers": 0,
    "edits": 7,
    "meta_alerts_new": 42,
    "meta_alerts_old": 41
}

The second analyis has now run. The cascade of alerts (and
adjudications/determinations had there been any) were carry forward to
all corresponding alerts in the new revision of the source code.

There has been a change in the number of alerts and meta-alerts between
the two versions of source code. This script did not make any
determinations/adjudications on the first version, but if it had, those
would have shown up in the 'det_transfers` total. As it stands,
determinations were transferred as-is for matching alerts since they
were identical.

Demo complete.
```

#### Conclusion

This concludes the SCAIFE CI Demo 'Without a CI' walkthrough.  The result is the same whether using a CI server or manually interacting with the SCAIFE CI API.
