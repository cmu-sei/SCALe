---
title: 'SCALe : Source Code Analysis Lab (SCALe)'
---
[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md)
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

SCALe : Migrating All SCALe Projects to Later SCALe Versions
=========================================

How to Migrate SCALe Projects, Plus Starting Containers to Enable Migration
---------------------------------------


This page contains instructions about how to migrate SCALe projects, plus how to start SCALe containers the right way to begin with so that the projects can be migrated. 

If you don't start SCALe or SCAIFE containers with them sharing the right set of volumes, then it's more difficult to copy the data you want outside of the container(s). It's best to start with the right volume-sharing, prior to any SCALe project creation. However, your data isn't lost if you didn't start with volume-sharing: In that case, see section [Method to Use to Copy Migration Files and Directories if the Container is not Volume Sharing Them](#method-to-use-to-copy-migration-files-and-directories-if-the-container-is-not-volume-sharing-them)

This document also describes how the projects can be backed up. People who use SCALe to analyze projects need to copy that project data outside of SCALe containers, to be able to report on their work. That important data should be backed up (outside of the container) regularly, to reduce risk of data loss. 


### Docker Container Volume-Sharing to Enable Backups and Migrations

To perform the following migration steps for a container, you need to be able to copy files and directories from the container to outside of the container. That requires that you run the container in a way that it "shares a volume" between the container and the host machine filesystem. You should copy files and directories in step 3 from the shared volume directory to a separate (not-shared) host machine directory "migration-files". 

When running a Docker container, you should use the `-v` (or `--volume`) option to share folders between the host and container. The syntax is `-v \<host-path\>:\<container-path\>:\<options\>`. You can use volume mounts to make persistent files used by your container. Here is more Docker documentation about this: https://docs.docker.com/storage/bind-mounts/


### If You Will Develop SCALe and Need to Backup and/or Migrate SCALe Project(s) 

You may want to do some SCALe development, which may include minor tweaking of scripts or may involve major addition of new features, or even just editing the documentation to provide clarification. Contributions back to SEI of any of your bugfixes, features, and documentation improvements are very welcome!

If you will develop SCALe and need to backup and/or migrate SCALe project(s) to new SCALe versions, you should do more volume-sharing than users who don't develop SCALe. 


#### Start SCALe as a "Dependent" Container (Volumes Share a Lot)

See [SCAIFE-Docker-Wisdom.md](SCAIFE-Docker-Wisdom.md) for information about how to start and use "Dependent" Containers.

This method of startup modifies files on the host machine, so it might not be an acceptable mode to run in, in some environments. It shares some directories including the following (as can be seen in `scaife/docker-compose.override.yml`):

a. `${HOME}/.m2:/home/scale/.m2`
b. `${HOME}/.cache/pip:/home/scale/.cache/pip`
c. `./ui_server_stub/scale.app:/scale.app`


#### Sharing a Lot, but Less Than "Dependent" Containers (Volume-Sharing Starting from `/scale.app`)

You can share the volume of the entire container's directory starting from `/scale.app` (but not the other two directories shared by "dependent" SCALe containers), by starting SCALe as follows and substituting your own path for `SCALE_MIGRATE`:

```
export SCALE_MIGRATE=/home/lflynn/migration/20210403
docker run -it -v=${SCALE_MIGRATE}/scale.app:/scale.app scale /bin/bash
```

### Docker Container Volume-Sharing to Enable Backups and Migrations, but NO development of SCALe code/documentation

If you are running SCALe to analyze one or more codebases but know you will not develop SCALe (nor modify any of its documentation), then you should start your Docker container sharing the following files and directories only. These will allow you to backup your projects and migrate them, but reduce the possibility of accidentally deleting or modifying code. Substitute your own path for `SCALE_MIGRATE`:

```
export SCALE_MIGRATE=/home/lflynn/migration/20210403
docker run -it -v=${SCALE_MIGRATE}/db/development.sqlite3:/scale/db/development.sqlite3 \
 -v=${SCALE_MIGRATE}/db/external.sqlite3:/scale/db/external.sqlite3 \
 -v=${SCALE_MIGRATE}/db/development/backup:/scale/db/development/backup \
 -v=${SCALE_MIGRATE}/archive:/scale/archive \
 -v=${SCALE_MIGRATE}/public/GNU:/scale/public/GNU \
 scale /bin/bash
```

Then, in a terminal on your host machine, copy that important migration data elsewhere. Do this for regular backups, as well as right before a migration.
E.g., 
```
mkdir ${SCALE_MIGRATE}/backup
cp ${SCALE_MIGRATE}/* ${SCALE_MIGRATE}/backup
```

### Method to Use to Copy Migration Files and Directories if the Container is not Volume Sharing Them

See https://stackoverflow.com/a/42553681 which provides the following solution to copy to or from such a container (you will need to specify CONTAINER as `scale` and `SRC_PATH` paths listed in the [section below](#locations-of-migration-files-and-directories-in-the-docker-container-which-should-also-be-backed-up-regularly) and your own  `DEST_PATH` destination path)
```
docker cp [OPTIONS] CONTAINER:SRC_PATH DEST_PATH
docker cp [OPTIONS] SRC_PATH CONTAINER:DEST_PATH
```

