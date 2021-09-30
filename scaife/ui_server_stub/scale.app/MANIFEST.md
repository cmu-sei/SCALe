This document describes the structure of the SCALe distribution.  This
information is intended to aid people working on peripheral SCALe
development work, such as packagers or SELinux policy authors.

This manifest specifies an intended set of user/group/permission settings
for running SCALe as an unprivileged virtual user. It does not apply
to instances where SCALE is run privileged. This could include a
Docker container, such as in some SCAIFE releases. Some files may be
owned by user root, group, whereas others may be owned by the
unprivileged virtual user or a different group.  Compliance has not
yet been verified or enforced for this version of SCALe. Currently,
this manifest is intended to guide SCALe developers, but enforcement
remains pending until an automated enforcement testing script will be
created.

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


## SCALe writable files

There are some files that SCALe must be able to create, or write to if
already created. They need not exist in an initial distribution.

A good strategy is to create these files as empty files before
starting the server. Such a file should be owned by the scale user and
scale grup, and have permissions 600, unless otherwise
specified. Their size/content/hash will change as SCALe modifies them,
so these aspects of the files should not be verified as part of
package verification.  Some directories will also initially be empty
and be filled by the server.

These files and directories will have the phrase
`created_by_scale_post_release`. before their introduction.

## `<Root directory>`

The root directory in which SCALe is installed should be user root,
group root, and no more permissive than permission 755.


MetaData
========

These files provide human-readable information about SCALe, but are
not used by the SCALe web app.

## `README.md`

This file contains release notes

## `ABOUT`

A JSON file that provides meta information about this specific SCALe
distribution.

## `COPYRIGHT`

This file contains the SCALe copyright.

## `demo`

Examples of input and output data suitable for feeding to SCALe.

## `doc`

SCALe documentation, in GFM format. (During the build process, these
files are converted to HTML and stored in public/doc/scale2)


Building SCALe
==============

## `.bundle`
## `Gemfile`
## `Gemfile.lock`
## `Rakefile`

These files and directories instruct Ruby to download sufficient gems
for distributing SCALe.

## `.git`
## `.gitingore`
## `.gitmodules`

These files are used by GIT to indicate the proper version of SCALe.

## `requirements.txt`

Some python modules are required that are not in python's standard
library. They are listed in this file. If using pip, use:

  pip install -r requirements.txt

Otherwise use apt-get to install the distro packaged versions:

  sudo apt install python-yaml python-lxml python-bs4


Testing SCALe
=============

These directories and files are used when testing SCALe, but are not
touched by the SCALe web app itself. They should be user scale, group
scale, permission 700.

## `bin`

This contains several binary executables for testing SCALe.

## `.coverage`

This file is produced when running coverage tests on the SCALe web
app. It is not accessed by the web app itself.

## `pylintrc`

This file is used to indicate specific tests for pylint to use when
testing SCALe.

## `test-output`

This directory contains output from running SCALe tests.

## `test`

This directory contains specific tests for SCALe, such as unit tests
in Python and Java. Not used by the SCALe web app itself.


SCALe Deployment
================

These files are used when deploying SCALe using various
technologies. They are not read or modified by the SCALe web app
itself.

## `package.py`

A script for creating a distribute-able tarball of SCALe.

## `packages`

`created_by_scale_post_release`

A directory for holding distribute-able SCALe tarballs.

## `Dockerfile`

This file instructs Docker to build a container for testing SCALe as
part of a CI/CD process.

## `cookbooks`
## `nodes`
## `roles`
## `Vagrantfile`

These directories contain information for building SCALe into a VM
using Vagrant.

## `scale_1804.json`
## `scale.json`

These files contain Vagrant configuration information for various VMs.


SCALe Web App Code
==================

With exceptions noted below, all files below `app` should be user
root, group root, and permission 755 (for directories) or permission
644 (for files).

SCALe reads all files into these files & directories, but does not
write anything to them.

## `app`

A directory tree containing core functionality for the (Ruby on Rails)
SCALe web app. This includes icons, Ruby code, CSS files, Javascript
code, et. al.

## `app/controllers/application_controller.rb`

