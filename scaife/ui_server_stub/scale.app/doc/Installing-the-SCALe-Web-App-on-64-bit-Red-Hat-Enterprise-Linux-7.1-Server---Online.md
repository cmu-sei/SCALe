---
title: |
    SCALe : Installing the SCALe Web App on 64-bit Red Hat Enterprise Linux
    7.1 Server - Online
---
 [SCALe](index.md) / [Source Code alysis Lab (SCALe)](Welcome.md) / [Installing SCALe](Installing-SCALe.md)
<!-- <legal> -->
<!-- SCALe version r.6.2.2.2.A -->
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
<!-- Released under a MIT (SEI)-style license, please see COPYRIGHT file or -->
<!-- contact permission@sei.cmu.edu for full terms. -->
<!--  -->
<!-- [DISTRIBUTION STATEMENT A] This material has been approved for public -->
<!-- release and unlimited distribution.  Please see Copyright notice for -->
<!-- non-US Government use and distribution. -->
<!--  -->
<!-- DM19-1274 -->
<!-- </legal> -->

SCALe : Installing the SCALe Web App on 64-bit Red Hat Enterprise Linux 7.1 Server - Online
============================================================================================

This section describes how to install the SCALe web app on 64-bit Red
Hat Enterprise Linux, Server Edition, Release 7.1.  These instructions
make heavy use of the yum package manager and reference URLs on the web.
Therefore, Internet access is required.

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
prepend `sudo` to the command.

Instructions
------------

1.  Ensure that you have the `rhel-7-*-optional-rpms` repository
    enabled, as several packages are sourced from this repository.

    ```sh
    sudo yum-config-manager --enable "rhel-7-*-optional-rpms"
    ```

2.  You must install a number of packages, summarized in this table

    +-----------------------------------+-----------------------------------+
    | Packages                          | Version String                    |
    +===================================+===================================+
    | `gcc`                             | `4.8.3-9.el7`                     |
    +-----------------------------------+-----------------------------------+
    | `gcc-c++`                         | `4.8.3-9.el7`                     |
    +-----------------------------------+-----------------------------------+
    | `sqlite`                          | `3.7.17-6.el7_1.1`                |
    +-----------------------------------+-----------------------------------+
    | `sqlite-devel`                    | `3.7.17-6.el7_1.1`                |
    +-----------------------------------+-----------------------------------+
    | `ruby`                            | `2.0.0.598-25.el7_1`              |
    +-----------------------------------+-----------------------------------+
    | `ruby-devel`                      | `2.0.0.598-25.el7_1`              |
    +-----------------------------------+-----------------------------------+
    | `ncurses-devel`                   | `5.9-13.20130511.el7`             |
    +-----------------------------------+-----------------------------------+
    | `openssl-devel`                   | `1:1.0.1e-42.el7_1.9  `           |
    +-----------------------------------+-----------------------------------+

    The following command installs all of these packages at once:

    ```sh
    sudo yum install gcc gcc-c++ sqlite sqlite-devel ruby ruby-devel ncurses-devel openssl-devel
    ```

    **A Note on Versions**

    It is possible the above command will install different versions of
    the packages than listed in the table.  For example, the package
    maintainer may release an update.  This may result in incorrect
    behavior in the SCALe web application.  To install a specific
    version of a particular package, use the following command.  The
    package name and version string should be drawn from the table
    above.

    ```sh
    sudo yum install <package_name>-<version_string>
    ```

3.  Next, you must download, build, and install GNU Global.  The source
    is available
    from  [http://www.gnu.org/software/global/download.html.](http://www.gnu.org/software/global/download.html){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) You should be able to use these commands:

    ```sh
    wget https://tamacom.com/global/global-6.5.1.tar.gz
    tar -xzf global-6.5.1.tar.gz
    cd global-6.5.1
    ./configure
    make
    sudo make install
    ```

4.  Next, you must download, build, and install the SQLite PCRE
    (Perl-Compatible Regular Expressions) package. This step creates a
    file called  `/usr/lib/sqlite3/pcre.so ` , which is used by the
    SCALe back end. The source is available here:
    <https://github.com/ralight/sqlite3-pcre>{.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)

    ```sh
    wget https://github.com/ralight/sqlite3-pcre/archive/master.zip
    unzip master.zip
    cd sqlite3-pcre-master
    make
    sudo make install
    ```

5.  Next, you need to install some "gems."  Gem is a package manager
    for Ruby, which you installed in the previous step. Packages are
    called  *gems*  in this system. The following command installs the
    first required gem:

    ```sh
    sudo -E gem install json_pure bundler
    # The "-E" keeps the user's environmental variables, such as proxy URLs.
    ```

    **A Note on Versions**

    It is possible the above command will install different versions of
    the gems than have been tested (version 1.8.3 of` json_pure` and
    version 1.8.3 of `bundler`).  For example, the gem maintainer may
    release an update.  This may result in incorrect behavior in the
    SCALe web application. To install a specific version of a particular
    gem, use the following command.

    ```sh
    sudo gem install <package_name> -v <version_number>
    ```

6.  RubyGems is already installed, but must be updated, using this
    command:

    ```sh
    sudo -E gem update --system
    # The "-E" keeps the user's environmental variables, such as proxy URLs.
    ```

7.  If you have not already extracted the SCALe web app software as
    described below, you must do so now. The SCALe web app is provided
    in a tarball archive, referred to as  `<scale_webapp_archive>.tgz`
     below. This archive should be extracted on your web app server in a
    location of your choosing. From here forward, we refer to this
    location as  `SCALE_HOME` . You may find it useful to define this
    environment variable in your system to point to the root of your
    SCALe installation. Extracting the archive might look something like
    this:

    ```sh
    export SCALE_HOME="/location/of/SCALe/install"
    mkdir -p $SCALE_HOME
    cd $SCALE_HOME
    tar xzf /location/of/<scale_webapp_archive>.tgz
    ```


8.  Finally, run the following commands to install the remaining web app
    dependencies and create the initial database.

    ```sh
    cd $SCALE_HOME/scale.app
    bundle install --path vendor/bundle/
    bundle exec rake db:migrate
    ```



------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Installing-SCALe.md)
[![](attachments/arrow_up.png)](Welcome.md)
