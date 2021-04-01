---
title: 'SCALe : PC-Lint / FlexeLint'
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

SCALe : PC-Lint / FlexeLint
===========================

PC-Lint is a proprietary static analysis tool produced by Gimpel
Software, to run on Windows. FlexeLint is a port of PC-Lint which runs
on Linux. Both programs use the same categories of alerts, which
are documented [on Gimpel's
website](http://www.gimpel-online.com/MsgRef.html){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).

Running PC-Lint
---------------

PC-Lint can be run with projects in MS Visual Studio. To run PC-Lint on
a project:

1.  Open Visual Studio (either 2010 or 2013).
2.  Select `Tools->Visual Studio Command Prompt`
3.  In the console, go to the project directory. (You can learn the
    project directory by right-clicking on an open file's header tab,
    and selecting Open Containing Folder.)
4.  Enter the following:

```sh
c:\lint\lint-nt.exe <project>.vcproj > project.lnt
c:\lint\lin.bat -w4 env-vc10.lnt project.lnt > pclint
```

These commands will not work in PowerShell or Cygwin terminal!

Running FlexeLint
-----------------

FlexeLint can be run with projects in Linux. To run FlexeLint on a source file, use this command:

 ```sh
flint -i ~/flint/lnt ~/flint/lnt/co-gcc.lnt sourcefile.c
```

Formatting Output For SCALe (1)
-------------------------------

This can be done in Cygwin or a Linux machine that has the codebase's
source tree (including PC-Lint output). Go to a parent directory of all
the `pclint` files, and run:

```sh
for file in `find . -name pclint -print`; do
  mv $file pclint/`echo $file | perl -p -e 's|^\./||; s|/|_|g; s|_pclint|.txt|;'`
done
```

This collects all the output files into a single pclint directory. It
works because `_` is never used in a directory name, so it serves as a
good pathname separator.

Finally, you will need to combine all the resulting text files to
produce a single text file, and we do not currently provide a script
that combines those files.

Formatting Output for SCALe (2)
-------------------------------
If you have multiple .result files:

 - If the files are in a zipfile together, unzip the file `<MULTIPLE_RESULT_FILES>.zip`
 - Then run script `scale.app/scripts/helper_scripts/cat_tool_output.py on the directory`, to create a single ".result" file containing the combined tool output
 - Use this single file as the PC-Lint tool output, for input to the SCALe project

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Microsoft-Visual-Studio-Static-Analyzer.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](LDRA.md)
