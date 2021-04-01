---
title: 'SCALe : CERT Rosecheckers'
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

SCALe : CERT Rosecheckers
=========================

CERT Rosecheckers is an open-source static analysis tool. It was developed by
the CERT Division to look for violations of the CERT C Coding Standard.

# Installing Rosecheckers

We recommend you install `rosecheckers` using the `Dockerfile`, then run its Docker container.

1.	Install `subversion` (e.g., `sudo apt install subversion`)
2.	Get the code:
`svn checkout https://svn.code.sf.net/p/rosecheckers/code/trunk rosecheckers-code`
3.	Change directories to where the Dockerfile is:
`cd rosecheckers-code/rosecheckers`
4.	Build the container, using the following command. It takes awhile to build because it has to download a lot. One person reports between 30-45 minutes to build the container on an Ubuntu 20.04 VM with 30GB memory.
```
    docker build -t rosecheckers . 
```

# Running Rosecheckers

The two main ways to run rosecheckers are (1) by hooking into  `gcc/g++` and (2) by using the shell log method. This section also provides technical detail required to use these methods and examples of running `rosecheckers`.

Detail: The `rosecheckers` command takes the same arguments as the GCC compiler,
but instead of compiling the code, `rosecheckers` prints alerts. To
run `rosecheckers` on a single file, pass `rosecheckers` the same arguments
that you would pass to GCC. You do not have to explicitly specify
warnings to GCC like you do when harvesting its output, as
specified [here](GCC-Warnings.md). 

## Method 1: Hook into `gcc/g++`

Hook into `gcc/g++` as follows:

   a. Copy the text from the following file from `scale.app` on GitHub: https://github.com/cmu-sei/SCALe/blob/scaife-scale/scaife/ui_server_stub/scale.app/scripts/gcc_as_rosecheckers 
   b. Put that text into 2 new files you create, named `gcc` and `g++` as follows, within the directory structure you downloaded for rosecheckers. Use the editor `nano` to paste the text and save it into the new files:
        * `apt install nano`
        * `nano rosecheckers-code/rosecheckers/gcc`
        * `nano rosecheckers-code/rosecheckers/g++`
   c. Make the renamed-script files executable: `chmod 700 rosecheckers-code/rosecheckers/g++; chmod 700 rosecheckers-code/rosecheckers/gcc` 
   d. Modify the copy/pasted text in the 2 new files where it initially specifies the filepath as `/home/rose/src/rosecheckers/rosecheckers`
   e. Make the filepath correct for the container, so edit the line to read: `/usr/bin/rosecheckers $ROSEARGS`
   f. Modify a second line in the copy/pasted text only in the new `g++` file, where it initially specifies the filepath as `/usr/bin/gcc`  That’s the correct filepath in the container to gcc but you should change it for `g++` at `/usr/bin/g++`
   g. Add the path to the scripts to the `PATH` variable:
       * `export PATH=/usr/rosecheckers:$PATH`
   h. Perform a normal build, and redirect the raw output into a text file. (To do this step, see section below about how to run `rosecheckers` with a mounted external source volume.)

## Sample Run

You should hook into `gcc/g++` prior to doing the sample run.
For running rosecheckers on a single file, do the following (example on a single file below named `example.c` )

  * `docker run -it rosecheckers rosecheckers example.c`


## Method 2: Shell Log

In this approach, you run the normal working build, but log raw text
output produced by `make`. Use that output to build a shell script that
runs rosecheckers on the same files built by GCC. Follow these steps:

  * Build a `makelog` file, which captures standard output and error
    from a successful build. (This assumes that your build process
    prints the commands it executes, which is the default behavior
    of `make`). A suitable command to generate the text data for an example project
    that has a Makefile that builds `all` is:
    ``` 
    make all >&makelog
    ```
  * Run `$SCALE_HOME/scripts/demake.py` on the `makelog` file, which
    prunes out the '`make`' commands and directory changes.
    ```
    python demake.py < makelog > output
    ```
  * Prune out lines with `:`(they indicate warnings and errors). You could use the following command, which does a per-file search (the `f` of `fgrep`) that inverts matched lines (inversion specified by the `-v` parameter) :

    ```
    fgrep -v : < output > cleaned_up_output
    ```
  * Remove any other lines that would break this shell script.
  * Substitute `rosecheckers` for each occurrence of `gcc` or `g++`, as follows:
    ```
    sed 's/gcc/rosecheckers/' cleaned_up_output > script_that_runs_rosecheckers_for_gcc
    sed 's/g++/rosecheckers/' script_that_runs_rosecheckers_for_gcc > script_that_runs_rosecheckers.sh
    ```
  * Run Bash on the shellscript, and save the output in a text file.
    ```
    ./script_that_runs_rosecheckers.sh >&output_from_rosecheckers.txt
    ```

