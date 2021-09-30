# Python unit tests
#
# Does not depend on SCALE_HOME, sets it based on pwd, which should be
# scale.app
#
# It would be nice if this test left the output file so can compare
# with answer.

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

import os
import re
import shutil
from glob import glob

import scripts.bootstrap as bootstrap
import util

KEEP_OUTPUT = False

class TestManualProject:

    def create_manual_project(self, src_zip, tool_output,
                              meta_alerts, displays, supplemental=None):
        # guarantee our data is relative to scale.app, not env
        # SCALE_HOME. This also sets/overwrites the env var as well.
        bootstrap.set_env(scale_dir_val=bootstrap.base_dir)
        tmp_dir = bootstrap.get_tmp_dir(ephemeral = not KEEP_OUTPUT,
                suffix="test_cmdline_ruby_scripts", uniq=True)
        scripts_ruby_dir = os.path.join(bootstrap.scripts_dir, "cmdline-ruby")
        if not tool_output.startswith("/"):
            tool_output = os.path.join(bootstrap.base_dir, tool_output)
        if not src_zip.startswith("/"):
            src_zip = os.path.join(bootstrap.base_dir, src_zip)
        # Create empty project, and get project_id from output
        script = os.path.join(scripts_ruby_dir, "create_project.sh")
        cmd = [script, "TestProject", "A test project"]
        output = util.callproc(cmd)
        match = re.search(r"(\d\d*) is the new project id.", output)
        assert match is not None, \
            "no match for project id:\n---\n%s\n---" % output
        project_id = match.group(1)
        # Make sure new project_id is in internal db
        cmd = ' '.join([
            "echo .dump | sqlite3",
            bootstrap.internal_db,
            "| grep -c 'INSERT INTO projects VALUES(%s,'" % project_id])
        output = util.callproc(cmd)
        assert output.strip() == "1"

        # Make testsuite out supplemental data
        if supplemental is not None:
            project_supp_dir = bootstrap.project_supplemental_dir(project_id)
            script = os.path.join(scripts_ruby_dir, "edit_project.sh")
            cmd = [script, project_id, "test_suite_name", '"test_suite"']
            util.callproc(cmd)
            script = os.path.join(scripts_ruby_dir, "edit_project.sh")
            cmd = [script, project_id, "test_suite_version", '12345678']
            util.callproc(cmd)
            for attribute in supplemental:
                script = os.path.join(scripts_ruby_dir,
                    "edit_project_file.sh")
                valpath = os.path.join(bootstrap.scale_dir,
                    supplemental[attribute])
                cmd = [script, project_id, attribute, valpath]
                util.callproc(cmd)
                assert os.path.exists(project_supp_dir)

        # Create GNU Global Archive
        script = os.path.join(scripts_ruby_dir, "create_src_html.py")
        out_zip = os.path.join(tmp_dir, "html.zip")
        cmd = [script, "--out", out_zip, "--tmp-dir", tmp_dir, src_zip]
        util.callproc(cmd)
        assert os.path.exists(out_zip)

        # Upload GNU Global Archive
        script = os.path.join(scripts_ruby_dir, "upload_src_html.sh")
        cmd = [script, project_id, out_zip]
        util.callproc(cmd)
        assert os.path.exists(bootstrap.project_gnu_dir(project_id))

        # Create database
        # (All projects use cppcheck output)
        script = os.path.join(scripts_ruby_dir, "create_database.py")
        tmp_db = os.path.join(tmp_dir, "db.sqlite3")
        cmd = [script, "-t", "cppcheck_oss", "-p", "c/cpp", "-V", "1.86",
                "--tmp-dir", tmp_dir, tmp_db, tool_output, src_zip]
        util.callproc(cmd)
        assert os.path.exists(tmp_db)
        # Count meta-alerts generated
        cmd = "echo .dump | sqlite3 " + tmp_db + \
            " | grep -c 'INSERT INTO MetaAlerts'"
        output = util.callproc(cmd)
        assert int(output.strip()) == meta_alerts

        # Upload project database
        script = os.path.join(scripts_ruby_dir, "upload_database.sh")
        cmd = [script, project_id, tmp_db]
        output = util.callproc(cmd)
        match = re.search(r"database was successfully uploaded", output)
        assert match is not None, \
                "no match for upload success:\n---\n%s\n---" % output
        # Count display alerts generated
        cmd = "echo \"SELECT id FROM Displays WHERE project_id='" \
            + project_id + "'\" | sqlite3 " + bootstrap.internal_db \
            + " | wc -l"
        output = util.callproc(cmd)
        assert int(output.strip()) == displays

        # Finally clean up project
        script = os.path.join(scripts_ruby_dir, "delete_project.sh")
        cmd = [script, project_id]
        util.callproc(cmd)
        assert not os.path.exists(bootstrap.project_gnu_dir(project_id))

    def test_dos2unix(self):
        self.create_manual_project(
            "demo/dos2unix/dos2unix-7.2.2.zip",
            "demo/dos2unix/analysis/cppcheck_oss.xml",
            21, 22) # dos2unix has 21 meta-alerts and 22 display entries

    def test_microjuliet(self):
        self.create_manual_project(
            "demo/microjuliet/package.zip",
            "demo/microjuliet/analysis/cppcheck_oss.xml",
            227, 229, { # mj has 227 meta-alerts and 229 display entries
                "manifest_file": "demo/microjuliet/supplemental/manifest.xml",
                "function_info_file": "demo/microjuliet/supplemental/function_info.csv",
                "file_info_file": "demo/microjuliet/supplemental/file_info.csv"
            })


if __name__ == '__main__':
    import pytest
    pytest.main()
