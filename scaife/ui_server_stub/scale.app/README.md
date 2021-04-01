# Source Code Analysis Lab (SCALe)

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


# SCAIFE/SCALe HTML manual

Much use, system design, and development information is provided in the included SCALe/SCAIFE HTML manual. To view it, in your web browser open this file location (first starting at SCAIFE home page, second starting at SCALe home page):

* `scaife/ui_server_stub/scale.app/public/doc/scale2/Welcome.html`
* `scaife/ui_server_stub/scale.app/public/doc/scale2/SCAIFE-Welcome.html`


## Installation Instructions (Tarball)

If the SCALe web app is provided via a tarball archive, it is referred to as <scale_webapp_archive>.tgz below. This archive should be extracted on your web app server in a location of your choosing.

This location is refered to in the SCALe install and use manual as `SCALE_HOME`. You may find it useful to define this environment variable in your system to point to the root of your SCALe installation. Extracting the archive might look something like this:

``` shell
export SCALE_HOME="/location/of/SCALe/install"
mkdir -p $SCALE_HOME
cd $SCALE_HOME
tar xzf /location/of/<scale_webapp_archive>.tgz
```


Use the instructions for installing and managing SCALe by opening the following file in a web browser:

``` shell
  $SCALE_HOME/scale.app/public/doc/index.html
```

If you are running the offline version, the SEI CERT Coding rules and the Common Weakness Enumeration (CWEs) that accompany the distribution may not be up-to-date.
The current version of the SEI CERT Coding rules are available online at:  https://securecoding.cert.org
The current version of the CWEs is available at: https://cwe.mitre.org/


## Installation Instructions (GitHub: `scaife-scale` branch)
Start by installing as from the tarball instructions, minus using ```tar`` instructions.
Next, follow GitHub-style SCALe installation instructions provided in the file `scaife/README.md`

You should also be able to do SCAIFE API -related testing by following the instructions in the following technical manual:
https://resources.sei.cmu.edu/library/asset-view.cfm?assetid=644354
"How to Instantiate SCAIFE API Calls: Using SEI SCAIFE Code, the SCAIFE API, Swagger-Editor, and Developing Your Tool with Auto-Generated Code"



## Installation Instructions (GitHub: `main` branch, version of SCALe that does not work with the rest of the SCAIFE system)
Install as from the tarball instructions, minus using ```tar`` instructions.


## Installation Instructions (VM)

