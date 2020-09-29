---
title: SCAIFE 'Bill of Materials'
---

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
<!-- Released under a MIT (SEI)-style license, please see COPYRIGHT file or -->
<!-- contact permission@sei.cmu.edu for full terms. -->
<!--  -->
<!-- [DISTRIBUTION STATEMENT A] This material has been approved for public -->
<!-- release and unlimited distribution.  Please see Copyright notice for -->
<!-- non-US Government use and distribution. -->
<!--  -->
<!-- DM19-1274 -->
<!-- </legal> -->

Updated info is available from the following files:

* ```scaife/Vagrantfile```
* ```datahub_server_stub/Dockerfile```
* ```priority_server_stub/Dockerfile```
* ```registration_server_stub/Dockerfile```
* ```stats_server_stub/Dockerfile```
* ```ui_server_stub/scale.app/Dockerfile```

The list below details components that were explicitly installed via
command-line calls to package installers (e.g., apt-get, pip, etc.)
for the SCAIFE release prototype VM beta version 2.1.3 in October 2019.
It does not include undocumented dependencies that were installed
automatically.

Third-Party Software
====================

Installed for SCALe
-------------------

* build-essential
* dos2unix
* jasper
* GnuGlobal
* eclipse
* geckodriver
* maven
* python (both version 2 and 3)
* pylint
* python-pytest
* python-pytest-cov
* sqlite3
* sqlite3-pcre
* ruby (both ruby2.4-dev and ruby2.5-dev)
* rubygems-integration
* libssl-dev
* zlib1g-dev
* libbz2-dev
* libreadline-dev
* libsqlite3-dev
* llvm
* libncurses5-dev
* libncursesw5-dev
* xz-utils
* tk-dev
* libffi-dev
* liblzma-dev
* python-openssl
* open-vm-tools
* open-vm-tools-desktop
* libxml2-dev
* libxslt1-dev
* Virtual Box's (VB's) Guest Tools (see https://www.engineyard.com/blog/building-a-vagrant-box-from-start-to-finish)

Installed for SCAIFE
--------------------

* Anaconda
* ctags
* mongodb
* python-pip
* python3-pip
* git
* pyenv (https://github.com/pyenv/pyenv.git)
* dos2unix

Python Packages
---------------

All Python packages are for SCAIFE only.

* flask_cors
* tox
* connexion
* python_dateutil
* setuptools
* mongoengine
* pymongo
* pyjwt
* bcrypt
* munch
* numpy
* lightgbm
* xgboost
* hyperopt
* scikit-learn
* flask_testing
* coverage
* nose
* pluggy
* py
* randomize
* pandas

Ruby Gems
---------

All Ruby gems are for SCALe only.

* json_pure
* bundler
* rails
* responders
* sqlite3
* pry
* pry-nav
* rubocop
* jshint
* minitest
* minitest-reporters
* simplecov
* turbolinks
* sprockets-rails
* bootstrap-sass
* will_paginate-bootstrap
* coffee-rails
* therubyracer
* execjs
* uglifier
* listen
* jquery-rails
* jquery-ui-rails
* annotate
* best_in_place
* rake
* populator
* will_paginate
* thin
* zip-zip
* bootsnap
* rest-client
* webmock
* rails-controller-testing

JavaScript Libraries
--------------------

All JavaScript libraries are for SCALe only.  The libraries support
particular functionality offered by SCALe, and are installed as
dependencies of the Ruby Gems listed.

* jquery (required to use Gem 'bootstrap-sass'; installed with Gem 'jquery-rails')
* jquery_ujs (required to use Gem 'jquery-rails'; installed with Gem 'jquery-rails')
* bootstrap-sprockets (required to use Gem 'bootstrap-sass'; installed with Gem 'bootstrap-sass')
* best_in_place (required to use Gem 'best_in_place'; installed with Gem 'best_in_place')

------------------------------------------------------------------------
