#!/usr/bin/env python
#
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

import os, sys, re, argparse, random, csv, hashlib, subprocess
import sqlite3
from zipfile import ZipFile

import bootstrap
from bootstrap import VERBOSE

salt_file = "salt.txt"

def relpath(path):
    return os.path.relpath(path, os.curdir)

def get_salt(f=salt_file):
    """
    Gets salt value from salt.txt or creates salt.txt with salt
    """
    try:
        salt = open(f).readline().strip()
    except IOError:
        salt = None
    if not salt:
        try:
            salt = subprocess.check_output(
                "head -c 16 /dev/urandom | base64",
                shell=True,
                stderr=subprocess.STDOUT
            ).strip()
        except subprocess.CalledProcessError, e:
            print("Unable to create salt: %s" % salt)
            sys.exit(1)
    if not salt:
        print("Empty result for salt")
        sys.exit(1)
    return salt


def win2unix(path):
    """
    Converts path to unix
    """
    path = re.sub(r"\w:", "", path)
    path = re.sub(r"\\\\", "/", path)
    path = re.sub(r"\\", "/", path)
    path = path.lower()
    return path


def sanitize_path(cur_path, salt):
    """
    Sanitizes a path and returns the new hashed path
    """
    new_path = None
    hash_components = []
    if cur_path:
        path_components = win2unix(cur_path).split("/")
        if not path_components[-1]:
            path_components.pop()
        for component in path_components:
            if component:
                hasher = hashlib.sha256()
                hasher.update(component + salt)
                component = hasher.hexdigest()
            hash_components.append(component)
        new_path = "/".join(hash_components)
    return new_path


def sanitize(entry, salt):
    """
    Sanitizes a single field and returns that hashed field
    """
    new_cursor = None
    hash_str = hashlib.sha256()
    # print(entry, salt)
    hash_str.update(entry + salt)
    new_cursor = hash_str.hexdigest()
    return new_cursor


def _create_offset_path(path):
    while os.path.exists(path) or offset:
        new_path = path.split("/")
        str_list = new_db_path[-1].split(".")
        offset = str(random.randint(0, 10000000))
        str_list[0] = str_list[0] + "_%08d" % offset
        new_path[-1] = ".".join(str_list)
        new_path = os.path.join(*new_path)
    return new_path


def gen_copy_db_path(old_db_path, create_new=False):
    """
    Get new name for copied db
    """
    tgt_dir, old_db = \
        os.path.dirname(old_db_path), os.path.basename(old_db_path)
    basename, ext = os.path.splitext(old_db)
    basename += ".with_salt"
    new_db_path = os.path.join(tgt_dir, basename + ext)
    if os.path.exists(new_db_path):
        if VERBOSE:
            print("Copied database already exists: %s" % relpath(new_db_path))
        if create_new:
            new_db_path = _create_offset_path(new_db_path)
            if VERBOSE:
                print("New database will be created: %s" % relpath(new_db_path))
        else:
            if VERBOSE:
                print("Existing copy will be overwritten")
    return new_db_path


def gen_sanit_db_path(old_db_path, salt, create_new=False, hashname=True):
    tgt_dir, old_db = \
        os.path.dirname(old_db_path), os.path.basename(old_db_path)
    basename, ext = os.path.splitext(old_db)
    if hashname:
        hash_str = hashlib.sha256()
        hash_str.update(basename + salt)
        basename = hash_str.hexdigest()
    else:
        basename += ".sanitized"
    sanit_db_path = os.path.join(tgt_dir, basename + ext)
    if os.path.exists(sanit_db_path):
        if VERBOSE:
            print("Sanitized database already exists: %s" \
                % relpath(sanit_db_path))
        if create_new:
            new_db_path = _create_offset_path(new_db_path)
            if VERBOSE:
                print("New database will be created: %s" % relpath(new_db_path))
        else:
            if VERBOSE:
                print("Existing copy will be overwritten")
    return sanit_db_path