If the SCALe web app is provided via a virtual machine (VM), then the SCALe app will be configured to run automatically when the machine boots, except for VMs with Docker containers. Instructions for starting the Docker containers on those types of VMs are provided in the HTML manual at `scale.app/public/doc/scale2/SCAIFE-Server-Management.html` (markdown version [here](doc/SCAIFE-Server-Management.md).

Less relevant but possibly useful: Some information (but not all) that is SCALe-specific about installing SCALe (e.g., changing the user login name and password) that may be useful is located here: `scale.app/public/doc/scale2/Installing-SCALe.html` (markdown version [here](doc/SCAIFE-Server-Management.md).


### SCAIFE System version 1.0.0 (Previous Version) Release VM with Containers

The SCAIFE System version 1.0.0 Release VM includes Docker containers. Installers will find the following information useful:
The release VM is distributed in an approximately 10 GB OVA file.
Once imported (e.g., as a VMWare VM), the VM is approximately 20 GB. The VM itself is set to expand dynamically up to 200 GB disk size, so installers should be careful to make sure that their host machine has sufficient space. (Please keep in mind that the host machine must also have spare disk space for itself, separate from the VM.)
The VM is set to 24 GB RAM memory, and users should increase that if their host machine has sufficient memory. (However, keep in mind that the host machine must also have memory for itself separate from the VM.)


## Contributions from External to SEI

Thank you to all collaborators who contribute code to help us improve SCALe and/or SCAIFE, with new features, bugfixes, and enhancements for DevOps. We hope this section of the README will grow, and invite you to contribute to SCALe/SCAIFE development!

Thank you to:
* Dr. Wei Le and her team at Iowa State University (Benjamin Steenhoek,  Ashwin Kallingal Joshy, Jason McInerney, and Xiuyuan Guo), who contributed SARIF tool output for use in our automated testing infrastructure.

Some code and data used for testing purposes (or as input data) comes from open-source codebases with licenses that allow that, such as the Juliet Test Suite, dos2unix, JasPer, and bzip2. This system uses open-source code and packages with licenses that permit that, and we thank all those many developers who contributed to the software tools we use to build our own systems.


## OpenAPI Version 3 and Auto-Generated Ruby Code

In SCAIFE, we recently switched to use OpenAPI version 3 format (previously we used Swagger version 2 format) for the API definitions. Since doing that, we have auto-generated some of the Ruby code now in SCALe, using SCAIFE APIs.


## Relevant Known Issues

1. Not all of the SCAIFE-connected functionality is integrated. Although this version enables specification of adaptive heuristic type, the adaptive heuristic dataflows have not been fully implemented in this SCAIFE release. The current version does not yet download projects and packages from the SCAIFE DataHub to SCALe (however, the current version does upload them from SCALe to the SCAIFE DataHub).

1. The SCALe/SCAIFE HTML manual has some out-of-date screenshots and some out-of-date instructions. Current collaborators receive special instructions directing them to the relevant HTML pages for use and testing, which we believe have sufficient updates (or are completely up-to-date). In future releases, the HTML manual will be further updated. Ideally, our auto-deployment will auto-update screenshots in the manual.

1. The user-uploaded fields can be used in prioritization formulas, but cannot be viewed in the GUI.

1. During the quick start demonstration, the following superfluous error is generated in the web app console: `.../scale.app/archive/backup/6/analysis/...out: no such file or directory`.

1. The `digest_alerts.py` script does not follow symlinks in source directories.

1. Some of the links in the exported secure coding rule documentation point to online pages, and will fail on a machine with no Internet connection.

1. SCALe language, taxonomy, and tool mappings to SCAIFE languages, taxonomies, and tools cannot currently be deleted since mappings are shared across all projects. The database must be re-initialized for this currently.

1. SCALe language, taxonomy, and tool IDs are assigned during database initialization based on the order they appear in scripts/taxonomies.json, scripts/languages.json, and scripts/tool.json. If new taxonomies, languages, tools, or versions thereof are added, it will potentially skew these ID assignments which might affect project imports.

1. Currently only one user-uploaded data file can be used in SCALe. In the future, handling multiple files (for a single project and for multiple projects) will be enabled.

1. Handling of the Juliet Java and STONESOUP test suite data needs some updates for SCALe and the full SCAIFE system to be able to use all the data. (Previous versions of SCAIFE rapidlcass_scripts code has been able to do that, so the updates needed are not extensive and will be included in a near-future release.)

1. Supplemental determination updates are not always reflected in the GUI immediately, as other `best_in_place` fields are based on meta-alert-id. That will be fixed in a future release.

1. Test suite projects are not currently editable within SCALe.

1. Different Fortify versions should use different checker sets in SCALe, but currently they don't.

1. "`SPECIAL`" checkers in SCALe currently may not be always handled correctly.

1. Some SCALe GUI features may not work on browsers other than Firefox (e.g., Chrome or Microsoft Edge).

1. No field for the checker mappings CSV currently exist in SCALe, though that is required for one of the API calls involving the  SCAIFE UI Module.

1. SCALe (but not the rest of SCAIFE) currently uses Python version 2, but Python version 2 is not officially supported anymore. We have modified most of the SCALe Python code so it works with both Python 3 and Python 2. In the future, SCALe updates to Python 3 need to be completed. 

1. The SCAIFE authentication system will be refactored in the future, to enhance SCAIFE modularity.

1. Scalability, performance (latency, memory use, disk use, processing) improvements, security hardening, and business continuity improvements would be needed to transition the SCAIFE system from research system to widely-usable tool.

1. There is a bug we have detected (yet to be fixed) that occasionally causes a silent SCAIFE failure when meta-alert/alert filepaths don't match filepaths in the source code archive

1. In SCALe, manually-created alertConditions are not fully functional (e.g., they do not export into an exported SCALe database). For current work with this research project, we are not using manually-created alertConditions, so this is a low priority bugfix.

1. The SCALe Vagrant-built VM will not produce a fully-functional SCALe VM anymore. It is missing several Python requirements (in scale.app/requirements.txt). It is also missing Maven, and the dependencies that Maven needs to run Selenium testing.

1. The Selenium sanitizer test currently fails. It needs updates in the reference database, since we've integrated new static analysis tools to work with SCALe.


## Support

Questions and comments can be sent to <scale-support@cert.org>.
