---
title: 'SCALe : GCC Warnings'
---
 [SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md) / [Audit Instructions](Audit-Instructions.md) / [Static Analysis Tools](Static-Analysis-Tools.md)
<!-- <legal> -->
<!-- SCALe version r.6.7.0.0.A -->
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

SCALe : GCC Warnings
=====================

Although GCC is primarily used as a compiler, it can produce useful
warnings. The `-Wall` option turns on most (not all) warnings.

The goal of the steps below is to do a complete build of the codebase
while passing GCC arguments to turn on the useful warnings, and to then
capture the build output into a file. You must be able to perform a
complete build from the command line. Here is an example command:

```sh
make all 2>&1 > makelog
```

However, unless GCC was configured in the makefile to output all
warnings, this does not produce the correct output. The makefile should
provide GCC with the correct arguments before doing a build, using the
following flags:

```
-std=c11 -O2 -fmessage-length=0 -Wall -Wextra -Wpointer-arith -Wstrict-prototypes -Wformat-security -pedantic
```

If you are using G++, the makefile should instead have the
following flags:

```
-std=c++14 -O2 -fmessage-length=0 -Wall -Wextra -Wpointer-arith -Wformat-security -pedantic
```

Formatting Output For SCALe (1)
---------------------------

Once you have raw output from a build (for example, the output from
`make all`, gathered by the command at the top of this page), you
may want to run the `demake` script on the output. The `demake` script
helps to identify directory changes so that source code can be properly
found in the codebase.  You can then upload this file
`gcc_results.txt` to the SCALe web application:

```sh
$SCALE_HOME/scripts/demake.py < makelog > gcc_results.txt
```

Formatting Output for SCALe (2)
---------------------------

If you have multiple files:

* If the files are in a zipfile together, unzip the file `<MULTIPLE_FILES>.zip`
* Then run script `scale.app/scripts/helper_scripts/cat_tool_output.py` on the directory, to create a single ".txt" file containing the combined tool output
* Use this single file as the GCC tool output, for input to the SCALe project


------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](CERT-Rosecheckers.md)
