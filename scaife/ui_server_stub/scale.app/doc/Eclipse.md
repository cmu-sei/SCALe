---
title: 'SCALe : Eclipse'
---
 [SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) [Audit Instructions](Audit-Instructions.md) / [Static Analysis Tools](Static-Analysis-Tools.md)
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

SCALe : Eclipse
================

Eclipse is an IDE with an incremental compiler built-in. It does not
rely on any external Java compiler, although it does use an external JRE
for debugging programs and to run Eclipse itself.

Running the Eclipse compiler from within the Eclipse IDE
---------------------------------------------------------

Before analyzing any project under Eclipse, be sure to turn on all
Eclipse warnings.  Eclipse by default shows only the first 100 warnings.
You'll need to increase the
`Use Marker Limits` setting to see all the
warnings; it is buried in
`View->Preferences` .

The warnings columns should appear in this order:
`Type Path Description Location Resource` . If the columns are not in
this order, you must reconfigure Eclipse's `Problems`  tab. Do this by
selecting the  `View`  menu in the  `Problems`  view. Then choose
`Configure Columns...`  and re-order the columns to match the specified
order.

Then build your codebase. If Eclipse builds automatically for you, then
you'll need to clean the project, in which case Eclipse will rebuild the
code.

### Formatting Output For SCALe

Once all warnings have appeared under the `Problems` view, select `All`
and then `Copy` from that view's context menu. From the main menu,
select `File->New->Untitled Text File`. Paste the warnings into that
text file, and save it. This is your Eclipse output for SCALe.

Running the Eclipse compiler from the command line
--------------------------------------------------

To run the Eclipse compiler from the command line, perform one of the
following two options:

-   Use the Eclipse instructions for compiling code in the [Using the Batch compiler section.](http://help.eclipse.org/neon/index.jsp?topic=%2Forg.eclipse.jdt.doc.user%2Ftasks%2Ftask-using_batch_compiler.htm){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) Download
    the ecj.jar file from the link provided, verify the file's hashcode
    before using, then run using a command like the following one:

`java -jar <PATH_TO_ECJ_FILE> -warn:all <FILENAME_TO_COMPILE>`

For example:

`java -jar ~/opt/eclipse4.8_jar_only/ecj-4.8.jar -warn:all Vector.java`

-   Use the Eclipse instructions for compiling code in the [Using the ant javac adapter](http://help.eclipse.org/neon/index.jsp?topic=%2Forg.eclipse.jdt.doc.user%2Ftasks%2Ftask-ant_javac_adapter.htm){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png) section

### Formatting the command-line output to SCALe format

To order the warning data from the command-line Eclipse compiler into
tab-separated format for SCALe:

1.  Save the command-line output into a `.txt` file
2.  Using a Python script called '`eclipse_convert.py`' which is located
    in \$SCALE\_HOME/`scale.app/scripts`, convert the command-line
    output into a tab-separated format.
    1.  Before running the script, edit the path of command-line output
        file to your path.
    2.  The first field for each row is automatically injected, using a
        mapping+heuristic from the file suffix to a phrase describing a
        problem type. This mostly provides the same problem type phrase
        given from the Eclipse IDE (GUI) method, but it's possible the
        phrases won't always be the same.

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Understand.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](FindBugs-SpotBugs.md)
