---
title: 'SCALe : LDRA'
---
[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Audit Instructions](Audit-Instructions.md) / [Static Analysis Tools](Static-Analysis-Tools.md)
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

SCALe : LDRA
=============

LDRA is a proprietary static analysis tool. The instructions for
generating textual alerts from LDRA are as follows:

1.  Select `Set` in the menu bar and then `Select/Create/Delete Set`.
2.  In the "`Select/Create Set`" text box, enter a name for the set.
3.  Press `Enter` and select `group`.
4.  Select `Add/Remove Source Files`.
5.  There should now be a visible set of C/C++ files from the codebase.
    Add all the files in the set.
6.  Press `F2` or select `Analysis/Select Analysis` to open the analysis
    window.
7.  Select `Start analysis` to start the analysis.
8.  If the selected file has any `#include` statements and the file is
    not found, then it opens an interactive include file analysis dialog
    window. In this dialog window, you should select the folders where
    the include files are located.
9.  Once all files are found, the analysis starts and a dialog box
    appears, indicating that the file analysis is complete.

For MS Visual Studio projects, the only deviation from these
instructions is that you need to select the project `.sln` (solution)
file.

Formatting Output For SCALe (1)
-------------------------------

Once the analysis is complete, you can create the file to be used by
SCALe by doing the following, in the LDRA GUI:

1.  Select `Group Results` and then
    `Text Results/Analysis Scope Report.`
2.  Select `Group Results` and then
    `Text Results/Code Review Report(ASCII)`.
3.  Save the two results and concatenate them into one file. This can be
    accomplished by opening both files in Notepad on Windows, selecting
    the contents of the code review report, and copying and pasting them
    to thend of the analysis scope report.  In Linux you could simply
    use the `cat` command:

    ```sh
    cat analysis_scope_report.txt code_revew_report.txt > ldra_results.txt
    ```

Formatting Output for SCALe (2)
-------------------------------

If you have multiple .rpf files:

* If the files are in a zipfile together, unzip the file `<MULTIPLE_RPF_FILES>.zip`
* Then run script `scale.app/scripts/helper_scripts/cat_tool_output.py` on the directory, to create a single ".rpf" file containing the combined tool output
* Use this single file as the LDRA tool output, for input to the SCALe project

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](PC-Lint-FlexeLint.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](Parasoft.md)
