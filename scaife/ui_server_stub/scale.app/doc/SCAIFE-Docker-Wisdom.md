
---
title: 'SCAIFE : Docker-Wisdom'
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

Docker Wisdom
=============

This page captures useful information about developing, testing, and inspecting contents of SCALe and SCAIFE Docker containers.

-   1 [General Docker Security and Efficiency](#general-docker-security-and-efficiency)
-   2 [SCAIFE container wisdom](#scaife-container-wisdom)
    -   2.1 [How to run and test SCAIFE containers](#how-to-run-and-test-scaife-containers)
        -   2.1.1 [To build and run a SCAIFE container:](#to-build-and-run-a-scaife-container)
            -   2.1.1.1 [Initializing a dependent container](#initializing-a-dependent-container)
            -   2.1.1.2 [Building and running containers](#building-and-running-containers)
        -   2.1.2 [To test a Swagger server](#to-test-a-swagger-server)
        -   2.1.3 [To test SCALe](#to-test-scale)
            -   2.1.3.1 [How to test script-based creation and use of SCALe projects in an independent
                container](#how-to-test-script-based-creation-and-use-of-scale-projects-in-an-independent-container)
            -   2.1.3.2 [SCALe SQLite database testing and examination](#scale-sqlite-database-testing-and-examination)
        -   2.1.4 [How to read log files in SCAIFE containers](#how-to-read-log-files-in-scaife-containers)
        -   2.1.5 [Volumes and SCAIFE containers](#volumes-and-scaife-containers)
        -   2.1.6 [Testing vs Production for containers including Selenium testing](#testing-vs-production-for-containers-including-selenium-testing)
        -   2.1.7 [List and Delete Images and Containers to Avoid Running out of Disk Space](#list-and-delete-images-and-containers-to-avoid-running-out-of-disk-space)
    -   2.2 [How to Refresh with SCAIFE Containers without Long Waits for Container Rebuilds](#how-to-refresh-with-scaife-containers-without-long-waits-for-container-rebuilds)
        -   2.2.1 [To refresh all independent containers](#to-refresh-all-independent-containers)
        -   2.2.2 [To refresh a single independent container](#to-refresh-a-single-independent-container)
        -   2.2.3 [To refresh a dependent SCALe container](#to-refresh-a-dependent-scale-container)
            -   2.2.3.1 [Details](#details)
        -   2.2.4 [To refresh ALL dependent containers](#to-refresh-all-dependent-containers)
        -   2.2.5 [To refresh a single dependent Swagger container without messing up any other containers](#to-refresh-a-single-dependent-swagger-container-without-messing-up-any-other-containers)
            -   2.2.5.1 [More details on how to refresh a single dependent swagger container](#more-details-on-how-to-refresh-a-single-dependent-swagger-container)
    -   2.3 [Managing servers](#managing-servers)
    -   2.4 [Troubleshooting](#troubleshooting)
-   3 [Summary Quick-Start for How to Test SCAIFE Code with and without Containers](#summary-quick-start-for-how-to-test-scaife-code-with-and-without-containers)
    -   3.1 [Without containers](#without-containers)
    -   3.2 [With containers](#with-containers)
-   4 [Building SCAIFE Virtual Machines](#building-scaife-virtual-machines)
-   5 [Starting and testing SCAIFE VMs for release and draft release VMs](#starting-and-testing-scaife-vms-for-release-and-draft-release-vms)

General Docker Security and Efficiency
======================================

These links are useful for security and efficiency issues with Docker:

-   [Production-ready Docker packaging](https://pythonspeed.com/docker/)
-   [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
-   [Docker Networking](https://docs.docker.com/compose/networking/)

SCAIFE container wisdom
=======================

How to run and test SCAIFE containers
---------------------------------------

For the following instructions set your `SERVER` and `PORT` environment
variables to one of the following:

  **SERVER**     **PORT**   **Mongo SERVER associated with column 1\'s swagger server**   **Mongo Server\'s PORT**   ** Redis Server\'s PORT**
  -------------- ---------- ------------------------------------------------------------- -------------------------- ---------------------------
  scale          8083
  datahub        8084       `mongodb_datahub`                                              28084                       28184
  priority       8085       `mongodb_priority`                                             28085
  stats          8086       `mongodb_stats`                                                28086
  registration   8087       `mongodb_registration`                                         28087

All containers also use a Pulsar container, and communicate with it via
Pulsar\'s ports 6065 and 8080.

You can test each server in the `scaife` directory.

### To build and run a SCAIFE container

First, you should set the following environment variable:\
`export COMPOSE_PROJECT_NAME=scaife`
which makes the network used by the SCAIFE containers `scaife-default`.

You should choose one of two approaches:

1.  **Dependent**: Run a container that shares the source filesystem
    with the host. This is useful for quickly developing code in the
    host and then running it in the container. However, the container\'s
    behavior can be erratic if there are unexpected files in your host
    filesystem\'s source tree.

2.  **Independent**: Run a container that shares no files with the host.
    This is useful for testing that the container (and all software in
    it) is valid.

If you also run the server on the host, we recommend you use an
*independent* container (option 2). Having both the host and container
run a server can create dependency problems when the host and container
each expect files to be tailored just for it. If you want to run code
both inside and outside a container, we recommend you keep two copies of
the code, one for building a dependent container, and one for running on
your host.

If you pass `--no-cache` to the `docker build` command, it will ignore
any cached image and rebuild the container from scratch. This results
in a much slower build. However, relying on the cache can cause
intermediate images to become obsolete, as new software packages can
appear in the apt repositories (or pip or rubygems or...). Therefore,
we recommend that you rebuild your containers from scratch every two
weeks.

#### Initializing a dependent container

If you want to share the host\'s source filesystem with a dependent
container, you\'ll want to make sure that the files in your host\'s
filesystem are suitably initialized for your container. **IN SOME CASES
ONLY (read below), **you can use the following command to make sure your
host files are suitably initialized:

**NOTE: Before using a SCALe dependent container for the
[first]{.underline} time, you must use the following command! Before
using the other dependent containers for the *first* time, you
do *not* need to initialize the container with the following command.**

**Command to \"initialize\" dependent container (note major
\"initialization\" differences between swagger servers and SCALe)**

`docker-compose run \${SERVER} ./init.sh`

For Swagger containers, the above command only partially initializes the
files and does not reset the database.

-   The partial initialization does not remove previously deposited
    files created by a previous run of the server (doing that requires
    separately running `scaife/clean.sh` ). To update a swagger server\'s
    python package for python 3 and python35 environment for tox tests,
    you must run tox and run `pip install -r requirements.txt` and `pip
    install -r test-requirements.txt`. Note that the swagger `init.sh`
    script does not run the install with the `test-requirements.txt` file,
    only the install with `requirements.txt`.
-   The databases for swagger servers are not reset because their data
    is stored in separate Mongo containers, and are technically not part
    of the host filesystem. To reset their database, restart the
    appropriate Mongo server:

**Command to reset Swagger dependent container\'s database**

`docker-compose restart mongodb_${SERVER}`

In contrast, SCALe\'s `init.sh` does reset its database, because it is
stored in the host filesystem.

#### Building and running containers

This command builds and runs a SCAIFE container, and shares the source
with the host. This is suitable for development, as you can develop the
code on the host and run it in the container without rebuilding the
container:

**Command to build and run a dependent container**

`docker-compose up ${SERVER}`

You can run any subset of servers by passing them to the `docker-compose
up` command. Passing no servers means it runs all SCAIFE servers.

You can pass the following arguments to docker-compose up :

+-----------------------------------+-----------------------------------+
| **Argument**                      | **Function**                      |
+===================================+===================================+
|`--build`                          | Re-build the container if source  |
|                                   | files have been updated.          |
+-----------------------------------+-----------------------------------+
|`-d`                               | Run containers in background,     |
|                                   | suppressing their output          |
+-----------------------------------+-----------------------------------+
|`-f docker-compose.yml`            | Run independent containers        |
|                                   | (don\'t share volume with host)   |
|                                   |                                   |
|                                   | Usually, both `docker-compose.yml`|
|                                   | and `docker-compose.override.yml` |
|                                   | are used if they exist. Passing   |
|                                   | this argument means that only     |
|                                   | `docker-compose.yml` will be used |
|                                   | even if                           |
|                                   | `docker-compose.override.yml`     |
|                                   | exists. The volume definitions    |
|                                   | that make SCAIFE\'s containers be |
|                                   | dependent are all in              |
|                                   | `docker-compose.override.yml`, so |
|                                   | not using it results in           |
|                                   | independent containers.           |
+-----------------------------------+-----------------------------------+

NOTE: Order of arguments matter. A common command useful for testing
pull requests (PRs) is:

**Build and run independent container, for local PR testing**

`docker-compose -f docker-compose.yml up \--build`

For example, the command `docker-compose up -d` runs all containers in
the background. It is equivalent to the following code:

**Shell script to build and run containers**
```
for SERVER in registration priority datahub stats; do
docker-compose up -d \${SERVER}
done
docker-compose up -d scale
```

If you run SCAIFE and no other containers, than a docker image ls 
command should produce output much like this:

```
**SCAIFE Docker Images**
REPOSITORY TAG IMAGE ID CREATED SIZE
scaife_research_lsi/scaife.scale scaife f283389b947d 4 days ago 1.62GB
scaife_research_lsi/scaife.registration scaife 72e3eaf81d11 6 days ago
477MB
scaife_research_lsi/scaife.stats scaife 12c7ba296f69 6 days ago 1.63GB
scaife_research_lsi/scaife.priority scaife 1eee544948ba 6 days ago
387MB
scaife_research_lsi/scaife.datahub scaife 309bc9775bdd 6 days ago
703MB
mongo latest bcef5fd2979d 3 weeks ago 386MB
ubuntu bionic 72300a873c2c 3 weeks ago 64.2MB
```
To take down containers, use docker-compose down .

Note: If your host machine is running a

### To test a Swagger server

**NOTE** : *See the next section for testing SCALe\...these notes only
apply to the Swagger servers*.

To verify that a Swagger server is running, from another terminal: (This
assumes you are on the same network as the server.)

**Command to test that swagger server is running**

`wget -q -O - localhost:${PORT}/status --header="x_request_token:deadbeef"

This command should produce:
```
{
"message": "${SERVER} Server is Running Properly",
"request_id": "deadbeat"
}
```
**Running containers in Test Mode**

Test mode adds some data and settings to containers and databases that are used by automated tests.
To start all servers in test mode, use the `docker-compose.test.yml` file as part of the
`docker-compose` command. For instance, a test mode startup command example is the following (which also shares
volumes, to speed up subsequent tests):
`docker-compose -f docker-compose.yml -f docker-compose.m2.yml -f docker-compose.test.yml up --build`


Each Swagger server has some tox  regression tests. These command will
test each Swagger server (except for stats). The tests can be run while
the production servers are still running:

**Command to run regression tests on an independent Swagger container**

```
docker-compose -f docker-compose.yml run registration tox
docker-compose -f docker-compose.yml run priority tox
docker-compose -f docker-compose.yml run datahub tox
```
The Stats server is more complicated. To run its tox tests, you need to
take down both stats and datahub servers. Then these commands will test
Stats:

**Command to run regression tests with independent Swagger containers and DataHub in Test Mode**
```
docker-compose -f docker-compose.yml -f docker-compose.test.yml up -d
datahub
docker-compose -f docker-compose.yml up -d stats
docker exec stats ./wait_for_pulsar.sh pulsar
docker exec stats tox
```
The test fails if and only if you see ERROR or FAIL: Examples:
```
Test case for get_projects ... ok
Test case for upload_codebase_for_package ... FAIL
```
You can also test a currently-running independent swagger container with
this command (WARNING: this will leave test files and entries in the
database! ALSO, since it doesn\'t start the DataHub in test mode, some
of the Stats tox tests will fail (integration tests for the DH that
require the DH to be in test mode)):

**Command to run tox tests on an independent Swagger container (WARNING:
will leave test data files and database changes!)**

Performance Measurements
--------------------------
To record performance measurements when running SCAIFE, start the Stats Module server using the "--experiment" flag followed by "y" or "n".  By default, performance measurements are automatically collected when SCAIFE is run in test mode.

To calculate and display performance measurements, run "python swagger_server/controllers/performance_measurements.py" from the stats_server_stub directory.  If trying to access performance measurements after running SCAIFE in test mode, add the "--mode" flag followed by "test" (i.e., "python swagger_server/controllers/performance_measurements.py --mode test")

```
# Access a bash command line on the container ${SERVER} (e.g., datahub)
you specify
docker exec -it ${SERVER} /bin/bash
# docker exec -it datahub /bin/bash
# Line below runs the tox tests
tox -r
```

**Mongo Test and Database Inspection/Manipulation**

Each swagger server comes with an assistant Mongo server. To access the
Mongo server, you can use this command (note PORT below refers to the
PORT for the swagger server not the mongo server\'s PORT) :

The following command works for accessing the mongo stats db via normal
terminal \"mongo\" command. Then, using the database and dropping the
database (or performing similar but different mongo commands):

**Commands to connect to a SCAIFE Mongo server then delete its
contents**

`docker run -it --network scaife_default --rm mongo mongo --host mongodb_stats --port 28086 test`
```
\> use stats\_db
\> db.dropDatabase()
\> quit()
```

The command below is generic for any mongo server:

**Command to connect to a SCAIFE Mongo server**

`docker exec -it mongodb_${SERVER} mongo --port 2${PORT} test`

or if you prefer to run Bash on the Mongo server:

**Command to connect to a SCAIFE Mongo server**

`docker exec -it mongodb_${SERVER} sh`

### To test SCALe

Once SCALe is running, you can test it quickly using the following
command. Here you must replace `${PASSWORD}` with the SCALe web app
password:

**Command to test that SCALe is running**

`wget --user=scale --password="${PASSWORD}" localhost:8083`

SCALe has several test scripts in its `scale.app/bin` directory. To run
the Python tests, use this command:

**Command to run a test in a SCALe container**

`docker-compose run scale ./bin/test-python`

You can replace `test-python` with any other SCALe test script to do
other tests.

This command runs Selenium on all tests:

**Command to run all Selenium tests**

`docker run -it --rm -v=${HOME}/.m2:/home/scale/.m2 --name scale
scaife_research_lsi/scaife.scale:scaife ./bin/test-selenium`

The `-v` option allows the container to access the `.m2` directory which
links the container\'s Maven settings to the hosts. If you can run Maven
on the host (regardless of whatever proxy you might be behind), then
Maven should work in the container.  The container must be able to read
and write to the `.m2` directory, so you may need to tweak its
permissions.

This command runs Selenium on an individual test:

**Command to run one Selenium test**

`docker run -it --rm -v=${HOME}/.m2:/home/scale/.m2 --name scale scaife_research_lsi/scaife.scale:scaife bin/test-selenium -Dtest={TestClass}#{testMethod}`

For example, the TarGZ uploading facility is a nice simple test, and
this command would be:

**Command to run the simplest Selenium test**

`docker run -it --rm -v=${HOME}/.m2:/home/scale/.m2 --name scale scaife_research_lsi/scaife.scale:scaife bin/test-selenium -Dtest=TestWebAppCoreScenariosRemote#testAlertsPresentTarGz`

This same command works in `docker-compose`, but not with volume sharing
(that is, it will re-download Maven dependencies):

**Using docker-compose to run a Selenium test**

`docker-compose run scale bin/test-selenium -Dtest=TestWebAppCoreScenariosRemote#testAlertsPresentTarGz`

#### How to test script-based creation and use of SCALe projects in an independent container

**Using docker-compose to test script-based creation of SCALe projects
and use of them in an independent container**

```
docker exec scale python scripts/automation/create_basic_project.py
docker exec scale python scripts/automation/create_manual_test_project.1.rosecheckers.py
docker exec scale python scripts/automation/create_manual_test_project.1.microjuliet.py
```

#### SCALe SQLite database testing and examination

The following commands works for accessing SCALe sqlite3 databases in an
independent container (`scale.app/archive/*/external.db` and
`scale.app/db/development.sqlite3`) via normal terminal `sqlite3`
command. Then, using the database and running some commands with it:

**Commands to connect to SCALe in an independent container, access one
of its sqlite3 databases, then execute sqlite3 commands**

```
# if SCALe is not running, start it
cd scaife
docker-compose -f docker-compose.yml up scale
# Access SCALe
docker exec -it scale /bin/bash
# Inside container
sqlite3 db/development.sqlite
# Next, commands within the sqlite3 command environment (commandline starts with ">")
# List all tables
> .tables
# Show everything from the 'projects' table
> select * from projects;
> .quit
# Commented-out line below would
# echo .dump | sqlite3 db/development.sqlite
exit
```

To access the sqlite3 databases within a dependent SCALe container, just
run `sqlite3 <LOCAL_SQLITE3_DATABASE_PATH>` from your command line of
your local machine.

### How to read log files in SCAIFE containers

You can access the log of a swagger server\'s associated Mongo container
with:

**Command to obtain a SCAIFE Mongodb log**

`docker logs mongodb_${SERVER}`

Here are some useful log files:

  **Container**   **Path**                     **Purpose**
  --------------- ---------------------------- -------------
  SCALe           /scale/log/development.log   Rails log

If `${CONTAINER}` is your container\'s name (specified above via the
`--name` flag, and a value you see listed if you run the command
**docker container ls**), and `${LOG}` is the path of a log file in a
container, you can copy the log file from container to host with this
command:

**Command to access SCAIFE log files**

`docker cp ${CONTAINER}:${LOG} .`

You could also watch new output to the log file, without copying it,
with this command:

**Command to monitor log files in containers**

`docker exec -it ${CONTAINER} tail -f ${LOG}`

### Volumes and SCAIFE containers

When running a Docker container, you can use the `-v` (or `--volume`)
option to share folders between the host and container. The syntax is `-v
\<host-path\>:\<container-path\>:\<options\>`. You can use volume mounts
to make persistent files used by your container. For example, you can
mount volumes on the log directories in order to make the logs persist
across containers, because they will actually live on the host file
system. Here are some other paths you can share:

  **Container**   **Path**              **Purpose**
  --------------- --------------------- --------------------------------------------
  SCALe           `/scale/db`           Internal SCALe database
  SCALe           `/scale/public/GNU`  Project-specific HTML pages
  SCALe           `/scale/test-output` Output of tests (including Selenium tests)

### Testing vs Production for containers including Selenium testing

The SCALe `Dockerfile` can be built for a production-ready SCALe, or a
SCALe server suitable for testing and development. The test/development
SCALe has extra packages, including pytest, selenium, Firefox, and Java,
that are required by the test scripts; otherwise the two versions of the
SCALe server are identical.

By default, the `Dockerfile` will build for testing. For a production
build, specify `--build-arg PRODUCTION=1` when calling `docker build`.

### List and Delete Images and Containers to Avoid Running out of Disk Space

Some convenient commands for listing and deleting images and containers
follow:

-   Cleanup dangling images and containers: **docker system prune**
-   Remove all stopped containers, dangling images, and intermediate
    images: **docker system prune -a**
    -   *WARNING: If you have any images you want to preserve, make sure
        they\'re used by a **running** container when you run this! 
        This command will require that all other images must be rebuilt.
        This takes 20 minutes for SCALe and \~10 minutes for each
        Swagger container.*
-   Remove list of named images (where each
    variable **`${IMAGE<INTEGER>}`**is supposed to contain the string
    for the container image name): **`docker rmi ${IMAGE1} ${IMAGE2}
    ...`**
-   Remove all volumes (created by dependent containers): **docker
    volume prune **
-   List all docker images: **docker image ls**
-   List all docker containers: **docker container ls**

How to Refresh with SCAIFE Containers without Long Waits for Container Rebuilds
--------------------------------------------------------------------------------

**\"Refresh\" Constraint**: When we speak of refreshing a component
here, we mean that the container should only contain files, directories,
and database entries that it would contain if it was a new-fully-built
container. (including updated SCALe/SCAIFE HTML manual) The container
should also use the same code as the host. 

+-------------+-------------+-------------+-------------+-------------+
|**Component**|**Independent|**Independent| **Dependent | **Dependent |
|             | Container,**| Container,**|Container,** |Container,** |
|             |             |             | **Where     | **Command   |
|             | **Where     | **Command   | Component   | to Refresh  |
|             | Component   | to Refresh  | Lives**     | Component** |
|             | Lives**     | Component** |             |             |
+=============+=============+=============+=============+=============+
| Data        | Container   |docker-compos| Host        | ./clean.sh  |
|             |             |e down       |             |             |
|             |             |docker-compos|             |             |
|             |             |e -f docker-c|             |             |
|             |             |ompose.yml up|             |             |
+-------------+-------------+-------------+-------------+-------------+
|Initial Data | Container   |docker-compos| Host        | ./clean.sh  |
|             |             |e down       |             |             |
|             |             | docker-compo|             |             |
|             |             |se -f docker-|             |docker-compos|
|             |             |comp ose.yml |             |e run scale  |
|             |             | up \--build |             |             |
|             |             |             |             | init.sh     |
|             |             |             |             |             |
+-------------+-------------+-------------+-------------+-------------+
| Code        | Container   | docker-comp | Host &      | *Restart    |
|             |             | ose down    |             | servers     |
|             |             |             | Container   | without res |
|             |             |             |             | tarting     |
|             |             | docker-comp |             | containers* |
|             |             | ose -f      |             | **OR**      |
|             |             | docker-comp |             |             |
|             |             | ose.yml up  |             | docker-comp |
|             |             | \--build    |             | ose         |
|             |             |             |             | down        |
|             |             |             |             |             |
|             |             |             |             | docker-comp |
|             |             |             |             | ose         |
|             |             |             |             | up          |
+-------------+-------------+-------------+-------------+-------------+
| External    | Container   | docker-compo| Container   | docker-compo|
| Dependencies|             |se down      |             |se down      |
|             |             |             |             |             |
|             |             | docker-compo|             | docker-comp |
|             |             |se -f docker-|             | ose         |
|             |             |compose.yml u|             | up \--build |
|             |             |p \--build   |             |             |
+-------------+-------------+-------------+-------------+-------------+

**Also, refer to separate section \"[Managing
servers](https://wiki.cc.cert.org/confluence/display/SC/Docker+Wisdom#managing-servers)\"**
which provides a fast restart (refresh) method for all containers
together **(but only if steps are run together, per the bold-font
warnings).**

**Note: **Do not refresh a running container (first, stop it
with `docker-compose stop ${SERVER}` )

### To refresh all independent containers

The following applies to SCALe containers and swagger containers.
Just delete and re-create all 5 refreshed containers, using these
commands:

SPEEDUP TIP: If the code hasn\'t changed at all and you only want to
clean up the filesystem and database, then leave off the `--build`
parameter.

**Commands to refresh all 5 SCAIFE containers**

```
docker-compose down
docker-compose -f docker-compose.yml up --build
```

### To refresh a single independent container

The following applies to SCALe containers and swagger containers.
Just delete & re-create the refreshed container, using these commands:

Note that you have to rebuild an independent container after *every*
code change, with the \"--build\" parameter.

SPEEDUP TIP: If the code hasn\'t changed at all and you only want to
clean up the filesystem and database, then leave off the `--build`
parameter.

**Commands to refresh a single SCAIFE independent container (SCALe or
swagger)**

```
docker-compose stop ${SERVER}
docker-compose rm ${SERVER}
docker-compose -f docker-compose.yml up ${SERVER}
```

Even faster, **if there have been no code changes** and you
only need to clean the filesystem and databases in SCALe:

Note that the following set of commands resets the filesystem by
deleting the old container. The `docker-compose` `...up` part of the
command creates a new container with virgin filesystem whether or not
you use a `--build` parameter, but if you use a `--build` parameter
then it will take a long time to rebuild the container. That\'s why the
second command below does not use a \"--build\" parameter.

**Commands to clean databases and filesystem in SCALe**
```
docker-compose stop scale
docker-compose rm scale
docker-compose -f docker-compose.yml up scale
```
### To refresh a dependent SCALe container

**Commands to refresh a dependent SCALe container**
```
docker-compose stop ${SERVER}
cd scaife/ui_server_stub/scale.app
./clean.sh
cd ../..
docker-compose run ${SERVER} ./init.sh
docker-compose up ${SERVER}
```
#### Details

For SCALe, running the init.sh script does the following:

-   Initializes the SCALe database
-   Rebuilds the SCALe/SCAIFE HTML manual
-   Adds bundled Ruby gems

### To refresh ALL dependent containers

(Do not run alone, as this would mess up any running SCAIFE system
where the SCALe container state (DBs, files) was supposed to have stayed
the same, plus will remove everything in the .tox directories of ALL of
the 4 swagger containers, which will mess up the other 3 swagger server
containers)

**Command to \"initialize\" dependent container (note major
\"initialization\" differences between swagger servers and SCALe)**
```
cd scaife
docker-compose stop
./clean.sh
for SERVER in registration priority datahub stats scale; do
# This cleans all Swagger containers and SCALe too
docker-compose run ${SERVER} ./init.sh
```
### To refresh a single dependent Swagger container without messing up any other containers

**Command to \"initialize\" dependent container (note major
\"initialization\" differences between swagger servers and SCALe)**

```
docker-compose stop ${SERVER}
# Go to the directory for this particular swagger server
cd scaife/<SWAGGER_SERVER_DIRECTORY>
# This cleans the single swagger container filesystem (not databases)
rm -rf .tox;
find . -name \*.pyc -exec rm -rf {} \\;
# Related to this fix, the following are some datahub-specific cleanup commands.
# If the directories don't exist (i.e., if not on the datahub) that doesn't hurt anything
echo "datahub-specific files"
rm -rf swagger_server/uploaded_files/*
cp swagger_server/test/test_output/README.md ./README.md.backup
rm -rf swagger_server/test/test_output/*
mv ./README.md.backup swagger_server/test/test_output/README.md
# Second, make fresh installs of python packages as required by the "requirements.txt" file
./init.sh
docker-compose run ${SERVER} ./init.sh
```

-   Then do a `pip install` of `test-requirements.txt` (TODO: provide more
    info)

#### More details on how to refresh a single dependent swagger container

The DataHub has filesystem changes due to SCAIFE depositing
project/package files, but all swagger servers can have python package
filesystem files deposited.

For Swagger containers, the `./init.sh` command only partially initializes
the filesystem and does not reset the database.

-   The partial initialization does not remove previously deposited
    files from running the server (doing that requires separately
    running `scaife/clean.sh` ). To update the swagger server\'s python
    package for python 3 and python35 environment for tox tests, you
    must run `tox` and run `pip install -r requirements.txt` and `pip install
    -r test-requirements.txt`. Note that the swagger init.sh script does
    not run the install with the `test-requirements.txt` file, only the
    install with `requirements.txt`.
-   The databases for swagger servers are not reset by a script within
    the swagger server\'s container because their data is stored in
    separate Mongo containers, and are technically not part of the host
    filesystem.
-   To reset a swagger server\'s database, restart the appropriate Mongo
    server:

**Command to reset Swagger dependent container\'s database**

`docker-compose restart mongodb_${SERVER}`

Managing servers
----------------

Here are the fastest ways to restart the swagger servers, for dependent
containers. These should all be done in the scaife directory:

1.  To run SCAIFE with dependent containers:
    `docker-compose up`
2.  To pause SCAIFE, without resetting any data:
    `docker-compose stop`
3.  To resume SCAIFE from a pause:
    `docker-compose start`
4.  To stop SCAIFE. Erases Mongo databases, but retains all other info:
`docker-compose down`

    -   **WARNING 1** : **IF ANY PREVIOUS FILES WERE ADDED TO THE
        FILESYSTEM** (E.G., IF SCAIFE PROJECT/PACKAGE FILES  SUCH AS
        CODEBASE TARBALL, FUNCTION/FILE METADATA FILES, TEST SUITE
        MANIFEST, ETC. HAD BEEN UPLOADED to the DataHub), **THIS
        [alone]{.underline} (**UNLESS \#5 BELOW IS RUN
        AFTERWARDS**) WILL MAKE THAT SWAGGER CONTAINER\'s FILESYSTEM
        INCONSISTENT** with the reset database.)
    -   **WARNING 2:** **THIS [alone]{.underline}  (**UNLESS \#5 BELOW
        IS RUN AFTERWARDS**) WILL LEAVE ANY SCALE** (SCAIFE UI MODULE)
        **DATABASE THAT HAS PREVIOUSLY INTERACTED WITH THE SWAGGER
        SCAIFE CONTAINERS [INCONSISTENT]{.underline} WITH THE SWAGGER
        SCAIFE CONTAINERS** with reset databases.

5. Remove data left over by dependent containers (non-swagger SCALe
container DBs and filesystem, plus ONLY filesystem from the swagger
containers **but NOT swagger databases**) **and then only start the
SCALe container:**

-   **NOTE: performing the following addresses both warnings 1 and 2
    above**
-   **WARNING: THIS [alone]{.underline} (**UNLESS RUN AFTER \#4 ABOVE**)
    WILL LEAVE SWAGGER DATABASES WITH DATA THAT IS INCONSISTENT WITH ANY
    SCALE DATABASE IF THAT SCALE CONTAINER HAS UPLOADED ANYTHING (E.G.,
    REGISTRATION INFORMATION, PROJECT, PACKAGE, TOOL, LANGUAGE,
    TAXONOMY, ETC) TO A SWAGGER SERVER (ALSO IF ANY SUCH DATA HAS BEEN
    PASSED BETWEEN SWAGGER SERVERS).**

```
> ./clean.sh\
> docker-compose run scale ./init.sh
```

Troubleshooting
---------------

-   Be sure your containers are on the same network. You can get this
    info from `docker inspect ${CONTAINER}`
-   Listing networks (`docker network ls`) can inform you if there are
    unwanted networks.
-   Also be sure to examine your containers\' logfiles (use `tail -f` to
    follow them as stuff happens) to see if they are behaving properly.
-   If you share your host\'s folders with the container, you might have
    trouble (re)building the container. This occurs because the
    container might leave `.pyc` files owned by root in your host
    directory, which Docker cannot actually read, so it will give you
    permission errors. This can be fixed by removing `.pyc` files:
```
> sudo find . -name \\\*.pyc -exec rm -rf {} \\;
```
-   If you tested with dependent containers (the default), the .tox
    directories (\'invisible\' because they start with a dot) will
    contain files that have root privileges that must be removed before
    you can run tox tests on your host machine (outside the container)
    with normal user privileges. You will need to remove that directory
    and all files in it, using root privileges. E.g., within
    `$scaife/scaife/<MODULENAME\>_server_stub` directory, run the
    following command in your terminal:
```
> sudo rm -rf .tox
```
-   Pulsar is the most memory-hungry container. It can easily die from
    lack-of-memory. To run a simple classifier on dos2unix, Pulsar
    uses 1.1 GB of memory, and will crash with "error 137" if this
    memory is not available.  Docker on Mac defaults to 2 GB of
    memory, but this can (and should) be upgraded. To do this, select
    Docker->Preferences->Resources.

Summary: Quick-Start for How to Test SCAIFE Code with and without Containers
============================================================================

Without containers
------------------

Make sure that `/etc/hosts` specifies the correct IP address for `localhost`
(e.g., `127.0.0.1` on IPv4, or `::1` on IPv6). We\'ve used `localhost`
below, as the right thing should happen whether a machine is IPv4-only,
dual-stack, or IPv6-only.

Edit the following 4 files to specify the correct host and port :

-   4 `servers.conf` files
    at `scaife/<MODULE_NAME>_server_stub/swagger_server/servers.conf`
    -   You likely only need to change the `host`, not port for the
        `<MODULE_NAME>_DEFAULT` sections.
        -   `host: localhost`
    -   Correct host and port for `db_host`, `STATS_DATABASE` and
        `DH_DATABASE`, likely to be the `mongod` default:
        -   `host: localhost`
        -   `port: 27017`
    -   Correct host and port for `redis_host`, likely to be the
        redis-server default:
        -   `host: localhost`
        -   `port: 6379`
-   1 `scale.app` file:
    -   `scale.app/config/scaife_server.yml`
        -   In the section development and/or test(if you\'re running
            the SCALe tests) edit the file so each of the 4 hosts (after
            the apostrophe and right before the \":\" then port) instead
            is localhost.
            -   e.g., datahub: `localhost:8084`

I strongly recommend that if you are going to test both with and without
containers, that you store 2 versions of each file starting with
different prefixes as follows: `bak.single.<NORMAL_FILENAME>` and
`bak.container.<NORMAL_FILENAME>` (e.g., `bak.single.db.conf` and
`bak.container.db.conf`). That way, you can just copy the appropriate
`bak.` file over, to switch between with and without containers.

Before testing, delete previous data and start servers as you did
previously, before we started using containers (e.g., run
**(1)** `${SCALE_HOME}/scale.app/remake_db.sh` and
**(2)** `$scaife/scaife/helpers/restartServers_afterDropDBsExceptReg.sh`
)

With containers
---------------

Use the code in the repositories as-is.

You will need to edit the 5 files listed above (or some subset,
depending on what type of tests you will do, i.e., manual and/or
automated) if you previously modified them for testing without
containers.

Then start each of the 5 containers as follows in a different terminal,
so you can view the terminal output, with the following command:

**Correct arg order in common command to build and run container, for
local testing of PRs**

`docker-compose -f docker-compose.yml up --build`

(TODO: test using the option `--parallel` with the above command, to
take advantage of multiple cores/virtual cores for faster builds.)

Testing: After each of the 5 containers has built, run tests as
specified in the above test section. If all works as it should, you
should be able to startup your machine\'s browser (Firefox works) and
access SCALe at the usual location
([http://localhost:8083/](http://127.0.0.1:8083/)), then login to
SCAIFE.

NOTE: If you want to empty the databases or remove files from previous
runs of the containers, see the scripts
`clean.sh` and `remake.sh` mentioned in [SCAIFE Server Management](SCAIFE-Server-Management.md).
Alternately, you can stop the containers, then:

1.  For SCALe: in your `${SCALE_HOME}/scale.app` directory, run
    `./remake_db.sh` and wait until *after* the terminal output says
    the server has started. Then stop the server (`control-C`).
2.  For the swagger servers: stop the containers (swagger and mongo) and
    delete them, then rebuild them. This doesn\'t 100% remove
    everything, though.

Building SCAIFE Virtual Machines
================================

In the `scaife` folder, you can use vagrant up to create a virtual
machine. The first time it comes up, it will provision the machine (eg
load SCAIFE and build the containers). This took 45 minutes on my
machine and used \~10GB.

You can use `vagrant ssh` to connect to the VM via a terminal, or you can
use Virtualbox\'s window. You can then start or stop the containers
manually.

Starting and testing SCAIFE VMs for release (and draft release VMs)
===================================================================

Within SEI, we create pre-release SCAIFE virtual machines and place them in a location (specified on our internal wiki) for our team to download to inspect.


Versions one of our team uses to create SCAIFE VMs: **Vagrant 2.2.3** combined
with **VirtualBox 5.2.24**

When the containers are running, you can point a web browser in your VM
*or* your host to localhost:8083  to access SCALe, and SCAIFE through
SCALe.

Inside the VM\'s `~/Desktop/scaife` directory, you can use
use `docker-compose up` and `docker-compose down` to start or stop the
SCAIFE containers.

When rebooting the machine, the containers do not start running
automatically. We recommend you open a terminal and start the containers
manually in the terminal.

The Swagger servers and SCALe share their source code with the host
filesystem, but the Mongo servers do not. This means that if you destroy
and re-create the Mongo containers, you lose whatever project data they
had. But data in the Swagger containers and SCALe is preserved, because
it lives in the host machine\'s filesystem.

TODO: How to reset the source of the Swagger servers? Are there scripts
to do this, or do the Swagger servers not store any info locally?
We have developed some scripts (including clean.sh) and
user instructions in the SCAIFE HTML manual pages about how to do that.

**[Draft VM tester instructions:]{.underline}**


        1.  create dos2unix or microJuliet project, and adjudicate 10 meta-alerts true and 10 meta-alerts false
        2.  register then login to SCAIFE, create a classifier, run it, and view the confidence fields populated in the alertConditions list
        3.  Stop containers
        4.  Make slight modification to code (not enough to require additional
            3rd-party package downloads)
        5.  Restart containers
        6.  check if expected data from before restarted containers
            there
        7.  Make sure you can repeat steps 1 and 2
        8.  Try creating new project
        9.  [Advanced testing (**not everyone has to**)]{.underline}
            a.  slight edit to SCALe/SCAIFE .md manual that will show in the HTML
            b.  rebuild SCALe/SCAIFE manual (in scale.app, run: scripts/builddocs.sh )
            c.  look at the rebuilt SCALe/SCAIFE HTML manual (look for your
                edit)
            d.  slight mod to one of the swagger module\'s
                \"swagger.yaml\" files
            e.  use scripts to generate corrected HTML, JSON, and YAML
                files from modified swagger.yaml
            f.  look at new exports, look for edit made (slight mod from
                above bullet)


Using SCAIFE in Experiment Mode
===============================

See the [SCAIFE Experiment Mode documentation](SCAIFE-Experiment-Mode.md) for more information.

------------------------------------------------------------------------
