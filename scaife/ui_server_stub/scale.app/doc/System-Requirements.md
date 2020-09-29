---
title: 'SCALe : System Requirements'
---
[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md)
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

SCALe : System Requirements
============================

-   [SCALe](#scale)
-   [Static Analysis Tools](#static-analysis-tools)
-   [Third-Party (non-SEI) Software and Offline SCALe Installation Disks](#third-party-non-sei-software-and-offline-scale-installation-disks)
-   [Network Access](#network-access)
-   [Requirements and
    Limitations](#requirements-and-limitations)
-   [Cryptography](#cryptography)

SCALe
-----

We are currently releasing a version of the SCALe software that has been verified to work on 64-bit Ubuntu 18.04 LTS.

SCALe consists of a front-end web app that uses Ruby-on-Rails and
manages a SQLite database. The front end has been tested with Firefox 69.01
(Past SCALe versions were tested with Explorer 11 and Google Chrome 44.0).
The back end consists of several Python and SQL scripts.

Static Analysis Tools
---------------------

Static analysis tools must be run in a particular way, to create output
that SCALe can use as input. Information about how to do that is
provided in the [Static Analysis
Tools](Static-Analysis-Tools.md) section
of this manual.

SCALe can use output from the following general-purpose flaw-finding
static analysis tools:

| Software | Version  | License | C | C++ | Java | Perl | Windows | Linux | Notes |
|---|---|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| [CERT Rosecheckers](http://rosecheckers.sourceforge.net/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)* |  | CMU | Yes | Yes |  |  |  | Yes |
| [PC-lint](http://www.gimpel.com/html/pcl.htm){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 9.0 | Proprietary | Yes | Yes |  |  | Yes | |
| [FlexeLint](http://www.gimpel.com/html/pcl.htm){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 9.0 | Proprietary | Yes | Yes |  |  | | Yes |
| [LDRA](http://www.ldra.com/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 9.4.3 | Proprietary | Yes | Yes |  |  | Yes |  |  |
| [Coverity Prevent](http://www.coverity.com/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 7.6.1 | Proprietary | Yes | Yes | Yes |  | Yes | Yes |
| [Fortify SCA](https://www.microfocus.com/en-us/products/static-code-analysis-sast/overview){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 6.10.0120, 18.10.0187 | Proprietary | Yes | Yes | Yes |  | Yes | Yes | Fortify versions 6.10.0120 and 18.10.0187 have the same output format, but 18.10.0187 has more checker mappings |
| [cppcheck](http://cppcheck.sourceforge.net/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |  1.86, 1.83, 1.66, and 1.0 | Open source | Yes |  Yes |  |  | Yes | Yes   | Versions 1.86 and 1.83 have same output format. Versions 1.0 and 1.66 have the same output format. |
| [Microsoft Visual Studio Static Analyzer](https://msdn.microsoft.com/en-us/library/a5b9aa09(v=vs.120).aspx){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) (part of Microsoft Visual Studio) |  |  Proprietary |  Yes |   Yes |  |  | Yes |  |
| [Parasoft C/C++Test](https://docs.parasoft.com/display/CPPDESKE1040){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |  10.4 | Proprietary | Yes |  Yes |  |  | Yes | Yes   |
| [FindBugs™](http://findbugs.sourceforge.net/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 3.0.1 | Open source |  |  | Yes |  | Yes | Yes |  |
| [SpotBugs](https://spotbugs.github.io//){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |  | Open source |  |  | Yes |  | Yes | Yes |
| [Perl::Critic](https://en.wikipedia.org/wiki/Perl::Critic){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 1.118 | Open source |  |  |  | Yes |  | Yes |  |
| [B::Lint](http://perldoc.perl.org/B/Lint.html){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 1.20 | Open source |  |  |  | Yes |  | Yes |  |  |

*This software depends
on [Boost](http://www.boost.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) and [ROSE](http://rosecompiler.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).

Furthermore, every compiler, interpreter, and integrated development
environment (IDE) can serve as a flaw-finding static analysis tool
because it can provide warnings about questionable code.

SCALe can use output from the following such tools, if your codebase can
be compiled in them:

 | Software | Version  | License | C | C++ | Java | Perl | Windows | Linux |
|---|---|---|:---:|:---:|:---:|:---:|:---:|:---:|
| [Microsoft Visual C++](http://msdn.microsoft.com/en-us/vstudio/hh386302.aspx){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | Ultimate 2013 12.0.31101.00 Update 4 |  Proprietary |  | Yes |  |  | Yes |
| [GCC](https://gcc.gnu.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 4.8.3.20140911 |  Open source | Yes |  |  |  | Yes | Yes |
| [G++ ](https://gcc.gnu.org/onlinedocs/gcc-3.3.5/gcc/G_002b_002b-and-GCC.html){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 4.8.3.20140911 |  Open source |  | Yes |  |  | Yes | Yes |
| [Eclipse](http://www.eclipse.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | Luna sr2 (4.4.2) Build id: 20150219-0600 |  Open source |  |  | Yes |  | Yes | Yes |
| [Perl](https://www.perl.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 5.16.3 | Open source |  |  |  | Yes |  | Yes |

NOTE: If you use a different compiler normally for your
codebase, possibly these compilers won’t work for your code
(e.g., because your code may require a special library only provided by
the other compiler).



The reason that specific versions of the flaw-finding static analysis
(SA) tools listed above (in both charts in this 'Static Analysis Tools'
section) are required is because SCALe maps alerts from a
particular version of the SA tool to CERT coding rules. Other versions
of the SA tool may have different alerts, invalidating our SCALe
mapping. (Often this is not a significant issue, as many times new
versions of flaw-finding static analysis tools simply work with previous
mappings but simply add new checkers that need to be mapped.)

Some code metrics tools have been integrated with SCALe. SCALe can use
output from the following code metrics tools static analysis tools (See
note on Lizard below table):

| Software | Version  | License | C | C++ | Java | Perl | Windows | Linux |
|---|---|---|:---:|:---:|:---:|:---:|:---:|:---:|
| [Lizard](https://github.com/terryyin/lizard){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |  | Open source | Yes | Yes | Yes |  |  | Yes  |
| [CCSM](https://github.com/bright-tools/ccsm){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)  |  | Open source | Yes | Yes |  |  |  | Yes
| [Understand](https://scitools.com/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |  | Proprietary | Yes | Yes | Yes |  | Yes |  |

Note on Lizard use:

-   Use our `scale.app/scripts/lizard_metrics.py` script on the codebase
    you are analyzing, to output a .csv file with all the needed fields
    for our output uploader

Third-Party (non-SEI) Software and Offline SCALe Installation Disks
-------------------------------------------------------------------

| Software | Version  | License |
|---|---|---|
| [Vagrant](https://www.vagrantup.com){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 2.2.9 | Open source |
| [VirtualBox](https://www.virtualbox.org){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 6.1.12 | Open source |
| [Docker](https://www.docker.com]{.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 19.03.12 | Open source |

In general, we deploy to virtual machines and containers.
Additional information about our automated deployment process and the explicitly-added third-party code
is available in these code locations that are part of the released code:

* $SCALE_HOME/scale.app/cookbooks
* $SCALE_HOME/scale.app/Vagrantfile
* $SCALE_HOME/scale.app/Dockerfile
* $SCALE_HOME/scale.app/Gemfile
* For creating a VirtualBox base box that is used with the auto-deployment process with the Vagrantfile, we install VirtualBox Guest Additions [per these instructions](https://www.engineyard.com/blog/building-a-vagrant-box-from-start-to-finish){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)

SCALe also runs as a container as part of SCAIFE; for more details see [Containers](SCAIFE-Customization.md#containers).

The following list provides only software packages that got explicitly installed via command-line
calls to package installers (e.g., apt-get, pip, etc.) during our automated deployment process
onto an Xubuntu 18.04 virtual machine for SCALe version r.5.0.0.0.A of 10/03/2019.
The following list does not include software that got installed automatically, due to dependencies,
during installation of the explicitly-specified software.

Disclaimer: The release of SCALe version r.5.0.0.0.A within SCAIFE prototype beta version 2.1.3 Ubuntu 18.04 VM on 10/11/2019 depends on the following third-party software. However,  third-party dependencies frequently change as scale.app is developed.  Please keep in mind that the following
information may be outdated.


| General Software |
|---|
| build-essential |
| dos2unix v. 7.2.2 |
| jasper v. 1.900.1 |
| GnuGlobal v. 6.5.1 |
| eclipse v. ‎4.7.0 |
| geckodriver v. 0.24.0 |
| maven v. 4.0.0 |
| python |
| python2.7 |
| pylint |
| python-pytest |
| python-pytest-cov |
| sqlite3 |
| sqlite3-pcre |
| ruby |
| ruby2.4-dev |
| ruby2.5-dev |
| rubygems-integration |
| libssl-dev |
| zlib1g-dev |
| libbz2-dev |
| libreadline-dev |
| libsqlite3-dev |
| llvm |
| libncurses5-dev |
| libncursesw5-dev |
| xz-utils |
| tk-dev |
| libffi-dev |
| liblzma-dev |
| python-openssl |
| open-vm-tools |
| open-vm-tools-desktop |
| libxml2-dev |
| libxslt1-dev |
|Virtual Box's Guest Tools added [per these instructions](https://www.engineyard.com/blog/building-a-vagrant-box-from-start-to-finish){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)|


| Ruby Gems |
|---|
| json_pure |
| bundler |
| rails v. 5.2 or higher |
| responders v. 2.4.0 or higher |
| sqlite3 v. 1.3.5 or higher |
| pry |
| pry-nav |
| rubocop |
| jshint |
| minitest |
| minitest-reporters |
| simplecov v. 0.12.0 or higher |
| turbolinks v. 2.5.3 or higher |
| sprockets-rails |
| bootstrap-sass v. 3.3.7 or higher |
| will_paginate-bootstrap v. 1.0.1 or higher |
| coffee-rails |
| therubyracer |
| execjs |
| uglifier v. 4.1.4 or higher |
| listen |
| jquery-rails v. 4.3.1 or higher |
| jquery-ui-rails v. 6.0.1 or higher |
| annotate |
| best_in_place v. 3.1.1 |
| rake v. 12.3.0 or higher |
| populator |
| will_paginate v. 3.1.6 |
| thin v. 1.7.2 or higher |
| zip-zip |
| bootsnap |
| rest-client |
| webmock |
| rails-controller-testing |


| JavaScript Libraries |
|---|
| jquery (required to use Gem 'bootstrap-sass'; installed with Gem 'jquery-rails') |
| jquery_ujs (required to use Gem 'jquery-rails'; installed with Gem 'jquery-rails') |
| bootstrap-sprockets (required to use Gem 'bootstrap-sass'; installed with Gem 'bootstrap-sass') |
| best_in_place (required to use Gem 'best_in_place'; installed with Gem 'best_in_place') |


Not currently guaranteed to work, but in the recent past we developed a Dockerfile for automated container deployment. That is released with the SCALe code and is located at:

* $SCALE_HOME/scale.app/Dockerfile


Instructions for installs per-OS-versions are listed on the SCALe Manual's Install pages for various
operating systems, which worked at one time. However, we have not maintained that install information
and the instructions may no longer work.

**The following information up to but not including the "Network Access" section may be out of date:**

The [Installing SCALe](Installing-SCALe.md) section of this
document provides detailed instructions for installing these
prerequisites on supported platforms. **SCALe offline installation
disks work for SCALe installs on machines which are not connected to
the internet and they include the third-party software** (including
other software dependencies), and SCALe online installation
instructions (along with the online install disks) do online installs
of the third-party software (including dependencies):

| Software | Front-end dependency | Back-end dependency  |
|---|:---:|:--:|
| [Ruby](https://www.ruby-lang.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |  Yes |  |
| [RubyGems](https://rubygems.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |  Yes |  |
| [Ruby on Rails](http://rubyonrails.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |  Yes |  |
| [Python](https://www.python.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |   | Yes |
| [SQLite](https://www.sqlite.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |  Yes | Yes |
| [Sqlite3 PCRE](https://github.com/ralight/sqlite3-pcre){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |   | Yes |
| [GNU Global](http://www.gnu.org/software/global/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |  Yes |  |
| [OpenSSL](https://www.openssl.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |   Yes |  |
| [Apache HTTP](http://httpd.apache.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |  Yes |  |
| [Phusion Passenger](https://www.phusionpassenger.com/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) |  Yes |  |




Network Access
--------------

The SCALe web app has the following links that connect to external
websites. These links fail if SCALe is installed on a machine that is
not connected to the Internet.

-   The Projects page links to
    [CERT Secure Coding Products & Services](https://www.cert.org/secure-coding/products-services/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)
    (which includes SCALe).
-   Every alertCondition in the top frame of the alerts pages has links
    in its *Rules* column. Each link connects to the rule in the
    SEI/CERT coding standards that corresponds to the alert.
-   The bottom frame in the Alerts pages normally contains GNU
    Global source code pages.

Except for optional use of these links, using SCALe does not require an
Internet connection.

Requirements and Limitations
----------------------------

The SCALe app does not use Secure Sockets Layer (SSL) by default.
However, it can be configured to work with SSL.

A developer or auditor can upload entire source codebases to the SCALe
app. These codebases are converted to HTML using GNU Global, which
creates HTML pages of the source code. The app does not make the
original source code available over the web interface. However, anyone
who can access the app could, in theory, scrape individual source files
from the app. Consequently, we recommend that the SCALe app *not* be
made accessible directly from the Internet, especially if the codebases
uploaded to the app are sensitive. We recommend that any server hosting
the web app be protected at least by a firewall. We also strongly
encourage configuring the app to work with SSL.

The SCALe app is currently protected by a username and password, which
are required to access the app. While multiple people may use the app,
they all must use the same username and password. The username and
password cannot be changed over the web. They can be changed only by an
administrator who has the ability to install and maintain the SCALe app.
The username is currently `scale`. We strongly encourage the
administrator to change the password upon installation and to use a
strong password.

The SCALe app provides minimal concurrency guarantees. In particular,
multiple users may use the app to audit the same codebase. The app will
correctly record changes to all verdicts as long as no two auditors
change the verdict of the same alertCondition. If two auditors set the
verdict on the same alertCondition to different values, the app will
preserve the most recent verdict and discard the earlier one. However,
this process is done with no warning to the auditor who set the
discarded verdict. Thus, concurrent usage of the alertConditions page cannot
corrupt the database, but it can produce loss of information. We
therefore recommend that auditors coordinate with each other to prevent
the simultaneous modification of a alertCondition.

The SCALe app is written in Python and Ruby and has undergone several
manual source code reviews. (Unfortunately, we cannot run SCALe on
itself because it does not currently support the audit of Python or Ruby
code.)  We believe it to be free of injection
[vulnerabilities](Terms-and-Definitions.md#vulnerability),
such as SQL injection. However, we must acknowledge the possibility of
unknown vulnerabilities lurking in the code or in Rails, Ruby, Python,
or other components of its operating platform. Consequently, we
reiterate that SCALe should not be used on machines that are directly
accessible from the Internet.

Cryptography
------------

The components of SCALe can be partitioned as follows:

1.  Packages distributed with the base Linux distribution (Xubuntu
    18.04)
2.  Packages made available through the Ubuntu 'apt' repositories
3.  External source code that is manually installed
4.  Packages (gems) made available through Ruby's 'gem' mechanism
5.  SCALe code itself. (Note that distributions of SCALe code do not
    include the JUnit tests.)
6.  dos2unix and JasPer, third-party open source code packages developed by third parties
and used for SCALe automated testing during development. This is provided with released SCALe
code along with many other automated test files, to enable others to use our automated tests
as they add new features and bugfixes to SCALe.

The code for (5) is completely developed at CERT and is not open-source
software (OSS). All other software is OSS.

SCALe implements no cryptographic algorithms of its own, but it does use
some algorithms that are included with SCALe (categories 1-4). SCAL'e
cryptographic functionality boils down to the following features:

1.  The web app can be (optionally) configured to use HTTPS (it defaults
    to HTTP)
2.  Exported SCALe databases can be "sanitized", which hashes sensitive
    data so that it can be moved outside of a trusted domain.

Here are the properties of the package that implements the HTTPS
feature, optionally used by SCALe:

| Component |Version | Category |
|:---:|:---:|:---:|
|[OpenSSL](https://www.openssl.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 1.0.2g-1ubuntu4.10 | 1 (this version was distributed with the base Linux distribution, a different version may be distributed with the current Ubuntu 18.04 distribution) |

The sanitizer technically performs one-way hashing, rather than
encryption. That is, data is modified with no expectation of being able
to restore the original data (outside the trusted domain). Here are the
properties of the software that provides the cryptography used by the
sanitizer:

|Algorithm | Component | Version | Category |
|:---:|:---:|:---:|:---|
| SHA-256 | [Python](https://www.python.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) (the "hashlib" library) | 2.7.11-1 | 1 (version specified was distributed with the previous Ubuntu 16.04 distribution, a different version may be distributed with the current Ubuntu 18.04 distribution) |

Other software provides cryptography features, but they are not used by
SCALe. For example, the SHA-256 algorithm is also provided by ruby, but
not used directly by SCALe:

| Algorithm       | Component       | Version         | Category        |
|:---:|:---:|:---:|:---:|
| SHA-256         | [Ruby](https://www.ruby-lang.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 1:2.3.0+1 | 2 (made available through the Ubuntu 'apt' repositories. (version specified was distributed with the Ubuntu 16.04 Linux distribution, a different version may be distributed with the current Ubuntu 18.04 distribution)) |

On a related note, the only software package that must be manually
installed is the following (which uses no cryptography)

| Component |Version | Category |
|:---:|:---:|:---:|
| [GNU Global](http://www.gnu.org/software/global/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) | 6.5.1 | 3 (works with Ubuntu 18.04 distribution) |

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Introduction.md)
[![](attachments/arrow_up.png)](Welcome.md)
[![](attachments/arrow_right.png)](User-Roles.md)
