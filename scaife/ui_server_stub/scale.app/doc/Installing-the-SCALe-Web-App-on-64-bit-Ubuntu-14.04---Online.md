---
title: 'SCALe : Installing the SCALe Web App on 64-bit Ubuntu 14.04 - Online'
---
 [SCALe](index.md) / [Source Code alysis (SLab (SCALe)](Welcome.md) / [Installing SCALe](Installing-SCALe.md)
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

SCALe : Installing the SCALe Web App on 64-bit Ubuntu 14.04 - Online
=====================================================================

This section describes how to install the SCALe web app on 64-bit Ubuntu
14.04, Trusty Tahr.  These instructions make heavy use of the
apt-get package manager and reference URLs on the web. Therefore,
Internet access is required.

Security Note
-------------

The SCALe web app is, by nature, a networked application. Other machines
in the system talk to the web app over a network to upload the outputs
and view the alerts. However, because of the sensitive nature of
the data on this machine, it should not be accessible from the Internet.
An Internet connection may be required to configure this machine
initially, using the instructions below. However, we recommend that this
web server, once operational, should be accessible only through an
intranet.

Documentation Conventions (Using `sudo` or `su`) for Installation Instructions
------------------------------------------------------------------------------

This documentation contains many code blocks that explain how to perform
some action. These blocks are written using the Bash shell language.
Because the syntax of different shells can vary, you may need to tweak
the syntax if you use a different shell, such as csh.

Some commands must be run with root privileges. In code blocks, these
commands are prepended with the  `sudo` command. If you get an error
when running `sudo`, then you will need to execute these commands in an
account that has administrator access. Alternatively, you can run these
commands using a root account, in which case you do not need to
prepend `sudo` to the command. If you use a proxy with your local user,
you may need to use it for your `sudo` commands. You can do so with
the -E flag as follows: `sudo` -E

Instructions
------------

### 1. Install Packages


Ensure your source list is up to date. Then you must install a number of
packages, summarized in this table:


   **Package**             **Version String tested in the past (not necessarily what you will get in online install)**
  ------------------------ ---------------------------------------------------------------------------------------------
  `build-essential`        `11.6ubuntu6`
  `sqlite3`                `3.8.2-1ubuntu2.1`
  `sqlite3-pcre`           `0~git20070120091816+4229ecc-0ubuntu1`
  `rubygems-integration`   `1.10`
  `python`                 `2.7.5-5ubuntu3`
  `libncurses5-dev`        `5.9+20140118-1ubuntu1`
  `libssl-dev`             `1.0.1f-1ubuntu2.15`
  `ruby-dev`               `2.3, 2.4.1, 2.4.4`
  `libsqlite3-dev`         `3.8.2-1ubuntu2.1`
  ------------------------ ---------------------------------------------------------------------------------------------

The following commands update your sources list and install all of these
packages:

```sh
sudo apt-get update
sudo apt-get install build-essential sqlite3 sqlite3-pcre rubygems-integration python libncurses5-dev libssl-dev ruby-dev libsqlite3-dev
```

**A Note on Versions**

It is possible the above command will install different versions of the
packages than listed in the table.  For example, the package maintainer
may release an update.  This may result in incorrect behavior in the
SCALe web application.  To install a specific version of a particular
package, use the following command.  The package name and version string
should be drawn from the table above.


```sh
sudo apt-get install <package_name>=<version_string>
```


### 2. Install Ruby Version Manager (RVM)

(Source
<https://rvm.io/rvm/install>{.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png))

1.  Install GPG keys
      ```sh
      gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
      ```

2.  RVM has a dedicated Ubuntu package. Run the following instructions
    from <https://github.com/rvm/ubuntu_rvm>{.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).
    ```sh
    sudo apt-get install software-properties-common
    sudo apt-add-repository -y ppa:rael-gc/rvm
    sudo apt-get update
    sudo apt-get install rvm
    ```
3.  Install Ruby 2.3.4

      ```sh
      rvm install 2.4
      rvm use 2.4
      ```

4.  To verify the version is correct, run

      ```sh
      ruby -v
      ```

### 3. Install GNU Global

Next, you must download, build, and install GNU Global.  (This program
is available in the Ubuntu repositories, but it is an older version.)
The source is available
from [http://www.gnu.org/software/global/download.html.](http://www.gnu.org/software/global/download.html){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) You
should be able to use these commands

```sh
cd $SCALE_HOME/scale.app
wget https://tamacom.com/global/global-6.5.1.tar.gz
tar -xzf global-6.5.1.tar.gz
cd global-6.5.1
./configure
make
sudo make install
```

### 4. Install Gems

Next, you need to install some "gems."  Gem ** is a package manager for
Ruby, which you installed in the previous step. Packages are called
*gems* in this system. The following command installs the required gems:

```sh
sudo -E gem install json_pure bundler
```

**A Note on Versions**

It is possible the above command will install different versions of the
gems than have been tested (version 1.8.3 of` json_pure` and version
1.8.3 of `bundler`).  For example, the gem maintainer may release an
update.  This may result in incorrect behavior in the SCALe web
application. To install a specific version of a particular gem, use the
following command.

```sh
sudo gem install <package_name> -v <version_number>
```

### 5. Install SCALe

If you have not already extracted the SCALe web app software as
described below, you must do so now.  The SCALe web app is provided in a
tarball archive, referred to as `<scale_webapp_archive>.tgz` below. This
archive should be extracted on your web app server in a location of your
choosing. From here forward, we refer to this location as
`SCALE_HOME`. You may find it useful to define this environment variable
in your system to point to the root of your SCALe installation.
Extracting the archive might look something like this (note 1. the
following commands do **not** use sudo; 2. you should substitute your
own path to the folder that scale.app will be installed to where it says
"/location/of/SCALe/install" AND no slash is needed at the end of this
path AND you should NOT have scale.app at the end of this path; and 3.
you should substitute your own path to the scale webapp tarball (if you
are using that), in the last command):

```sh
export SCALE_HOME="/location/of/SCALe/install"
mkdir -p $SCALE_HOME
cd $SCALE_HOME
tar xzf /location/of/<scale_webapp_archive>.tgz
```

### 6. Install Dependencies

Finally, run the following commands to install the remaining web app
dependencies and create the initial database. (Note the following
commands do **not** use sudo.)

```sh
cd $SCALE_HOME/scale.app
bundle install --path vendor/bundle/
bundle exec rake db:migrate
```

### 7. [Tips for SCALe performance improvement](Tips-for-SCALe-performance-improvement.md)

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Installing-on-64-bit-CentOS-Offline.md)
[![](attachments/arrow_up.png)](Installing-SCALe.md)
