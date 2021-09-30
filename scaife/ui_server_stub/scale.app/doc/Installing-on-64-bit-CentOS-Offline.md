---
title: |
    SCALe : Installing the SCALe Web App on 64-bit CentOS Linux 6.6
    (minimal version, with gnome and browser added) - Offline
---

[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Installing SCALe](Installing-SCALe.md)
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

SCALe : Installing the SCALe Web App on 64-bit CentOS Linux 6.6 (minimal version, with gnome and browser added) - Offline
==========================================================================================================================

In this scenario, you install a SCALe distribution onto a CentOS 6.6
machine that has no net access. The SCALe CentOS Offline bundle has no
external network requirements; it is entirely self-contained. The bundle
is provided to you as a tarball archive, referred to below
as `<scale-offline-tarball>.tgz`.  Remember to review the "Documentation
Conventions (Using `sudo` or `su`) for Installation Instructions"
section, security notes, and more on the main [Installing
SCALe](Installing-SCALe.md) page.

This distribution is designed for 64-bit CentOS 6.6 Linux 
([minimal version](http://vault.centos.org/6.6/isos/x86_64/CentOS-6.6-x86_64-minimal.iso){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png))
with gnome and a browser added).   Method used to install the
third-party packages is similar to what’s documented on this page:
[http://www.idevelopment.info/data/Unix/Linux/LINUX_AddGNOMEToCentOSMinimalInstall.shtml](http://www.idevelopment.info/data/Unix/Linux/LINUX_AddGNOMEToCentOSMinimalInstall.shtml){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png). So,

`yum -y groupinstall "Desktop" "Desktop Platform" "X Window System" "Fonts"`

`yum -y groupinstall "Internet Browser"`

After completing these instructions, do **not** update your system with
newer packages.  They may cause the installation to fail due to obsolete
dependencies.

Documentation Conventions (Using `sudo` or `su`) for Installation Instructions
------------------------------------------------------------------------------

This documentation contains many code blocks that explain how to perform
some action. These blocks are written using the Bash shell language.
Because the syntax of different shells can vary, you may need to tweak
the syntax if you use a different shell, such as csh. 

Some commands must be run with root privileges. In code blocks, these
commands are prepended with the  `sudo` command. If you get an error
when running `sudo`, then you will need to execute these commands in an
account that has administrator access. Alternatively, you can run these
commands using a root account, in which case you do not need to
prepend `sudo` to the command.

Instructions
------------

To install SCALe, you must do the following.

1.  If you have not already extracted the SCALe web app software as
    described below, you must do so now:

    ```sh
    export SCALE_HOME="/location/of/SCALe/install"
    mkdir -p $SCALE_HOME
    cd $SCALE_HOME
    tar xzf <scale-offline-tarball>.tgz
    ```

2.  Install all RPMs provided.  This command will ask you for
    confirmation before installing the packages.  Type 'y &lt;Enter&gt;'
    at the confirmation prompt to install the packages as **root**

    ```sh
    cd $SCALE_HOME/scale.app/extern
    yum localinstall rpm/*
    ```

3.  Install SQLITE from source as **root**

    ```sh
    cd $SCALE_HOME/scale.app/extern/sqlite-autoconf-3090200
    ./configure
    make
    make install
    ```

4.  Install the SQLite PCRE package as **root** 

    ```sh
    cd ../sqlite3-pcre-master
    make
    make install
    ```

5.  Install Ruby from source as **root**

    ```sh
    cd ../ruby-2.0.0-p647
    ./configure
    make
    make install
    ```

6.  Install Python from source as **root**

    ```sh
    cd ../Python-2.7.5
    ./configure
    make
    make altinstall
    ```

7.  Install GNU Global from source as **root**

    ```sh
    cd ../global-6.5.1
    ./configure
    make
    make install
    ```

8.  Install prerequisite gems as **root**

    ```sh
    cd ..
    gem install -f --local  gem/json_pure-1.8.3.gem gem/bundler-1.10.6.gem
    ```

9.  Install the webapp in a new terminal, as **NOT root (Careful: do not
    install this as root!)**

    ```sh
    cd $SCALE_HOME/scale.app
    cp -r extern/gem/cache vendor
    bundle install --local --path vendor/bundle/
    bundle exec rake db:migrate
    ```

10. Make a symlink for Python, as **root**

    ```sh
    ln -s /usr/local/bin/python2.7 /usr/local/bin/python
    ```

    Note that the account on which the app runs should have 'python'
    invoke Python 2.7 by default. This can be accomplished by the
    account having `/usr/local/bin` before `/usr/bin` in their `$PATH`
    environment variable.

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Installing-SCALe.md)
[![](attachments/arrow_up.png)](Welcome.md) 
