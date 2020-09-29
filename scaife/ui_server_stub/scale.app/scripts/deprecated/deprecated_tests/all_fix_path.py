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

