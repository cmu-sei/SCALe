# Automated testing for feature/RC-1563
#
# Tests that the 'stats_subscriber.py' script works correctly.
#
# It would be nice if this test left the output data

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

import os
import sys

import bootstrap, util

import stats_subscriber as Subscriber

KEEP_OUTPUT = False

class Obj(object):
    '''Class for converting a dictionary into objects'''
    def __init__(self, d):
        for a, b in d.items():
            if isinstance(b, (list, tuple)):
                setattr(self, a, [Obj(x) if isinstance(x, dict) else x for x in b])
            else:
                setattr(self, a, Obj(b) if isinstance(b, dict) else b)


def json2python(path):
    '''Read a JSON file into a python object hierarchy'''
    import json
    with open(path) as f:
        data = json.load(f)
    return Obj(data)


class TestSubscriber:

    def test_subscriber(self):
        msg_file = os.path.join(bootstrap.python_test_data_dir,
                "RC-1563/mj.stats.json")
        sql_file = os.path.join(bootstrap.python_test_data_dir,
                "RC-1563/mj.db.sql")
        confidence = "0.727808653670"

        tmp_dir = bootstrap.get_tmp_dir(ephemeral = not KEEP_OUTPUT,
                suffix="test_subscriber")

        # Right now this only tests the update_db mechanism

        # Confidence value is plentiful in json file
        cmd = ["grep", "-c", confidence, msg_file]
        count = util.callproc(cmd).strip()
        assert count == "378"
        # But confidence value is not in initial SQL file
        # The wc -l is b/c grep will return nonzero if no hits
        cmd = 'grep "{}" {} | wc -l'.format(confidence, sql_file)
        count = util.callproc(cmd).strip()
        assert count == "0"

        # Create sqlite database from test data
        new_db = os.path.join(tmp_dir, "db.sqlite3")
        cmd = 'sqlite3 {} < {}'.format(new_db, sql_file)
        util.callproc(cmd)

        msg = json2python(msg_file)

        # update db
        Subscriber.update_db(new_db, msg)

        # Confidence value should now be plentiful in new database
        cmd = 'echo .dump | sqlite3 {} | grep -c "{}"'.format(
                new_db, confidence)
        count = util.callproc(cmd).strip()
        assert count == "383"


if __name__ == '__main__':
    import pytest
    pytest.main()