def copy_schema(old_db_path, new_db_path):
    old_con = sqlite3.connect(old_db_path)
    old_cursor = old_con.cursor()
    new_con = sqlite3.connect(new_db_path)
    new_cursor = new_con.cursor()

    # delete existing tables if they already exist in new db
    new_cursor.execute(
        "SELECT name FROM sqlite_master WHERE type='table'")
    tables = [row[0] for row in new_cursor]
    for table in tables:
        if VERBOSE:
            print("dropping table %s" % table)
        new_cursor.execute("DROP TABLE %s" % table)

    # replicate old db schema into new db
    old_cursor.execute(
        "SELECT sql FROM sqlite_master WHERE type='table'")
    for sql in [x[0] for x in old_cursor]:
        new_cursor.execute(sql)

    new_con.commit()
    new_con.close()
    old_con.close()


def copy_cur_db(old_db_path, new_db_path):
    copy_schema(old_db_path, new_db_path)

    old_con = sqlite3.connect(old_db_path)
    old_cursor = old_con.cursor()

    old_cursor.execute(
        "SELECT name FROM sqlite_master WHERE type='table'")
    tables = [row[0] for row in old_cursor]

    old_cursor.execute("ATTACH DATABASE '" + new_db_path + "' as copydb")
    for table in tables:
        if VERBOSE:
            print("copying table %s" % table)
        old_cursor.execute("""
            INSERT INTO copydb.%s SELECT * from main.%s
        """ % (table, table))

    old_con.commit()
    old_con.close()

    if VERBOSE:
        print("Copy of database created: %s" % relpath(new_db_path))

    return new_db_path


