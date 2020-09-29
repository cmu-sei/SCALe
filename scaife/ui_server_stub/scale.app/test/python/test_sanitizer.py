#!/bin/env python

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

from __future__ import print_function

import pytest

import os, sys, re
import itertools, subprocess, shutil, sqlite3
from datetime import datetime
from subprocess import CalledProcessError

import bootstrap
from bootstrap import rel2scale_path

# The db to test is determined in one of several different ways:
#   a) a project name is specified, in which case the db file
#      containing it is located in scale.app/db/backup
#      and is then sanitized
#   b) an arbitrary unsanitized db file is specified and it is sanitized
#   c) the default unsanitized db file in this test directory is sanitized
#   d) or sanitization is disabled and unsanitized DBs are compared

test_dir = os.path.dirname(os.path.abspath(__file__))
dat_dir = os.path.join(test_dir, 'data/sanitizer')
scale_dir = os.path.dirname(os.path.dirname(test_dir))
scripts_dir = os.path.join(scale_dir, 'scripts')

def archive_project_db(project_id, project_name):
    cwd = os.getcwd()
    dbf = bootstrap.export_project(project_id)
    if not dbf:
        print("Unable to archive project %d: %s" % (project_id, project_name))
    return dbf

def _gen_db_names(keep_tmp=False):
    copy_db = bootstrap.get_tmp_file(
            basename="copy.sqlite3", ephemeral=(not keep_tmp))
    sanit_db = bootstrap.get_tmp_file(
            basename="sanit.sqlite3", ephemeral=(not keep_tmp))
    return sanit_db, copy_db

def sanitize_db(db, salt_file, keep_tmp=False):
    if scripts_dir not in sys.path:
        sys.path.insert(0, scripts_dir)
    import sanitize_db as sdb
    sdb.VERBOSE = False
    new_db_sanit, new_db_copy, = \
            _gen_db_names(keep_tmp=keep_tmp)
    sdb.sanitize_db(db, copy_db_path=new_db_copy,
            sanit_db_path=new_db_sanit, salt_file=salt_file)
    return new_db_sanit

