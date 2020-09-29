# Automated testing for feature/RC-1563
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

# Tests that the 'stats_subscriber.py' script works correctly.

# It would be nice if this test left the output data

import os
import sys
import subprocess

sys.path.append(os.getenv("SCALE_HOME") + "/scale.app/scripts")
import stats_subscriber as Subscriber


class Obj(object):
    '''Class for converting a dictionary into objects'''
    def __init__(self, d):
        for a, b in d.items():
            if isinstance(b, (list, tuple)):
                setattr(self, a, [Obj(x) if isinstance(x, dict) else x for x in b])
            else:
                setattr(self, a, Obj(b) if isinstance(b, dict) else b)


class TestMethods:
    @classmethod
    def setUp(cls):
        # Why does os.getcwd() return a different path from $PWD???
        os.chdir(os.getenv("PWD"))   # scale.app
        return "test/python/data"


def json2python(path):
    '''Read a JSON file into a python object hierarchy'''
    import json
    with open(path) as f:
        data = json.load(f)
    return Obj(data)


tmp = "/tmp/scale.app"


class TestSubscriber:

    def clean_up(self):
        try:
            import shutil
            shutil.rmtree(tmp)
        except Exception:
            pass

    def test_subscriber(self):
        try:
            data_dir = TestMethods.setUp()
            msg_file = data_dir + '/RC-1563/mj.stats.json'
            sql_file = data_dir + '/RC-1563/mj.db.sql'
            confidence = "0.727808653670"

            # Right now this only tests the update_db mechanism

            # Confidence value is plentiful in json file
            count = subprocess.check_output(
                ["grep", "-c", confidence, msg_file]).strip()
            assert count == "378"
            # But confidence value is not in initial SQL file
            count = subprocess.check_output(
                # The wc -l is b/c grep will return nonzero if no hits
                'grep "{}" {} | wc -l'.format(
                    confidence, sql_file), shell=True).strip()
            assert count == "0"

            # Create sqlite database from test data
            os.mkdir(tmp)
            new_db = tmp + "/db.sqlite"
            subprocess.check_call(
                'sqlite3 {} < {}'.format(new_db, sql_file), shell=True)

            msg = json2python(msg_file)

            # update db
            Subscriber.update_db(new_db, msg)

            # Confidence value should now be plentiful in new database
            count = subprocess.check_output(
                'echo .dump | sqlite3 {} | grep -c "{}"'.format(
                    new_db, confidence), shell=True).strip()
            assert count == "383"

        finally:
            self.clean_up()


if __name__ == '__main__':
    import pytest
    pytest.main()
