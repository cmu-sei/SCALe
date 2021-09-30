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

class TestFixPath:

    def clean_up(self):
        try:
            os.remove("fix_path_output")
        except Exception:
            pass

    def run_fix_path(self):
        self.test_data_dir = TestMethods.setUp()
        try:
            script = "fix_path.py"
            source = "../demo/dos2unix/src"
            fixable_paths = "ascii.t : fr/man1/dos2unix.txt"
            unfixable_paths = "unmapped_file_path.txt : en/man1/dos2unix.txt "
            paths_to_fix = fixable_paths + " : " + unfixable_paths
            output_file = "fix_path_output"
            args = ["python", script, source, paths_to_fix, output_file]
            subprocess.call(args)
            good_data = self.test_data_dir + "/good/good." + output_file
            err = subprocess.check_output(
                "cmp " + output_file + " " + good_data, shell=True)
            assert err == ""

        finally:
            self.clean_up()

    def test_fix_path(self):
        self.run_fix_path()

