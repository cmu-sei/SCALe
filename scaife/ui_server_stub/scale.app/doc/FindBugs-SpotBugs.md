---
title: 'SCALe : FindBugs / SpotBugs'
---
 [SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Audit Instructions](Audit-Instructions.md) / [Static Analysis Tools](Static-Analysis-Tools.md)
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

SCALe : FindBugs™ / SpotBugs
============================

FindBugs™ is an open-source static analysis tool. SpotBugs is intended
to be a replacement for FindBugs and provides the same API and output
checkers. Their different categories of alerts are documented  [on
FindBugs™'
website](http://findbugs.sourceforge.net/bugDescriptions.html){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).

In this document, we will refer to findbugs to indicate either FindBugs or SpotBugs.

Each tool only operates on Java `.class` files, so you must first build
your codebase.

Command Line
------------

The commands to run findbugs are:

```sh
$FINDBUGS_HOME/bin/findbugs  -textui  -low  -progress  -xml:withMessages  -xargs < cp.txt  -output findbugs.xml
$FINDBUGS_HOME/bin/spotbugs  -textui  -low  -progress  -xml:withMessages  -xargs < cp.txt  -output findbugs.xml
```

This produces an XML file of findbugs alerts.

If findbugs runs out of memory, you can instruct it to use more with
these arguments: `-jvmArgs "-Xmx2048m"`

The `cp.txt` input file indicates the classpath (that is, Jars and
source directories) that findbugs should analyze. The input file should
contain the absolute pathname of one jar file per line. These commands
in a source directory might produce a sufficient `cp.txt` file:

```sh
find . -name classes -print > cp.txt
find . -name \*.jar -print >> cp.txt
find ~/.m2/repository -name \*.jar -print >> cp.txt
```

GUI
---

Once you have invoked the appropriate GUI, select `File->New Project`.
Then provide locations for class files, auxiliary classes, and source
files. For auxiliary classes, you can select multiple jars at once.Then
let findbugs do its analysis.

Maven
-----

findbugs is already integrated with Maven. To run findbugs on a Maven
project, you must  integrate findbugs into the top-level `pom.xml` file.
To do this, follow the use case scenario 3 in this
[internet tutorial](http://www.petrikainulainen.net/programming/maven/findbugs-maven-plugin-tutorial/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png),
and build the project. The directory tree will become peppered
with `findbugsXml.xml` files.

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Eclipse.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](Perl-Critic.md)

Attachments:
------------

![](images/icons/bullet_blue.gif)
[project.txt](attachments/project.txt) (text/plain)
