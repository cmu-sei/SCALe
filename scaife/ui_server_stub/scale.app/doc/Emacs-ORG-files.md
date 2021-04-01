---
title: 'SCALe : Emacs ORG files'
---
 [SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Audit Instructions](Audit-Instructions.md)
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

SCALe : Emacs ORG files
========================

ORG files are a type of text file supported by
[Emacs](https://www.gnu.org/software/emacs/emacs.html){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)'s
[org-mode](http://orgmode.org/){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).
 For more information on ORG files, you
can type `<ctrl>-h f org-mode` in Emacs.

In this process, you extract subsets of the alerts into an ORG
file. You can then update the ORG file manually in Emacs and incorporate
your updates back into the database.

An ORG file looks like a raw text file (and can be modified with any
text editor), but Emacs provides several useful conventions with ORG
files:

-   Hyperlinks work, and ORG files in SCALe provide hyperlinks directly
    into the source code you are auditing.
-   The file is stored as an outline, and you can expand and collapse
    various outline headings by using the `Tab` key when the cursor is
    on a heading.
-   The file contains tables, which consist of text beginning and ending
    with | characters. Hitting `Tab` while the cursor is in a table will
    cause the table columns to be aligned properly.

There are three scripts you can use to handle ORG files:

1. The `     scale2csv.py   ` script produces an ORG file from a SCALe
database. It can provide all the alerts, or a subset of all
alerts. It assumes you are in the `$SCALE_HOME/scale.app/scripts`
directory.

```sh
./scale2csv.py --output org --link org <db> [--constraint <select-arg>]? > <org-file>
```

If you provide a `<select-arg>` it should be some SQL selection
constraint, such as `checker='MSC30-C'`. If you provide
no `<select-arg>,` all the alerts are returned.

If you put the ORG file into the top directory of your source tree, then
its hyperlinks properly send you into the source files referenced by the
alerts. You can therefore examine the code associated with each
alert quickly.

2. The
[csv2scale.py](Back-End-Script-Design.md#csv2scale.py)
 script updates a SCALe database from an ORG file.

```sh
./csv2scale.py --input org < <org-file> | sqlite3 <db>
```

The ORG file should have been created by `scale2csv.py`. In fact, its
table need only have 3 columns: the alert ID, the flag, and the
verdict. All subsequent columns are ignored. The script updates each
alert with the flag and verdict from the ORG file. Alerts not
in the ORG file remain unchanged.

3. This command produces an ORG file consisting of all the messages
associated with a single alert.

```
./msg.py --output org --link org <db> <alert-id> > <org-file>
```

This is useful for alerts that have multiple messages. Whereas the
other routines only produce one message per alert (said message
also containing a filename and line number), this routine produces all
the messages, producing an ORG table of all the messages. The alert
id it requires is a number, which is available in the ORG files produced
by `scale2csv.py`

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](CSV-file.md)
[![](attachments/arrow_up.png)](Audit-Instructions.md)
[![](attachments/arrow_right.png)](SQL-Dump.md)