class TestSanitizer(object):

    @pytest.fixture(scope="class", autouse=True)
    def setup_all(self, request):
        print()
        cls = type(self)
        cls.project_name = request.config.option.sanitizer_project
        cls.db_tgt = request.config.option.sanitizer_tgtdb
        cls.db_ref = request.config.option.sanitizer_refdb
        cls.db_salt = request.config.option.sanitizer_salt
        cls.sanitize = not request.config.option.sanitizer_no_sanitize
        cls.keep_tmp = request.config.option.sanitizer_keep
        cls.dbh_ref = cls.dbh_tgt = None
        cls.cur_ref = cls.cur_tgt = None
        cls.schema_ref = cls.pk_ref = None
        cls.schema_tgt = cls.pk_tgt = None
        if not cls.db_tgt and cls.project_name:
            project_id, project_name = \
                    bootstrap.get_project_id_and_name(cls.project_name)
            print("archiving project: %s" % cls.project_name)
            cls.db_tgt = archive_project_db(project_id, project_name)
        if cls.sanitize:
            if not cls.db_ref:
                cls.db_ref = os.path.join(dat_dir,
                    'dos2unix.sanitizer.sanitized.sqlite3')
            if not cls.db_salt:
                cls.salt_file_ref = \
                    os.path.join(dat_dir, 'dos2unix.sanitizer.salt')
            if not os.path.exists(cls.salt_file_ref):
                raise RuntimeError(
                    "Reference salt file does not exist: %s" \
                        % rel2scale_path(cls.salt_file_ref))
        else:
            if not cls.db_ref:
                cls.db_ref = os.path.join(dat_dir, 'dos2unix.sanitizer.sqlite3')
            cls.salt_file_ref = None
        if not os.path.exists(cls.db_ref):
            raise RuntimeError(
                "Reference DB does not exist: %s" % rel2scale_path(cls.db_ref))
        if not cls.db_tgt:
            if cls.sanitize:
                cls.db_tgt = os.path.join(dat_dir, 'dos2unix.sanitizer.sqlite3')
            else:
                raise RuntimeError(
                    "No target DB (--no_sanitize used without " \
                        "--sanitizer-project or --sanitizer-tgtdb)")
        if cls.sanitize:
            if not os.path.exists(cls.db_tgt):
                raise RuntimeError(
                    "Target DB does not exist: %s" % rel2scale_path(cls.db_tgt))
            cls.db_tgt_orig = cls.db_tgt
            cls.db_tgt = sanitize_db(
                cls.db_tgt_orig, cls.salt_file_ref, keep_tmp=cls.keep_tmp)
        else:
            cls.db_tgt_orig = None
        if not os.path.exists(cls.db_tgt):
            raise RuntimeError(
                "Target DB does not exist: %s" % rel2scale_path(cls.db_tgt))
        cls.dbh_ref = connect(cls.db_ref)
        cls.cur_ref = cls.dbh_ref.cursor()
        cls.dbh_tgt = connect(cls.db_tgt)
        cls.cur_tgt = cls.dbh_tgt.cursor()
        cls.schema_ref, cls.pk_ref = schema(cls.cur_ref)
        cls.schema_tgt, cls.pk_tgt = schema(cls.cur_tgt)
        if not cls.schema_ref:
            raise RuntimeError("Unable to load reference schema")
        if not cls.schema_tgt:
            raise RuntimeError("Unable to load target schema")

    def teardown_class(cls):
        if cls.dbh_ref:
          cls.dbh_ref.close()
        if cls.dbh_tgt:
          cls.dbh_tgt.close()
          if cls.keep_tmp:
              print("sanitized DB retained: %s" % rel2scale_path(cls.db_tgt))

    @pytest.fixture
    def print_state(self):
        print()
        if self.sanitize:
            print("Target DB:", rel2scale_path(self.db_tgt_orig))
            print("Target DB (sanitized):", rel2scale_path(self.db_tgt))
            print("Salt file:", rel2scale_path(self.salt_file_ref))
        else:
            print("Target DB:", rel2scale_path(self.db_tgt))
        print("Reference DB:", rel2scale_path(self.db_ref))

    def test_schema(self, print_state):
        common, diff_plus, diff_minus = diff(self.schema_ref, self.schema_tgt)
        str_plus = ', '.join(sorted(diff_plus))
        str_minus = ', '.join(sorted(diff_minus))
        assert not diff_plus, "Tables ADDED: [%s]" % str_plus
        assert not diff_minus, "Tables REMOVED: [%s]" % str_minus
        for table in common:
            cols_ref = self.schema_ref[table]
            cols_tgt = self.schema_tgt[table]
            common, diff_plus, diff_minus = diff(cols_ref, cols_tgt)
            str_plus = ', '.join(sorted(diff_plus))
            str_minus = ', '.join(sorted(diff_minus))
            assert not diff_plus, \
                "Table %s columns ADDED: [%s]" % (table, str_plus)
            assert not diff_minus, \
                "Table %s columns REMOVED: [%s]" % (table, str_minus)
            for col in sorted(common):
                type_ref = cols_ref[col]
                type_tgt = cols_tgt[col]
                assert type_ref == type_tgt, \
                    "Table %s column %s TYPE CHANGED: %s -> %s" \
                            % (table, col, type_ref, type_tgt)

    def test_contents(self, print_state):
        re_sha256 = re.compile(r"\b (?:0x)? ( [0-9a-f]{64} ) \b", re.I|re.X)
        def is_sha256(text):
            for component in text.split('/'):
                if component and not re_sha256.search(component):
                    return False
            return True
        variable_sanitized_columns = dict(
            Projects = set([
                "name",
                "description",
                "source_file",
                "test_suite_name",
                "test_suite_version",
                "test_suite_type",
                "test_suite_sard_id",
                "project_data_source",
                "author_source",
                "manifest_file",
                "manifest_url",
                "function_info_file",
                "file_info_file",
                "license_file",
                "version",
            ]),
            PrioritySchemes = set([
                "name",
            ]),
            ClassifierSchemes = set([
                "classifier_instance_name"
            ]),
        )
        variable_unsanitized_columns = dict(
            PerformanceMetrics = set([
                "cpu_time",
                "elapsed_time",
            ]),
        )
        self.table_count = self.row_count = self.val_count = 0
        common, diff_plus, diff_minus = diff(self.schema_ref, self.schema_tgt)
        ignore_columns = {
            "PerformanceMetrics": ["elapsed_time", "cpu_time"],
            "ClassifierSchemes": ["source_domain"],
            "MetaAlerts": ["confidence_score"],
        }
        for table in common:
            self.table_count += 1
            cols_ref = self.schema_ref[table]
            cols_tgt = self.schema_tgt[table]
            common, diff_plus, diff_minus = diff(cols_ref, cols_tgt)
            datetime_cols = set()
            for col in common:
                if cols_ref[col] == 'DATETIME':
                    datetime_cols.add(col)
            sql = "SELECT %s FROM %s" % (','.join(common), table)
            rows_ref = tuple(dict(row) for row in self.cur_ref.execute(sql))
            rows_tgt = tuple(dict(row) for row in self.cur_tgt.execute(sql))
            rc_tgt, rc_ref = len(rows_tgt), len(rows_ref)
            if "PerformanceMetrics" == table: # Handle additional row being inserted into the target database on Bamboo
                assert rc_tgt >= rc_ref, "Table %s row count mismatch: %d is not >= %d" % (table, len(rows_tgt), len(rows_ref))
            else:
                assert rc_tgt == rc_ref, "Table %s row count mismatch: %d != %d" % (table, len(rows_tgt), len(rows_ref))
            var_sanit_cols = variable_sanitized_columns.get(table, set())
            var_unsanit_cols = variable_unsanitized_columns.get(table, set())
            if rc_tgt == rc_ref:
                for r, (row_tgt, row_ref) \
                        in enumerate(itertools.izip(rows_tgt, rows_ref)):
                    self.row_count += 1
                    for col in common:
                        self.val_count += 1
                        if col in var_sanit_cols:
                            if self.sanitize and row_tgt[col]:
                                assert is_sha256(row_tgt[col]), \
                                    "Table %s row %d: col '%s' " \
                                    "is not sha256: '%s'" \
                                        % (table, r, col, row_tgt[col])
                            else:
                                pass
                        elif col in datetime_cols and row_tgt[col]:
                            v = re.sub(r'\.\d+$', '', row_tgt[col])
                            dtfmt = "%Y-%m-%d %H:%M:%S"
                            try:
                                v = datetime.strptime(v, dtfmt)
                            except ValueError:
                                pass
                            assert isinstance(v, datetime), \
                                "Table %s row %d: col '%s' is not type " \
                                "DATETIME (%s): %s" \
                                    % (table, r, col, dtfmt, row_tgt[col])
                        elif (table in ignore_columns) \
                                and (col in ignore_columns[table]):
                            pass
                        elif col not in var_unsanit_cols \
                                and not re.search(r"^scaife.*id$", col):
                            assert row_tgt[col] == row_ref[col], \
                                "Table %s row %d: col '%s' " \
                                "mismatch: %s != %s" \
                                    % (table, r, col, \
                                       row_tgt[col], row_ref[col])
        print("Compared %d tables, %d rows, %d values" \
                % (self.table_count, self.row_count, self.val_count))

def connect(db):
    conn = sqlite3.connect(db)
    conn.row_factory = sqlite3.Row
    conn.text_factory = str
    return conn

def diff(a, b):
    diff_plus = set(b).difference(a)
    diff_minus = set(a).difference(b)
    common = set(a).intersection(b)
    return common, diff_plus, diff_minus

def schema(cur):
    tables = {}
    primary_keys = {}
    cur.execute("SELECT name FROM sqlite_master WHERE type='table'")
    for table in [row[0] for row in cur]:
        cur.execute("PRAGMA table_info(%s)" % table)
        cols = tables[table] = {}
        for _, name, typ, _, _, pk in cur:
            cols[name] = typ
            if pk:
                primary_keys[table] = name
    return tables, primary_keys


if __name__ == '__main__':
    pytest.main()
