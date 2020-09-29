# Python unit tests

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
import subprocess


class TestMethods:
    @classmethod
    def setUp(cls):
        # os.getcwd() returns different path from $PWD!
        os.chdir(os.getenv("PWD") + "/scripts")
        return "../test/python/data"


class TestMetric2Org:

    def clean_up(self):
        for db in ("/tmp/db.sqlite", "/tmp/db.good.sql"):
            try:
                os.remove(db)
            except Exception:
                pass

    def run_metric_tool(self, file_path):
        test_data_dir = TestMethods.setUp()
        file_name, file_extension = os.path.splitext(file_path)
        # If both files are gone, don't do test.
        if os.path.isfile(test_data_dir + "/" + file_name + ".csv") or \
           os.path.isfile(test_data_dir + "/good." + file_name + ".sqlite"):
            try:
                err = subprocess.check_output(
                    "echo  .dump  |  sqlite3  "
                    + test_data_dir + "/good." + file_name + ".sqlite  "
                    + "  >  /tmp/db.good.sql",
                    shell=True, stderr=subprocess.STDOUT)
                assert err == ""

                err = subprocess.check_output(
                    "python  ./" + file_name + "2sql.py  <  "
                    + test_data_dir + "/" + file_name + ".csv"
                    + "  |  sqlite3  /tmp/db.sqlite",
                    shell=True, stderr=subprocess.STDOUT)
                assert err == ""

                err = subprocess.check_output(
                    "echo  .dump"
                    + "  |  sqlite3  /tmp/db.sqlite"
                    + "  |  cmp  -  /tmp/db.good.sql",
                    shell=True)
                assert err == ""

            except subprocess.CalledProcessError as e:
                raise Exception(e.output)
            finally:
                self.clean_up()

    def test_ccsm_oss(self):
        self.run_metric_tool("ccsm_oss.txt")

    def test_lizard_oss(self):
        self.run_metric_tool("lizard_oss.txt")

    def test_understand(self):
        self.run_metric_tool("understand.txt")


class TestSaAlert2TSV:

    def clean_up(self):
        for db in ("/tmp/db.sqlite", "/tmp/db.good.sql"):
            try:
                os.remove(db)
            except Exception:
                pass

    def diff_lines(self, tool, file1, file2):
        temp1 = open(file1, 'r')
        temp2 = open(file2, 'r')

        f1 = temp1.readlines()
        f2 = temp2.readlines()

        unmatched = {}

        for i in range(0, len(f2)):
            f1_line = f1[i]
            f2_line = f2[i]
            if f1_line != f2_line:
                unmatched[f2_line] = f1_line

        if(len(unmatched) > 0):
            key, value = unmatched.iteritems().next()
            error_info = tool + " files don't match!\n\n" + \
            str(len(unmatched)) + " unmatched line(s)\n\n" + \
            "Example:\n\n" + \
            key + "\n" + \
            value
            raise Exception(error_info)

    def run_alert_tool(self, tool, file_path):
        test_data_dir = TestMethods.setUp()

        file_name, file_extension = os.path.splitext(file_path)
        input_file = test_data_dir + "/input/" + file_name + file_extension
        output_file = file_name + "_parser_output"
        good_data = test_data_dir + "/good/good." + file_name + ".tsv"
        # If both files are gone, don't do test.
        if os.path.isfile(input_file) or \
           os.path.isfile(good_data):
            try:
                script = "./tool_output_parsers/" + tool + "2tsv.py"
                parser_args = ["python", script, input_file, output_file]
                subprocess.call(parser_args)
                self.diff_lines(tool, output_file, good_data)

            except subprocess.CalledProcessError as e:
                raise Exception(e.output)
            finally:
                self.clean_up()
                # Remove temporary output file
                temp_parser_output = os.getcwd() + "/" + output_file
                if os.path.isfile(temp_parser_output):
                    os.remove(temp_parser_output)

    def test_coverity(self):
        self.run_alert_tool("coverity", "coverity_dos2unix.txt")
        self.run_alert_tool("coverity", "coverity_jasper.json")

    def test_fortify(self):
        self.run_alert_tool("fortify", "fortify.txt")

    def test_gcc_oss(self):
        self.run_alert_tool("gcc_oss", "gcc_oss_dos2unix.txt")
        self.run_alert_tool("gcc_oss", "gcc_oss_jasper.txt")

    def test_msvc(self):
        self.run_alert_tool("msvc", "msvc.txt")

    def test_pclint(self):
        self.run_alert_tool("pclint", "pclint.txt")

    def test_rosecheckers_oss(self):
        self.run_alert_tool("rosecheckers_oss",
                            "rosecheckers_oss_dos2unix.txt")
        self.run_alert_tool("rosecheckers_oss", "rosecheckers_oss_jasper.txt")

    def test_ldra(self):
        # Note that this test only covers ldra rpf files
        self.run_alert_tool("ldra", "ldra.rpf")

    def test_cppcheck(self):
        self.run_alert_tool("cppcheck_oss", "cppcheck_oss_v100.xml")
        self.run_alert_tool("cppcheck_oss", "cppcheck_oss_v183.xml")

    def test_blint(self):
        self.run_alert_tool("blint_oss", "blint_oss.txt")

    def test_perlcritic(self):
        self.run_alert_tool("perlcritic_oss", "perlcritic_oss.txt")

    def test_eclipse(self):
        self.run_alert_tool("eclipse_oss", "eclipse_oss.tsv")

    def test_jshint_oss(self):
        self.run_alert_tool("jshint_oss", "jshint_oss_scale.txt")

    def test_findbugs_oss(self):
        self.run_alert_tool("findbugs_oss", "findbugs_oss.xml")
  
 
class TestMatchPath:
 
    def clean_up(self):
        try:
            os.remove("match_path_output")
        except Exception:
            pass
 
    def run_match_path(self):
        self.test_data_dir = TestMethods.setUp()
        try:
            script = "match_paths.py"
            source = "../demo/dos2unix/src"
            fixable_paths = "ascii.t ::: fr/man1/dos2unix.txt"
            unfixable_paths = "unmapped_file_path.txt ::: en/man1/dos2unix.txt "
            paths_to_fix = fixable_paths + " ::: " + unfixable_paths
            output_file = "match_path_output"
            
            args = ["python", script, source, paths_to_fix, output_file]
            subprocess.call(args)
            
            good_data = self.test_data_dir + "/good/good." + output_file
            
            err = subprocess.check_output(
                "cmp " + output_file + " " + good_data, shell=True)

            assert err == ""
 
        finally:
            self.clean_up()
 
    def test_match_path(self):
        self.run_match_path()  
         

if __name__ == '__main__':
    import pytest
    pytest.main()