## Using One of the Two Run Methods in a Container

The technique for using either a hook into `gcc/g++` or a shell log method inside a container is the same as for using it outside a container. First issue the command `docker run -it <other-args> rosecheckers bash`, and then in the container's bash shell do either the `gcc/g++` hook or the shell-log method as described above.

### Running Rosecheckers with a Mounted External Source Volume

Do the following to run the rosecheckers container on your codebase (consisting of multiple files), which will mount a shared volume (sharing the codebase files between the container and your local machine):

 * `export MY_PROJECT=/path/to/my/project/on/host`
 * `docker run -it -v ${MY_PROJECT}:/my_project rosecheckers bash`
 * Then in the bash prompt:
   * `cd /my_project`
 * Next, run `rosecheckers` using Method 1 or Method 2 described above.
   * Method 1: Build the project by using the script(s) you named `gcc` and/or `g++` on your code project. The script will also run rosecheckers. 
     * `gcc file1.c file2.c file3.c file4.c`
   * Method 2: Build the project using the shell-log method for Makefiles, described in the section above.

Finally, `exit` or `logout` or `ctrl-d` in bash exits bash and removes the container (but leaves the image intact).

### Projects with Extra Dependencies Needed in the Rosecheckers Container

Note: All of the above assumes that your project will build in the `rosecheckers` container, which runs Ubuntu 18 (bionic). If you need extra dependencies, such as `clang`, you can `apt install` them in the container. Or, you could modify the `Dockerfile` if you want those extras included in the image (and all subsequent container)


## Substitution: Replace GCC with Program that Runs GCC and Rosecheckers (`gcc-and-sa`)

In this approach, you replace GCC (or `g++`) with a program that both runs GCC (or `g++`)
and your static-analysis tool (`rosecheckers`, in this case), using the
`$SCALE_HOME/scale.app/scripts/gcc-and-sa` script. It runs both `gcc` (or `g++`) and
`rosecheckers` with the arguments given to it. 

There are several approaches to using `gcc-and-sa`:

#### FIRST approach to using `gcc-and-sa`: Fool build system with renaming and path

A FIRST approach is to fool the build system without telling it that it is not directly calling `gcc`. To do this:

  * Rename this script to
    `gcc` and ensure it is in your
    `$PATH`, so when
    your build system invokes `gcc`, it really invokes `gcc-and-sa` instead.
  * Make the renamed-script files executable (`chmod 700`)
  * You must modify the line with the `rosecheckers` command, to provide
    the correct path on your own machine. (As of 01/08/2021, the script currently 
    has the hardcoded path `/home/rose/src/rosecheckers/rosecheckers`)
  * Then perform a normal build, and redirect the raw output into a text
    file.

### SECOND approach to using `gcc-and-sa`: set compiler to `gcc-and-sa`

The SECOND approach: If your build system lets you override the compiler, you simply
execute the build system setting the compiler to `gcc-and-sa`:

```
make CC=$SCALE_HOME/scale.app/scripts/gcc-and-sa all
```

If you are using the C++ compiler, you would tweak the `gcc-and-sa` script to call
`g++` instead of `gcc`.

# Formatting Output For SCALe

The approaches described above result in a text file. This file
can be uploaded to the SCALe web application.


------------------------------------------------------------------------

[![](attachments/arrow_left.png)](GCC-Warnings.md)
[![](attachments/arrow_up.png)](Static-Analysis-Tools.md)
[![](attachments/arrow_right.png)](Coverity-Prevent.md)