def populate_sanit_db(old_db_path, sanit_db_path, salt):
    """
    Dump information from original DB into new DB and obfuscate
    sensitive fields
    """

    copy_schema(old_db_path, sanit_db_path)

    old_con = sqlite3.connect(old_db_path)
    old_con.row_factory = sqlite3.Row
    old_cursor = old_con.cursor()

    new_con = sqlite3.connect(sanit_db_path)
    new_cursor = new_con.cursor()

    old_cursor.execute(
        "SELECT name FROM sqlite_master WHERE type='table'")
    tables = [row[0] for row in old_cursor]

    def _sanitize_txt(txt, force=False):
        if (txt and txt != "0") or force:
            txt = sanitize(txt or '', salt)
        return txt

    def _sanitize_path(txt):
        if txt:
            txt = sanitize_path(txt, salt)
        return txt

    def _insert_sql(count, table):
        hooks = '(' + ','.join(['?'] * count) + ')'
        sql = "INSERT INTO %s VALUES %s" % (table, hooks)
        return sql

    def _insert_dict_sql(key_order, table):
        cols = ', '.join(key_order)
        placeholders = ', '.join([':' + x for x in key_order])
        sql = "INSERT INTO %s (%s) VALUES (%s)" % (table, cols, placeholders)
        return sql

    def _fetchall(table):
        old_cursor.execute("SELECT * FROM %s" % table)
        return old_cursor

    def _split_dict_repr(text):
        row = []
        if text:
            row = text[1:-1].split(',')
            row = [x.split(':') for x in row]
            row = [[k[1:-1], v[1:-1]] for k, v in row]
        return row

    def _join_dict_repr(row):
        text = ''
        if row:
            row = [':'.join(['"%s"' % k, '"%s"' % v]) for k, v in row]
            text = "{%s}" % ','.join(row)
        return text

    # pre-sanitize user contributed columns
    uc_sanit_map = {}
    rows = list(_fetchall("UserUploads"))
    for row in rows:
        keys = row.keys()
        d = dict(row)
        uc_row = _split_dict_repr(d["user_columns"])
        for k, _ in uc_row:
            if k not in uc_sanit_map:
                uc_sanit_map[k] = _sanitize_txt(k)
    uc_pat = re.compile(r'\b(%s)\b' % '|'.join(sorted(uc_sanit_map.keys())))

    copy_tables = []
    for table in tables:
        if table == "Projects":
            if VERBOSE:
                print("sanitizing table %s" % table)
            for row in _fetchall(table):
                keys = row.keys()
                d = dict(row)
                # guard against blank name/description, need a sha256 here
                d["name"] = _sanitize_txt(d["name"], force=True)
                d["description"] = _sanitize_txt(d["description"], force=True)
                d["source_file"] = _sanitize_path(d["source_file"])
                d["source_url"] = _sanitize_path(d["source_url"])
                d["test_suite_name"] = _sanitize_txt(d["test_suite_name"])
                d["test_suite_version"] = _sanitize_txt(d["test_suite_version"])
                d["test_suite_type"] = _sanitize_txt(d["test_suite_type"])
                d["test_suite_sard_id"] = _sanitize_txt(d["test_suite_version"])
                d["project_data_source"] = _sanitize_txt(d["project_data_source"])
                d["author_source"] = _sanitize_txt(d["author_source"])
                d["manifest_file"] = _sanitize_path(d["manifest_file"])
                d["manifest_url"] = _sanitize_path(d["manifest_url"])
                d["function_info_file"] = _sanitize_path(d["function_info_file"])
                d["file_info_file"] = _sanitize_path(d["file_info_file"])
                d["license_file"] = _sanitize_path(d["license_file"])
                d["version"] = _sanitize_txt(d["version"])
                sql = _insert_dict_sql(keys, table)
                new_cursor.execute(sql, d)
        elif table == "Messages":
            if VERBOSE:
                print("sanitizing table %s" % table)
            for row in _fetchall(table):
                keys = row.keys()
                d = dict(row)
                d["path"] = _sanitize_path(d["path"])
                d["message"] = ''
                sql = _insert_dict_sql(keys, table)
                new_cursor.execute(sql, d)
        elif table == "ExtraSourceContext":
            if VERBOSE:
                print("sanitizing table %s" % table)
            for row in _fetchall(table):
                keys = row.keys()
                d = dict(row)
                d["func"] = _sanitize_txt(d["func"])
                d["class"] = _sanitize_txt(d["class"])
                d["namespace"] = _sanitize_txt(d["namespace"])
                sql = _insert_dict_sql(keys, table)
                new_cursor.execute(sql, d)
        elif table == "Determinations":
            if VERBOSE:
                print("sanitizing table %s" % table)
            for row in _fetchall(table):
                keys = row.keys()
                d = dict(row)
                d["notes"] = _sanitize_txt(d["notes"])
                sql = _insert_dict_sql(keys, table)
                new_cursor.execute(sql, d)
        elif table == "UserUploads":
            if VERBOSE:
                print("sanitizing table %s" % table)
            rows = list(_fetchall(table))
            for row in rows:
                keys = row.keys()
                d = dict(row)
                uc_row = _split_dict_repr(d["user_columns"])
                sanit_row = [[uc_sanit_map[k], v] for k, v in uc_row]
                sanit_txt = _join_dict_repr(sanit_row)
                d["user_columns"] = sanit_txt
                sql = _insert_dict_sql(keys, table)
                new_cursor.execute(sql, d)
        elif table == "PrioritySchemes":
            if VERBOSE:
                print("sanitizing table %s" % table)
            for row in _fetchall("PrioritySchemes"):
                keys = row.keys()
                d = dict(row)
                d["name"] = _sanitize_txt(d["name"])
                if uc_sanit_map:
                    d["formula"] = uc_pat.sub(lambda x: uc_sanit_map[x.group()], d["formula"])
                    uc_row = _split_dict_repr(d["weighted_columns"])
                    sanit_row = [[uc_sanit_map[k], v] for k, v in uc_row]
                    sanit_txt = _join_dict_repr(sanit_row)
                    d["weighted_columns"] = sanit_txt
                sql = _insert_dict_sql(keys, "PrioritySchemes")
                new_cursor.execute(sql, d)
        elif table == "ClassifierSchemes":
            if VERBOSE:
                print("sanitizing table %s" % table)
            for row in _fetchall(table):
                keys = row.keys()
                d = dict(row)
                d["classifier_instance_name"] = _sanitize_txt(d["classifier_instance_name"])
                d["source_domain"] = _sanitize_txt(d["source_domain"])
                sql = _insert_dict_sql(keys, table)
                new_cursor.execute(sql, d)
        elif table == "PerformanceMetrics":
            if VERBOSE:
                print("sanitizing table %s" % table)
            for row in _fetchall(table):
                keys = row.keys()
                d = dict(row)
                d["function_name"] = _sanitize_txt(d["function_name"])
                d["user_id"] = _sanitize_txt(d["user_id"])
                d["user_organization_id"] = \
                        _sanitize_txt(d["user_organization_id"])
                sql = _insert_dict_sql(keys, table)
                new_cursor.execute(sql, d)
        elif table == "LizardMetrics":
            if VERBOSE:
                print("sanitizing table %s" % table)
            for row in _fetchall(table):
                keys = row.keys()
                d = dict(row)
                if d["parent"]:
                    d["parent"] = _sanitize_path(d["parent"])
                    d["name"] = _sanitize_txt(d["name"])
                else:
                    d["name"] = _sanitize_path(d["name"])
                sql = _insert_dict_sql(keys, table)
                new_cursor.execute(sql, d)
        elif table == "CcsmMetrics":
            if VERBOSE:
                print("sanitizing table %s" % table)
            for row in _fetchall(table):
                keys = row.keys()
                d = dict(row)
                d["File"] = _sanitize_path(d["File"])
                d["Func"] = _sanitize_txt(d["Func"])
                sql = _insert_dict_sql(keys, table)
                new_cursor.execute(sql, d)
        elif table == "UnderstandMetrics":
            if VERBOSE:
                print("sanitizing table %s" % table)
            for row in _fetchall(table):
                keys = row.keys()
                d = dict(row)
                d["Name"] = _sanitize_txt(d["Name"])
                d["File"] = _sanitize_path(d["File"])
                sql = _insert_dict_sql(keys, table)
                new_cursor.execute(sql, d)
        else:
            copy_tables.append(table)

    new_con.commit()
    new_con.close()

    # direct dump of remaining tables
    old_cursor.execute("ATTACH DATABASE '" + sanit_db_path + "' as sanitdb")
    for table in copy_tables:
        if VERBOSE:
            print("copying table %s" % table)
        old_cursor.execute("""
            INSERT INTO sanitdb.%s SELECT * from main.%s
        """ % (table, table))

    old_con.commit()
    old_con.close()

    if VERBOSE:
        print("Sanitized database created: %s" % relpath(sanit_db_path))


