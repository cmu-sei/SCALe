# Source Code Analysis Lab (SCALe)
----------------------------------
Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See the ./COPYRIGHT file for details.


## Installation Instructions (VM)

If the SCALe web app is provided via a virtual machine (VM), then the SCALe app will be configured to run automatically when the machine boots.

## Installation Instructions (Zip)

If the SCALe web app is provided via a zip archive, it is referred to as <scale_webapp_archive>.zip below. This archive should be extracted on your web app server in a location of your choosing.

We will refer to this location as SCALE_HOME. You may find it useful to define this environment variable in your system to point to the root of your SCALe installation. 

If the zip is downloaded from Github, the scale.app folder will be inside another folder like "SCALe-Master". In this case, SCALe-Master would be the location of SCALE_HOME.

Extracting the archive might look something like this:

```shell
export SCALE_HOME="/location/of/SCALe/install"
mkdir -p $SCALE_HOME
cd $SCALE_HOME
unzip /location/of/<scale_webapp_archive>.zip
```


Use the instructions for installing and managing SCALe by opening the following file in a web browser:

```shell
$SCALE_HOME/scale.app/public/doc/index.html
```

If you are running the offline version, the SEI CERT Coding rules and the Common Weakness Enumeration (CWEs) that accompany the distribution may not be up-to-date.
The current version of the SEI CERT Coding rules are available online at:  https://securecoding.cert.org
The current version of the CWEs is available at: https://cwe.mitre.org/


## Relevant Known Issues

* During the quick start demonstration, the following superfluous error is generated in the web app console: ".../scale.app/archive/backup/6/analysis/...out: no such file or directory".

* The digest_diagnostics script does not follow symlinks in source directories.

* The pathnames in Rosecheckers output are incorrect when executed on a project that compiles files outside of the directories they live in. This affects the web app's ability to display the source code associated with a diagnostic.

* Some of the links in the exported secure coding rule documentation point to online pages, and will fail on a machine with no Internet connection.

## Support

Questions and comments can be sent to [info@sei.cmu.edu](mailto:info@sei.cmu.edu).
