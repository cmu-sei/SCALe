#!/usr/bin/env python3
#
# This is an interactive script that works in conjunction with a user
# interacting with the SCALe interface to see CI-enabled projects
# receive updated alerts from SCAIFE. This script is meant to be run
# from the docker *host* machine, not from within a container. This
# script uses a SCALe automation script to create and upload a
# CI-enabled project:
#
#  scale.app/scripts/automation/create_scaife_ci_project_for_local_demo.sh
#
# It then uses the SCAIFE CI demo to create a git repository local to
# the datahub with two different versions of the code. CI update calls
# are simulated to trigger SCAIFE to do a code analysis and generate
# alerts and meta-alerts for the project/package:
#
#  scaife/datahub_server_stub/scripts/ci_demo.py
#
# As the script is running it will pause in the appropriate places and
# ask the user to reload/interact with the SCALe project page in order
# for SCALe to receive the SCAIFE-generated alerts and meta-alerts.
#
# <legal>
# SCALe version r.6.7.0.0.A
# 
# Copyright 2021 Carnegie Mellon University.
# 
# NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING
# INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON
# UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR
# IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF
# FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS
# OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT
# MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT,
# TRADEMARK, OR COPYRIGHT INFRINGEMENT.
# 
# Released under a MIT (SEI)-style license, please see COPYRIGHT file or
# contact permission@sei.cmu.edu for full terms.
# 
# [DISTRIBUTION STATEMENT A] This material has been approved for public
# release and unlimited distribution.  Please see Copyright notice for
# non-US Government use and distribution.
# 
# DM19-1274
# </legal>

import os, sys, re, subprocess
from subprocess import CalledProcessError

import bootstrap
dh_mod = bootstrap.datahub_module()

def pause_for_key():
    input("Press <enter> to continue...")

def run_cmd(cmd):
    try:
        subprocess.run(cmd, stderr=subprocess.STDOUT)
    except CalledProcessError as e:
        print("problem running command:\n", e.output.decode("utf-8"))
        sys.exit(1)

def run_cmd_capture(cmd):
    try:
        out = subprocess.check_output(cmd, stderr=subprocess.STDOUT)
        out = out.decode("utf-8")
    except CalledProcessError as e:
        print("problem running command:\n", e.output.decode("utf-8"))
        sys.exit(1)
    return out

def main():

    print()
    print("""

============================== CI GUI Test =============================

This script is intended to be run from the docker host machine, not from
within any of the docker containers for the SCAIFE modules.

First we'll create a local demo git repository accessible by the Datahub
and SCALe containers.

========================================================================

    """.strip())
    print()
    pause_for_key()
    host_repo_dir = str(bootstrap.tmp_dir.joinpath("ci_demo"))
    dh_repo_dir = "/usr/src/app/tmp/ci_demo"
    scale_repo_dir = "/scale/tmp/ci_demo"
    repo_relpath = "tmp/ci_demo/demo_repo"
    demo_repo_script = \
            str(dh_mod.app_dir.joinpath("scripts/ci_demo_create_repo.py"))
    hash_old = hash_new = None
    tool_out_old = tool_out_new = None
    cmd = [demo_repo_script, "-o", "-v", "-d", host_repo_dir]
    print()
    print("RUNNING:", ' '.join(cmd))
    print()
    out = run_cmd_capture(cmd)
    m = re.search(r"old\s+hash:\s+(\S+)", out)
    if m:
        hash_old = m.group(1)
    m = re.search(r"new\s+hash:\s+(\S+)", out)
    if m:
        hash_new = m.group(1)
    m = re.search(r"old\s+tool\s+out:\s+(\S+)", out)
    if m:
        tool_out_old = os.path.relpath(m.group(1), bootstrap.base_dir)
    m = re.search(r"new\s+tool\s+out:\s+(\S+)", out)
    if m:
        tool_out_new = os.path.relpath(m.group(1), bootstrap.base_dir)
    if not all([hash_old, hash_new, tool_out_old, tool_out_new]):
        print("could not gather repo information")
        sys.exit(1)
    cmd = ["docker", "cp", host_repo_dir, "datahub:%s" % dh_repo_dir]
    print(' '.join(cmd))
    run_cmd(cmd)
    cmd = ["docker", "cp", host_repo_dir, "scale:%s" % scale_repo_dir]
    print(' '.join(cmd))
    run_cmd(cmd)
    print()
    print("""

============================== CI GUI Test =============================

The demo git repository has been created in the Datahub and SCALe
containers.

old git hash: %s
new git hash: %s
old tool output: %s
new tool output: %s

Next we will create a CI-enabled project via the SCALe web API and also
uploade the project/package from SCALe to SCAIFE. Make sure all docker
containers are up and running.

========================================================================

    """.strip() % (hash_old, hash_new, tool_out_old, tool_out_new))
    print()
    pause_for_key()

    cmd = [
        "docker-compose", "exec", "scale",
        "scripts/automation/create_scaife_ci_project.py",
        "-v", "--url", repo_relpath
    ]
    print()
    print("RUNNING:", ' '.join(cmd))
    print()
    out = run_cmd_capture(cmd)
    tool_name = "rosecheckers_oss"
    project = None
    for line in (x.strip() for x in out.split("\n")):
        m = re.search(r"^automation\s+complete:\s+(\S+)", line)
        if m:
            project = m.group(1)
            break
    if not project:
        print("problem parsing output")
        sys.exit(1)
    print(out.strip())
    print()
    print("""

============================== CI GUI Test =============================

Project name: %s
Tool name: %s

The CI-enabled project is now created; we've captured the package access
token in order to simulate the commands a CI server would be sending to
datahub. The next script uses the package token ID and tool ID gathered
from the last step, and initiates the first code analysis with the first
git commit hash and analysis tool output, followed by the second commit
and analysis.

Make sure SCALe is connected to SCAIFE. You can view the SCALe project
page now, but there will be no alertConditions/meta-alerts yet.

The next steps will periodically pause and ask you to reload the project
page and/or interact with the notification that SCAIFE updates are
available.

========================================================================

""".strip() % (project, tool_name))
    print()
    pause_for_key()

    cmd = [
        "docker-compose", "exec", "datahub",
        "scripts/ci_demo.py",
        "--no-create-package",
        "--no-create-repo",
        "--tool", tool_name,
        "--package", project,
        "--output-first", tool_out_old,
        "--output-second", tool_out_new,
        "--hash-first", hash_old,
        "--hash-second", hash_new,
        "--git-url", repo_relpath, # not mandadtory, just for status message
        "--scale"
    ]
    print()
    print("RUNNING:", ' '.join(cmd))
    print()
    run_cmd(cmd)
    print()
    print("""

============================== CI GUI Test =============================

This concludes the integrated test of CI-enabled project alert and
meta-alert updates on SCALe/SCAIFE.

========================================================================

""".strip())

if __name__ == "__main__":
    main()
