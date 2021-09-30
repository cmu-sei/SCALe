---
title: 'SCALe : Clang'
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

SCALe : Clang
==============

Introduction
------------

Clang is a C/C++ compiler that uses the LLVM framework for
optimization. Clang is open-source software available under a [permissive
license](https://opensource.org/licenses/NCSA){.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png).
You can read more about Clang at its project page:
<https://clang-analyzer.llvm.org/>{.extlink}![(lightbulb)](images/icons/emoticons/lightbulb_on.png)

As a compiler, Clang can output warnings and errors to the standard
error stream. These warnings and errors are called
"diagnostics" in Clang and "alerts" in SCALe.

Clang also includes a static analyzer, which can be invoked in several
ways. The simplest way to invoke the static analyzer is to use the
`scan-build` tool, which is documented
[here](https://clang-analyzer.llvm.org/scan-build.html).  It runs
Clang's static analyzer, which runs the AST section of Clang's
compiler. It also runs your native compiler (if not Clang) to compile
the code.  This means that `scan-build` emits compiler alerts for Clang
and your native compiler to standard error. But the primary output of
`scan-build` is its static-analysis (SA) alerts, which you should export 
in the form of an Apple-style property list (`.plist`) for use in SCALe.
Both compiler alerts and SA alerts can be imported into SCALe.

No tool invocation catches "everything" (see the "Bzip2 Tool Output"
section for illustration). We recommend using the Clang
compiler, with a few flags to maximize its warnings, to generate
compiler alerts.  And we recommend using `scan-build` to generate
static-analysis alerts.  (We also recommend ignoring the alerts
that `scan-build` emits on standard error, as these can be obtained
using the Clang compiler or your native compiler.)  Below, we discuss
each output in turn. For each one, we provide an example of how
to produce output for a single file (called `src_file.c`), and how to
produce output for a whole project using `make`.


Static-Analysis Alerts
----------------------

To create clang static-analysis alerts, you should first create this
target directory:

```sh
mkdir /tmp/clang_oss.out
```

To populate the target directory with alerts from a project that is
built with  `make`:

```sh
scan-build -plist -o /tmp/clang_oss.out    make
```

To populate the target directory with alerts from just one file:

```sh
scan-build -plist -o /tmp/clang_oss.out    clang source_file.c
```

Finally, the output should be bundled into a ZIP file:
```sh
cd /tmp/clang_oss.out
zip -r clang_oss.out.zip  *
```

The ZIP file can then be loaded in to SCALe using the `clang_oss` tool.


Compiler Alerts
---------------

To create clang compiler, you will use these flags:

```sh
export CFLAGS="-std=c11 -O2 -fmessage-length=0 -Wall -Wextra -Wpointer-arith -Wstrict-prototypes -Wformat-security -pedantic"
```

To build a project using `make`:

```sh
make CC=clang CFLAGS=$CFLAGS |& tee makelog.txt
```

To build just one file:

`clang $CFLAGS source_file.c |& tee makelog.txt`

The `makelog.txt` file can then be loaded in to SCALe using the
`clang_compiler_oss` tool.


Bzip2 Tool Output
-----------------

The set of compiler alerts produced by `clang`, compiler alerts
produced by `scan-build` and SA alerts produced by `scan-build` are
all distinct.  To illustrate this, we used Clang 6.0 tools `clang`,
`scan-build`, and `clang-tidy` using several argument combinations on
the `bzip2` open-source tool, to see which alerts each generates. Our
results are shown in the table in the "Bzip2 Tool Output" section.


| Description       | File                    | Command                    | decompress.c:198 | bzlib.c:102 | bzip2.c:1073 | bzip2.c:1073 | bzlib.c:1431 | compress.c:170 | compress.c:225 |
|-------------------|-------------------------|----------------------------|------------------|-------------|--------------|--------------|--------------|----------------|----------------|
| Clang Alerts      | clang_compiler_oss.txt  | clang ${CFLAGS}            |                  | x           | x            |              | x            |                |                |
| Scan-build Alerts | clang_oss_scanbuild.txt | scan-build clang           |                  |             |              | x            |              | x              | x              |
|                   |                         | scan-build clang ${CFLAGS} | x                |             | x            |              |              | x              | x              |
| Scan-build Alerts | clang.oss.out.zip       | scan-build -plist -o dir   |                  |             |              |              |              | x              | x              |
| clang-tidy alerts | clang_tidy_oss.txt      | clang-tidy *.c             |                  |             |              |              |              | x              | x              |


For the commands that used `${CFLAGS}`, here are the flags that were
provided:
`export CFLAGS="-std=c11 -O2 -fmessage-length=0 -Wall -Wextra -Wpointer-arith -Wstrict-prototypes -Wformat-security -pedantic"`

| Heading     | Definition                                                      |
|-------------|-----------------------------------------------------------------|
| Description | How we shall refer to this output                               |
| File        | File in scale.app/demo/bzip/analysis with output                |
| Command     | Clang command that was run on each source file                  |
| Remaining   | A file name & line number where an alert might have been issued |

The remaining headings, along with the details of their alerts are as follows:

| Heading          | Alert Details                   |
|------------------|---------------------------------|
| decompress.c:198 | Code might "fall through"       |
| bzlib.c:102      | Unused parameter                |
| bzip2.c:1073     | "fchown()" not declared         |
| bzip2.c:1073     | "fchown()" returns value unused |
| bzlib.c:1431     | integer-to-pointer conversion   |
| compress.c:170   | "Garbage value"                 |
| compress.c:225   | Value that is never read        |

Each marked cell indicated that the alert appeared in the command's
output.

As you can see, no tool invocation caught "everything". We therefore
elected to support both types of output (compiler, SA) in
SCALe.

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Cppcheck.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](CodeSonar.md)