This files contains SCALe configuration data, including TLS settings
and potentially passwords.  _It must be protected from casual
viewing._ It should be user scale, group scale, permission 600.

For packaging, this file should be marked as a configuration file, so
that SCALe package upgrades do not overwrite local changes to this
file.

## `lib`
## `script`

Various configuration files used by SCALe.

## `scripts`

These are Python scripts used for importing data into SCALe.

## `remake_db.sh`
## `setup.sh`
## `start.sh`

These shell scripts are responsible for starting, stopping, and
resetting data on the SCALe server.

## `vendor`

This directory contain the gems used by SCALe.


SCALe Web App Configuration
===========================

These files and directories contain configuration data for SCALe. They
may be modified by an administrator, and they are ready, but not
modified, by the web app. Unless otherwise specified, the information
is not sensitive.

## `cert`

If the SCALe web app is run in SSL mode, the SSL certificates should
be stored here. If run outside of SSL mode, this directory may be
empty. Nonetheless, the data here is sensitive, and so it should be
user scale, group scale, permission 700.

## `config`

Various configuration data for SCALe.

## `config.ru`

This file contains configuration information for Rack-based servers to
start SCALe.  It should be user root, group root, permission 644.


SCALe Web App Data
==================

## `archive`

The archive directory is where SCALe unpacks artifacts that are
uploaded.  SCALe writes to this directory tree.  It should be user
scale, group scale, permission 700.

The bulk of SCALe's data will be in this directory tree.

## `db`

The directory tree that contains SCALe databases.

SCALe creates database files in this directory during normal
operation.  It should be user scale, group scale, permission 700.

With exceptions noted below, all files below `db`` should be user
scale, group scale, and permission 755 (for directories) or permission
644 (for files).

## `db/development.sqlite3`
## `db/development.db`
## `db/external.db`

`created_by_scale_post_release`

These are the primary internal and external databases actually read
and written by the SCALe web app at startup (tables: languages,
taxonomies, and tools), when auditing data, when users upload user
data, and when a new SCALe project is created.

They should be packaged as empty files, user scale, group scale,
permissions 600.  Their size/content/hash will change as SCALe
modifies it, so these aspects of the files should not be verified as
part of package verification.

## `db/external.sqlite3`

`created_by_scale_post_release`

This holds any database that is used when importing or exporting a
database into the SCALe web app.

It should be packaged as an empty file, user scale, group scale,
permissions 600.  Its size/content/hash will change as SCALe modifies
it, so these aspects of the file should not be verified as part of
package verification.

## `db/test.sqlite3`

`created_by_scale_post_release`

This holds a database used for testing the app. It is not used by
SCALe when in production mode.

It should be packaged as an empty file, user scale, group scale,
permissions 600.  Its size/content/hash will change as SCALe modifies
it, so these aspects of the file should not be verified as part of
package verification.

## `db/backup`

`created_by_scale_post_release`

This directory holds backups of the db/development.sqlite3 and
db/external.sqlite3 files.

It should be initially packaged as an empty directory, and be owned by
user scale, group scale, permissions 700.

## `log`

This holds log files generated by the SCALe web app during
execution.

`created_by_scale_post_release`

## `log/development.log`

`created_by_scale_post_release`

The actual log file written by the web app.

It should be packaged as an empty file, user scale, group scale,
permissions 600.  Its size/content/hash will change as SCALe modifies
it, so these aspects of the files should not be verified as part of
package verification.

## `log/test.log`

`created_by_scale_post_release`

This log file is written by the web app only when testing. It is not
used by SCALe when in production mode.

It should be packaged as an empty file, user scale, group scale,
permissions 600.  Its size/content/hash will change as SCALe modifies
it, so these aspects of the file should not be verified as part of
package verification.

## `public`

This directory contains web pages used by SCALe. Most are not
writable, except as noted below:

## `public/GNU`

This directory contains web pages generated by GNU Global when a new
project is created by SCALe. The web app must create sub-directories
numbered after each project.

## `public/doc`

This directory contains the SCALe documentation made available under
SCALE's 'help' link. It also contains the CERT Secure Coding
standards. SCALe can read any file here, but never changes them.


## `tmp`

Temporary data used by the SCALe web app.