def add_sanit_fields(db_name, salt):
    """
    Adds sanitized path of current DB, other fields to sanitize can be
    added here
    """

    conn = sqlite3.connect(db_name)

    cur = conn.cursor()
    new_cursor = conn.cursor()

    # Determine if path has already been sanitized/inserted into
    # current DB
    msg_cols = [i[1] for i in cur.execute("PRAGMA table_info(Messages)")]

    # Sanitize path
    if "sanitPath" not in msg_cols:
        add_path_sanit_str = "ALTER TABLE Messages" \
                          "  ADD COLUMN sanitPath TEXT"
        exec_str_cur = "SELECT id, path from Messages"
        exec_str_new = "UPDATE Messages SET sanitPath=? WHERE id=?"

        try:
            cur.execute(add_path_sanit_str)
            cur.execute(exec_str_cur)
            for entry in cur:
                new_path = sanitize_path(entry[1], salt)
                new_cursor.execute(exec_str_new, (new_path, entry[0]))
        except:
            print("ERROR: Unable to add sanitized database value/s.")
            conn.close()
            sys.exit(1)

    cur = conn.cursor()
    cur.execute("CREATE TABLE Salt (salt TEXT KEY)")
    cur.execute("INSERT INTO Salt VALUES (?)", (salt,))

    conn.commit()
    conn.close()


