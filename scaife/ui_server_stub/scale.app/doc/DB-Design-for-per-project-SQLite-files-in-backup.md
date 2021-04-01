---
title: 'SCALe : DB Design for per-project SQLite files in backup'
---
[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md)
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

SCALe : DB Design for per-project SQLite files in backup
=========================================================

When a new SCALe project is created using the SCALe GUI, a new
SQLite-formatted file (each named "`db.sqlite`") is created in a folder
named with an integer (increases by 1 with each new project), in
the `scale.app/archive/backup` directory. E.g,:

-   `$SCALE_HOME/scale.app/archive/backup/1/db.sqlite`
-   `$SCALE_HOME/scale.app/archive/backup/2/db.sqlite`

Since every project has a unique ID, below we use the `$PROJECT`
variable to represent a particular project ID, eg:

-   `$SCALE_HOME/scale.app/archive/backup/$PROJECT/db.sqlite`

The internal format of these database files is the same as for [Exported
Database Design](Exported-Database-Design.md).

### Creating a new project

This process is also done when a project is edited:

> update db/development.sqlite3 -&gt; db/external.sqlite3\
> copy db/external.sqlite3 -&gt;
> db/backup/\$PROJECT/external-\`timestamp\`.sqlite3\
> load SA-output -&gt; archive/backup/\$PROJECT/db.sqlite\
> copy archive/backup/\$PROJECT/db.sqlite -&gt; db/external.sqlite3\
> copy db/external.sqlite3 -&gt; db/backup/\$PROJECT/external.sqlite3

### Uploading a new database

This is done when the user selects "Create DB".

> upload -&gt; archive/backup/\$PROJECT/db.sqlite\
> copy archive/backup/\$PROJECT/db.sqlite -&gt; db/external.sqlite3\
> update db/external.sqlite3 -&gt; db/development.sqlite3\
> copy db/external.sqlite3 -&gt; db/backup/\$PROJECT/db.sqlite

### Exporting a database

This is done when the user selects 'Export DB'.

> copy db/backup/\$PROJECT/external.sqlite3 -&gt; db/external.sqlite3\
> update db/development.sqlite3 -&gt; db/external.sqlite3\
> download db/external.sqlite3

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](DB-Design-for-development.sqlite3.md)
[![](attachments/arrow_up.png)](Welcome.md)
[![](attachments/arrow_right.png)](Notes-on-Languages-vs-Platforms.md)
