---
title: SCAIFE 'Bill of Materials'
---

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

Third-Party Software (Current)
====================

NOTE: The information about third-party software listed below details components that get explicitly installed via
command-line calls to package installers (e.g., apt-get, pip, etc.)
It does not include undocumented dependencies that are installed automatically.

Information is available from the following files:

* ```datahub_server_stub/Dockerfile```
* ```priority_server_stub/Dockerfile```
* ```registration_server_stub/Dockerfile```
* ```stats_server_stub/Dockerfile```
* ```ui_server_stub/scale.app/Dockerfile``` Within this Dockerfile, there are specified additional files which Dockerfile specifies using to explicitly install additional third-party packages. For instance, the files `scale.app/Gemfile` and `scale.app/Gemfile.lock` specify Ruby gems that get installed. 
* ```ui_server_stub/Dockerfile``` This file is not used for the production running SCAIFE. It is only used for automated integration testing, which creates a swagger UI module in addition to a SCALe UI module. 
* ```scaife/Vagrantfile``` The `Vagrantfile` is relevant only for VM releases/deployments, but the other files above are relevant to all our current releases/deployments, which all use containers. 
* As part of VM deployments by SEI, we install Virtual Box's (VB's) Guest Tools (see https://www.engineyard.com/blog/building-a-vagrant-box-from-start-to-finish)


JavaScript Libraries
--------------------

All JavaScript libraries are installed for SCALe use only, not the other containers or modules.
The JavaScript libraries support particular functionality offered by SCALe, and are installed as
dependencies of Ruby Gems. (See outdated example list below, for an example of 
JavaScript libraries installed for an older version of SCALe.)



Outdated Example Lists of Third-Party Software in SCAIFE 
====================

NOTE!: The list below contains out-of-date information, provided for readers to 
see an example of third-party packages installed for a previous version of SCAIFE.
It details components that were explicitly installed via
command-line calls to package installers (e.g., `apt-get`, `pip`, etc.)
for the SCAIFE release prototype VM beta version 2.1.3 in October 2019.
It does not include undocumented dependencies that were installed
automatically.

Installed for SCALe
-------------------

* `build-essential`
* `dos2unix`
* `jasper`
* `GnuGlobal`
* `eclipse`
* `geckodriver`
* `maven`
* `python (both version 2 and 3)`
* `pylint`
* `python-pytest`
* `python-pytest-cov`
* `sqlite3`
* `sqlite3-pcre`
* `ruby (both ruby2.4-dev and ruby2.5-dev)`
* `rubygems-integration`
* `libssl-dev`
* `zlib1g-dev`
* `libbz2-dev`
* `libreadline-dev`
* `libsqlite3-dev`
* `llvm`
* `libncurses5-dev`
* `libncursesw5-dev`
* `xz-utils`
* `tk-dev`
* `libffi-dev`
* `liblzma-dev`
* `python-openssl`
* `open-vm-tools`
* `open-vm-tools-desktop`
* `libxml2-dev`
* `libxslt1-dev`
* Virtual Box's (VB's) Guest Tools (see https://www.engineyard.com/blog/building-a-vagrant-box-from-start-to-finish)

Installed for SCAIFE
--------------------

* `Anaconda`
* `ctags`
* `mongodb`
* `python-pip`
* `python3-pip`
* `git`
* `pyenv` (https://github.com/pyenv/pyenv.git)
* `dos2unix`

Python Packages
---------------

All Python packages are for SCAIFE only.

* `flask_cors`
* `tox`
* `connexion`
* `python_dateutil`
* `setuptools`
* `mongoengine`
* `pymongo`
* `pyjwt`
* `bcrypt`
* `munch`
* `numpy`
* `lightgbm`
* `xgboost`
* `hyperopt`
* `scikit-learn`
* `flask_testing`
* `coverage`
* `nose`
* `pluggy`
* `py`
* `randomize`
* `pandas`

Ruby Gems
---------

All Ruby gems are for SCALe only.

* `json_pure`
* `bundler`
* `rails`
* `responders`
* `sqlite3`
* `pry`
* `pry-nav`
* `rubocop`
* `jshint`
* `minitest`
* `minitest-reporters`
* `simplecov`
* `turbolinks`
* `sprockets-rails`
* `bootstrap-sass`
* `will_paginate-bootstrap`
* `coffee-rails`
* `therubyracer`
* `execjs`
* `uglifier`
* `listen`
* `jquery-rails`
* `jquery-ui-rails`
* `annotate`
* `best_in_place`
* `rake`
* `populator`
* `will_paginate`
* `thin`
* `zip-zip`
* `bootsnap`
* `rest-client`
* `webmock`
* `rails-controller-testing`

JavaScript Libraries
--------------------

All JavaScript libraries are for SCALe only.  The libraries support
particular functionality offered by SCALe, and are installed as
dependencies of the Ruby Gems listed.

* `jquery` (required to use Gem `bootstrap-sass`; installed with Gem `jquery-rails`)
* `jquery_ujs` (required to use Gem `jquery-rails`; installed with Gem `jquery-rails`)
* `bootstrap-sprockets` (required to use Gem `bootstrap-sass`; installed with Gem `bootstrap-sass`)
* `best_in_place` (required to use Gem `best_in_place`; installed with Gem `best_in_place`)

------------------------------------------------------------------------