def create_csv_files(sanit_db):
    """
    Creates a csv file for each table of the database
    """

    csv_path = os.path.dirname(sanit_db)
    zip_file = '.'.join([re.sub("\.sqlite3", sanit_db), '.zip'])
    conn = sqlite3.connect(sanit_db)
    cursor = conn.cursor()
    cmd_cursor = conn.cursor()
    cursor.execute("SELECT name from sqlite_master WHERE type='table'")
    file_list = []
    for table in [row[0] for row in cursor]:
        csv_file = os.path.join(csv_path, table + ".csv")
        file_list.append(csv_file)
        cmd_cursor.execute("SELECT * from %s" % table)
        with open(csv_file, "w") as fh:
            csv_writer = csv.writer(fh)
            for row in cmd_cursor:
                row = list(row)
                for i, c in enumerate(row):
                    try:
                        row[i] = row[i].encode('ascii', errors='ignore')
                    except AttributeError:
                        pass
                csv_writer.writerow(row)
    conn.close()
    with ZipFile(zip_file, 'w') as zip_fh:
        for f in file_list:
            zip_fh.write(f, arcname=os.path.basename(f))
            os.remove(f)
    if VERBOSE:
        print("created csv zipfile: %s" % relpath(zip_file))

    if not os.path.exists(args.db):
        raise RuntimeError("Target database does not exist")


def sanitize_db(db, copy_db_path=None, sanit_db_path=None, create_new=False,
        hashname=True, salt_file=None, copy=True, gen_csv=False):
    if not os.path.exists(db):
        raise RuntimeError("Source database does not exist:", db)
    if not copy_db_path:
        copy_db_path = gen_copy_db_path(db, create_new=create_new)
    if copy:
        copy_cur_db(db, copy_db_path)
    if not salt_file:
        salt_file = re.sub('\.sqlite3?$', '', copy_db_path)
        salt_file = re.sub('_with_salt', '', salt_file)
        salt_file += '.salt'
    if VERBOSE:
        print("salt file: %s" % relpath(salt_file))
    salt = get_salt(salt_file)
    if not os.path.exists(salt_file):
        fh = open(salt_file, 'w')
        print(salt, file=fh)
        if VERBOSE:
            print("created salt file:", relpath(salt_file))
    if copy:
        add_sanit_fields(copy_db_path, salt)
    if not sanit_db_path:
        sanit_db_path = gen_sanit_db_path(db, salt,
                create_new=create_new, hashname=hashname)
    populate_sanit_db(db, sanit_db_path, salt)
    if gen_csv:
        create_csv_files(sanit_db_path)
    return sanit_db_path, copy_db_path, salt_file


def main():
    parser = argparse.ArgumentParser(
        description="Creates sanitized version of database")
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    parser.add_argument("db", help="Database to sanitize")
    parser.add_argument("-n", "--newDb",
            help="Create new database if db of same name found",
            action="store_true", default=False)
    parser.add_argument("-H", "--no-hash",
            help="Do not hash sanitized db filename",
            action="store_true", default=False)
    parser.add_argument("-C", "--no-copy", action="store_true", default=False,
            help="Do not make copy of original DB with salt added")
    parser.add_argument("-s", "--salt-file",
            help="Optional salt file to use/create", default=None)
    parser.add_argument("-c", "--csv", help="export as zip of csv files",
            action="store_true", default=False)
    args = parser.parse_args()

    sanitize_db(args.db, create_new=args.newDb, hashname=not args.no_hash,
            salt_file=args.salt_file, copy=not args.no_copy, gen_csv=args.csv)


if __name__ == "__main__":
    main()