Another Stack Overflow answer (https://stackoverflow.com/a/33956387) recommends committing your existing container (that is create a new image from container’s changes) and then running it with your new mounts, to start volume-sharing as desired. We have not tested the method ourselves, but this particular answer currently has 504 upvotes so far giving support for the method being useful. (Also, we have seen the same method recommended on other pages after googling about how to start volume sharing after initially starting a container without volume sharing.) Copying the example from that attributed link:
```
$ docker ps  -a
CONTAINER ID        IMAGE                 COMMAND                  CREATED              STATUS                          PORTS               NAMES
    5a8f89adeead        ubuntu:14.04          "/bin/bash"              About a minute ago   Exited (0) About a minute ago                       agitated_newton

$ docker commit 5a8f89adeead newimagename

$ docker run -ti -v "$PWD/somedir":/somedir newimagename /bin/bash
```
Then the example says if all is ok, to stop the old container and to use the new one.


Additional methods are also listed in other parts of the same Stack Overflow page: 
[https://stackoverflow.com/questions/28302178/how-can-i-add-a-volume-to-an-existing-docker-container](https://stackoverflow.com/questions/28302178/how-can-i-add-a-volume-to-an-existing-docker-container)



### Locations of Migration Files and Directories in the Docker Container Which Should Also Be Backed Up Regularly


Locations in the container:

a. `db/development.sqlite3`: The "internal" SCALe database, which holds data for all the projects in SCALe.
a. `db/external.sqlite3`: The "external" SCALe database, which is designed to export data for only one project at a time.
a. `db/development/backup`: This is a directory. It holds a differently-numbered subdirectory for each SCALe project, with an "external" type of database for the project.
a. `archive`: This is a directory. You should copy the whole thing. It contains two subdirectories, discussed below.
    -   `archive/development/backup`: This is a directory. It holds a differently-numbered subdirectory for each SCALe project.
    -   `archive/development/nobackup`: This is a directory. It holds a differently-numbered subdirectory for each SCALe project.
a. `public/GNU`: This is a directory. It holds a differently-numbered subdirectory for each SCALe project. It has the GnuGlobal-processed files for each codebase that is a SCALe project.


NOTE: When migrating to a new SCALe version, you should NOT copy the following files from the OLD version of SCALe to the NEW version of SCALe. From the container, do NOT copy the  following into a shared volume in the NEW version of SCALe:

   -   `db/migrate` folder, nor any of its contents (Don't need this since the new version of SCALe will have all those migrations plus possibly more)
   -   `db/schema.rb` (Don't need this since the new version of SCALe will have the correct new schema)
   -   `db/seeds.rb` (Don't need this since the new version of SCALe will have the correct new seeds) 


### Steps to Migrate All the Projects (Prepare for, Then Move to a New Installation of SCALe)

Do the following steps to migrate all of the projects from an old installation of SCALe to a new version of SCALe:

1. *Back up* the directories from the container that you have access to, via container volume sharing.
   -   Back up the full original `scale.app` directory if you have access to all of that from the container, to a different directory outside the `scale.app` filepath. 
   -   Otherwise, back up the migration files and directories specified above, to a different directory that is not part of volume sharing and is outside the `scale.app` filepath. 
2. Unpack/install a fresh SCALe installation from the new tarball. Start up SCALe with volume sharing for migration and backup, according to one of the methods described above that is most appropriate for you.
3. In the newly installed app location, replace the following directories or files with copies from the old installation, by copying the file or directory to the appropriate shared volume location:
   -   `scale.app/db/development.sqlite3`
   -   `scale.app/archive`
   -   `scale.app/public/GNU`
Note that it is *not* necessary to copy anything in `scale.app/db/development/backup` (the migration would still work regardless)
4. If using a container, stop the previous SCALe container and start up the new SCALe container.
5. In the newly-installed app location, change to the `scale.app` directory: `cd $SCALE_HOME/scale.app`. 
   -   If you are using a SCALe container, you can get to a command-line by running `docker exec -it scale /bin/bash`. Your starting directory is already `/scale` which is also aliased to `/scale.app`, so you don't have to change directories.
6. Run `bundle exec rake db:migrate`.  This will update the schema in `db/development.sqlite3` while preserving the data. Note that there would have to be an extra step in here if the migration required any specific initializations or transformations of data beyond just updating the schema. For migrations from recent versions (e.g., March 2021), SCALe does not seem to need that.
7. Run `scripts/init_external_from_internal.py -v -f`. By default this will reinitialize the external DBs for all projects present in the internal DB which was just migrated in the last step.
9. The external DB schemas and data for each project should now be in sync with the data within the internal DB.


### Related Information about SCALe Databases

The following process is done when a project is created or edited:

1. update `db/development.sqlite3` -> `db/external.sqlite3`
2. copy `db/external.sqlite3` > ```db/backup/$PROJECT/external`timestamp`.sqlite3```
3. load SA-output -> `archive/backup/$PROJECT/db.sqlite`
4. copy `archive/backup/$PROJECT/db.sqlite` -> `db/external.sqlite3`
5. copy `db/external.sqlite3` -> `db/backup/$PROJECT/external.sqlite3`

Related information is here: [DB-Design-for-per-project-SQLite-files-in-backup.md](DB-Design-for-per-project-SQLite-files-in-backup.md)



------------------------------------------------------------------------

Attachments:
------------

![](images/icons/bullet_blue.gif)
[Arrow Left](attachments/arrow_left.png)
(image/png)\
![](images/icons/bullet_blue.gif)
[Arrow Right](attachments/arrow_right.png)
(image/png)\
![](images/icons/bullet_blue.gif)
[Arrow Up](attachments/arrow_up.png)
(image/png)
