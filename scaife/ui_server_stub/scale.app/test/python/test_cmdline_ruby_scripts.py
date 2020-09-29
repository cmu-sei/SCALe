# Python unit tests

# Does not depend on SCALE_HOME, sets it based on pwd, which should be
# scale.app

# It would be nice if this test left the output file so can compare
# with answer.

# <legal>
# SCALe version r.6.2.2.2.A
# 
# Copyright 2020 Carnegie Mellon University.
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
import subprocess


class TestManualProject:
    def create_manual_project(self, src_zip, tool_output,
                              meta_alerts, displays, supplemental=None):
        try:
            os.putenv("SCALE_HOME", os.getenv("PWD") + "/..")
            scale_app = os.getenv("PWD") + "/"  # Must be $SCALE_HOME/scale.app
            os.mkdir("temp_scale")
            os.chdir("temp_scale")


            # Create empty project, and get project_id from output
            cmd = [scale_app + "scripts/cmdline-ruby/create_project.sh",
                   "TestProject", "A test project"]
            output = subprocess.check_output(cmd)
            match = re.search(r"(\d\d*) is the new project id.", output)
            project_id = match.group(1)
            # Make sure new project_id is in db/development.sqlite
            cmd = "echo .dump | sqlite3 " + scale_app + "db/development.sqlite3" + \
                " | grep -c 'INSERT INTO projects VALUES(" + project_id + ",'"
            output = subprocess.check_output(cmd, shell=True)
            assert output.strip() == "1"

            # Make testsuite out supplemental data
            if supplemental is not None:
                cmd = [scale_app + "./scripts/cmdline-ruby/edit_project.sh",
                       project_id, "test_suite_name",'"test_suite"']
                subprocess.call(cmd)
                cmd = [scale_app + "./scripts/cmdline-ruby/edit_project.sh",
                       project_id, "test_suite_version",'12345678']
                subprocess.call(cmd)
                for attribute in supplemental:
                    cmd = [scale_app + "./scripts/cmdline-ruby/edit_project_file.sh",
                           project_id, attribute,
                           scale_app + supplemental[attribute]]
                    subprocess.call(cmd)
                assert os.path.exists(scale_app + "archive/backup/"
                                      + project_id + "/supplemental")

            # Create GNU Global Archive
            cmd = [scale_app + "scripts/cmdline-ruby/create_src_html.py", scale_app + src_zip]
            subprocess.call(cmd)
            assert os.path.exists("html.zip")

            # Upload GNU Global Archive
            cmd = [scale_app + "scripts/cmdline-ruby/upload_src_html.sh",
                   project_id, "html.zip"]
            subprocess.call(cmd)
            assert os.path.exists(scale_app + "public/GNU/" + project_id)

            # Create database
            # (All projects use cppcheck output)
            cmd = [scale_app + "scripts/cmdline-ruby/create_database.py",
                   "-t", "cppcheck_oss", "-p", "c/cpp", "-V", "1.86",
                   "db.sqlite3", scale_app + tool_output,
                   scale_app + src_zip]
            subprocess.call(cmd)
            assert os.path.exists("db.sqlite3")
            # Count meta-alerts generated
            cmd = "echo .dump | sqlite3 db.sqlite3" + \
                " | grep -c 'INSERT INTO MetaAlerts'"
            output = subprocess.check_output(cmd, shell=True)
            assert int(output.strip()) == meta_alerts

            # Upload project database
            cmd = [scale_app + "scripts/cmdline-ruby/upload_database.sh",
                   project_id, "db.sqlite3"]
            output = subprocess.check_output(cmd)
            match = re.search(r"database was successfully uploaded", output)
            assert match is not None
            # Count display alerts generated
            cmd = "echo \"SELECT id FROM Displays WHERE project_id='" \
                + project_id + "'\" | sqlite3 " + scale_app \
                + "db/development.sqlite3 | wc -l"
            output = subprocess.check_output(cmd, shell=True)
            assert int(output.strip()) == displays

            # Finally clean up project
            cmd = [scale_app + "scripts/cmdline-ruby/delete_project.sh", project_id]
            subprocess.call(cmd)
            assert not os.path.exists(scale_app + "public/GNU/" + project_id)

        except subprocess.CalledProcessError as e:
            raise Exception(e.output)
        finally:
            os.chdir("..")
            shutil.rmtree("temp_scale")

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
