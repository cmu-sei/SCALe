---
title: 'SCALe : CSV file'
---
[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Audit Instructions](Audit-Instructions.md)
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

SCALe : CSV file
=================

You can extract data from an SQL database into comma-separated-values
(CSV), which is useful for importing into Excel or any other spreadsheet
application. To do this, you will use `     scale2csv.py, which `is
located in the `$SCALE_HOME/scale.app/scripts` directory of the SCALe
web app.

```sh
scale2csv.py <db> --constraint <select-arg>? --link excel --prefix <prefix> > <csv-file>
```

You'll have to provide selection arguments, of course.

You can also insert links to a Web server (or the local filesystem) into
this table. You will use
[GNU Global](http://www.gnu.org/software/global/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) to build
web pages out of a source tree. To do this, go to your source directory
and type

```sh
htags -aghnosTx --show-position
```

This creates an `HTML` subdirectory with the web pages. (You could now
remove the source code; the HTML pages are independent of the source
code.)

You'll also need to provide a `<prefix>` argument to `scale2csv.py`.
This is a URL each link in the spreadsheet will point to. It directs
your web browser to your source directory. The links all then point
inside the `HTML` subdirectory in your source directory.

To update your database with modified data, you can use this command.

```sh
./csv2scale.py < <csv-file> | sqlite3 <db>
```

It constructs several `SQL UPDATE` statements, which updates the
database with your new verdicts and flags (from the CSV file). Any other
fields are ignored.

Occasionally, you will encounter a alert with multiple messages
associated with it, but the table you get shows only one 'primary'
message. This command produces a CSV file consisting of all the messages
associated with a single alert.

```sh
./msg.py --link excel --prefix <prefix> <db> <alert-id> > <csv-file>
```

This is useful for alerts that have multiple messages. Whereas the
other routines only produce one message per alert (said message
also containing a filename and line number), this routine produces all
the messages, producing a CSV table of all the messages. The alert
ID it requires is a number which is available in the CSV files produced
by `scale2csv.py`.

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Cascading-Determinations-from-Old-Codebase-to-New-Codebase.md)
[![](attachments/arrow_up.png)](Audit-Instructions.md)
[![](attachments/arrow_right.png)](Emacs-ORG-files.md)
