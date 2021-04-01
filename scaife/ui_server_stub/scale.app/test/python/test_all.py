# Python unit tests

# <legal>
# SCALe version r.6.5.5.1.A
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

from __future__ import print_function

import os, sys
import subprocess

import bootstrap, util

# for debugging, leave output in scale.app/tmp if set
KEEP_OUTPUT=False

class TestMetric2Org:

    def run_metric_tool(self, tool):
        test_dir = bootstrap.python_test_data_dir
        # If both files are gone, don't do test.
        input_csv = os.path.join(test_dir, "%s.csv" % tool)
        input_db = os.path.join(test_dir, "good.%s.sqlite" % tool)
        script = os.path.join(bootstrap.scripts_dir, "%s2sql.py" % tool)
        if os.path.isfile(input_csv) or os.path.isfile(input_db):
            tmp_file1 = bootstrap.get_tmp_file(
                basename="db.%s.good.sql" % tool,
                ephemeral = not KEEP_OUTPUT)
            res = util.callproc(
                "echo  .dump  |  sqlite3  " + input_db
                + "  >  " + tmp_file1)
            assert res == ""

            tmp_db = bootstrap.get_tmp_file()
            tmp_file2 = bootstrap.get_tmp_file(
                basename="db.%s.comp.sql" % tool, ephemeral = not KEEP_OUTPUT)
            cmd = "python %s < %s | sqlite3 %s" % (script, input_csv, tmp_db)
            res = util.callproc(cmd)
            assert res == ""
            cmd = "echo .dump | sqlite3 " + tmp_db + " > " + tmp_file2
            res = util.callproc(cmd)
            assert res == ""

            res = subprocess.call(["cmp", tmp_file2, tmp_file1])
            assert res == 0, "db dumps differ"
        else:
            print("Missing an input for: %s" % tool)

    def test_ccsm_oss(self):
        self.run_metric_tool("ccsm_oss")

    def test_lizard_oss(self):
        self.run_metric_tool("lizard_oss")

    def test_understand(self):
        self.run_metric_tool("understand")


class TestSaAlert2TSV:

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
        file_name, file_extension = os.path.splitext(file_path)
        input_dir = os.path.join(bootstrap.python_test_data_dir, "input")
        input_file = os.path.join(input_dir, file_path)
        good_dir = os.path.join(bootstrap.python_test_data_dir, "good")
        good_file = os.path.join(good_dir, "good.%s.tsv" % file_name)
        output_file = bootstrap.get_tmp_file(
            basename="%s.parser_output.tsv" % file_name,
            ephemeral = not KEEP_OUTPUT)
        parser_dir = os.path.join(bootstrap.scripts_dir,
                "tool_output_parsers")
        # If both files are gone, don't do test.
        if os.path.isfile(input_file) or os.path.isfile(good_file):
            script = os.path.join(parser_dir, "%s2tsv.py" % tool)
            cmd = ["python", script, input_file, output_file]
            util.callproc(cmd)
            self.diff_lines(tool, output_file, good_file)

    def test_coverity(self):
        self.run_alert_tool("coverity", "coverity_dos2unix.txt")
        self.run_alert_tool("coverity", "coverity_jasper.json")

    def test_fortify(self):
        self.run_alert_tool("fortify", "fortify.txt")

    def test_gcc_oss(self):
        self.run_alert_tool("gcc_oss", "gcc_oss_dos2unix.txt")
        self.run_alert_tool("gcc_oss", "gcc_oss_jasper.txt")

    # def test_codesonar(self):
    #     self.run_alert_tool("codesonar", "codesonar.sarif")

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

    def test_clang(self):
        self.run_alert_tool("clang_oss", "clang_oss.zip")

    def test_clang_compiler(self):
        self.run_alert_tool("clang_compiler_oss", "clang_compiler_oss.txt")

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

    def run_match_path(self):
        script = os.path.join(bootstrap.scripts_dir, "match_paths.py")
        src_dir = os.path.join(bootstrap.base_dir, "demo/dos2unix/src")
        good_dir = os.path.join(bootstrap.python_test_data_dir, "good")
        match_base = "match_path_output"
        good_file = os.path.join(good_dir, "good.%s" %  match_base)
        fixable_paths = "ascii.t ::: fr/man1/dos2unix.txt"
        unfixable_paths = "unmapped_file_path.txt ::: en/man1/dos2unix.txt "
        paths_to_fix = fixable_paths + " ::: " + unfixable_paths
        output_file = bootstrap.get_tmp_file(
            basename="%s.out" % match_base, ephemeral = not KEEP_OUTPUT)
        cmd = ["python", script, src_dir, paths_to_fix, output_file]
        util.callproc(cmd)
        cmd = ["cmp", output_file, good_file]
        res = subprocess.call(cmd)
        assert res == 0, "results differ, cmd: %s" % cmd

    def test_match_path(self):
        self.run_match_path()


if __name__ == '__main__':
    import pytest
    pytest.main()
