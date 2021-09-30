# This module is a grab bag of utility settings, functions, and objects
# that are generally useful for most of the scripts in this directory.

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

from __future__ import print_function

import os, sys, re, json, sqlite3, yaml, time
import atexit, tempfile, shutil, itertools, subprocess
import urllib2, requests, argparse
from urllib2 import urlparse
from requests.exceptions import ConnectionError
from glob import glob
from copy import copy
from dateutil.parser import parse as date_parse
from subprocess import CalledProcessError

class ScriptsError(Exception):
    pass

# attempt to normalize verbosity across all scripts and modules

def truthy(val=None):
    try:
        val = abs(int(val))
    except (TypeError, ValueError):
        if str(val).lower() in ("", "no", "false", "0", "none"):
            val = 0
        else:
            val = 1
    return val

class Verbose(object):
    # this is to set up the singleton VERBOSE object, which in addition
    # to providing its value as a boolean or numeric value, is also
    # shared across the scripts that use it. If a script changes
    # verbosity via command line argument, it will be reflected in all
    # modules that use the VERBOSE object. Likewise, if the value is
    # manually set, it will be reflected in all modules that use it.
    def __init__(self, value=False):
        self.value = False if value is None else self.__call__(value)
    def __call__(self, value=None):
        # only set VERBOSE if given something besides None
        if value is not None:
            self.value = truthy(value)
            os.environ["VERBOSE"] = self.__str__()
        return self.value
    def __nonzero__(self):
        return self.value
    # python 3
    __bool__ = __nonzero__
    def __cmp__(self, other):
        return cmp(self.value, other)
    def __pos__(self):
        return self.value
    def __neg__(self):
        return -(self.value)
    def __add__(self, val):
        return self.value + val
    def __sub__(self, val):
        return self.value - val
    def __str__(self):
        return str(self.value) if self.value else ""

# set up the singleton, defaults to False/0 unless environment
# variable is set
VERBOSE = Verbose(os.environ.get("VERBOSE"))

class Verbosity(argparse.Action):
    # This class is for enabling argparse to handle verbosity in such a
    # way that includes increments for extra verbosity -- "-v" is 1,
    # "-vv" is 2, etc
    def __init__(self, option_strings, dest, **kwargs):
        kwargs["nargs"] = 0
        kwargs["metavar"] = None
        kwargs["type"] = None
        kwargs["choices"] = None
        kwargs["required"] = False
        if "help" not in kwargs:
            kwargs["help"] = "Verbose output (repeat for more verbosity)"
        self.verbosity = 0
        super(Verbosity, self).__init__(option_strings, dest, **kwargs)
    def __call__(self, parser, namespace, values=None, option_string=None):
        self.verbosity += 1
        VERBOSE(self.verbosity)
        setattr(namespace, self.dest, self.verbosity)

# All of the script/module/data orientation settings; no need to
# hard-code absolute paths

basename = __file__
if basename.endswith(".pyc"):
    basename = basename[:-1]
# bin_dir might not be scripts_dir
bin_dir = os.path.dirname(os.path.abspath(basename))
# find true basedir even if this is a soft link to bootstrap.py
scripts_dir = os.path.dirname(os.path.abspath(os.path.realpath(basename)))
properties_dir = os.path.join(scripts_dir, "data/properties")
conditions_dir = os.path.join(scripts_dir, "data/conditions")
base_dir = os.path.dirname(scripts_dir)
automation_dir = os.path.join(scripts_dir, "automation")

# let python scripts that aren't in the scripts dir load modules that
# live in the scripts dir (but still let cwd have precedence)
# for example: import automate
if scripts_dir not in sys.path:
    sys.path.insert(1, scripts_dir)

test_dir = os.path.join(base_dir, "test")
python_test_data_dir = os.path.join(test_dir, "python/data")
junit_test_data_dir = os.path.join(test_dir, "junit/test/scale_input")
server_crt_dir = os.path.join(base_dir, "cert")
server_crt_file = os.path.join(server_crt_dir, "cert/server.crt")
tmp_dir = os.path.join(base_dir, "tmp")

if not os.path.exists(tmp_dir):
    os.makedirs(tmp_dir)

# can manually set this here for development if desired -- will override
# the environment variable and the default "development"

RAILS_ENV = None
ASK_RAILS = False

default_env = "development"

def get_rails_env(ask_rails=None):
    if ask_rails is None:
        ask_rails = ASK_RAILS
    env = None
    if RAILS_ENV is not None:
        if ask_rails:
            print("warning: overriding rail_env", file=sys.stderr) 
        env = RAILS_ENV
    else:
        if ask_rails:
            # slow (10 sec to initialize)
            env = rails_config()["env"]
        else:
            # fast
            env = os.getenv("RAILS_ENV") or default_env
    return env

rails_env = get_rails_env()

# We sneak some information from a couple of the rails config files for
# uniformity. (could also interrogate the rail app dynamically, but
# that's slower)

config_dir = os.path.join(base_dir, "config")
db_config_file = os.path.join(config_dir, "database.yml")
scaife_config_file = os.path.join(config_dir, "scaife_servers.yml")

_configs = {}

def db_config(config_file=None):
    if not config_file:
        config_file = db_config_file
    config_file = os.path.realpath(config_file)
    if config_file not in _configs:
        _configs[config_file] = yaml.safe_load(open(config_file))
    return _configs[config_file]

def scaife_config_all(config_file=None):
    # all services by env
    if not config_file:
        config_file = scaife_config_file
    config_file = os.path.abspath(config_file)
    if config_file not in _configs:
        _configs[config_file] = yaml.safe_load(open(config_file))
    config = _configs[config_file]
    return config

def scaife_config(config_file=None, env=None):
    # per-env services
    if not env:
        env = rails_env
    config = scaife_config_all(config_file=config_file)
    if env not in config:
        raise ValueError(
            "environment not found: %s in %s" % (env, config_file))
    return config[env]

# data directories might live somewhere else, based on the SCALE_HOME
# environment variable. scale_dir defaults to base_dir but is maintained
# separately

SCALE_HOME = None
scale_dir = base_dir

def get_scale_home():
    # defaults to relative to this file unless overridden above or
    # by env var
    return SCALE_HOME or os.environ.get("SCALE_HOME") \
            or os.path.abspath(os.path.join(scale_dir, '..'))

scale_home = get_scale_home()

internal_db = None
db_dir = None
external_db = None
external_db_name = None
db_backup_dir = None
db_archive_dir = None
gnu_dir = None

def set_env(rails_env_val=None, scale_home_val=None, scale_dir_val=None):
    # set all variables dependent on rails_env or scale_home
    global RAILS_ENV
    global rails_env
    global SCALE_HOME
    global scale_home
    global scale_dir
    global internal_db
    global db_dir
    global external_db
    global external_db_name
    global db_backup_dir
    global db_archive_dir
    global gnu_dir

    # deal with rails env
    if rails_env_val is not None:
        if not rails_env_val:
            # False, "", 0 unsets
            RAILS_ENV = rails_env = os.environ["RAILS_ENV"] = None
        else:
            if rails_env_val not in db_config():
                raise RuntimeError("unknown rails env: %s" % rails_env_val)
            RAILS_ENV = rails_env = os.environ["RAILS_ENV"] = rails_env_val
    if rails_env is None:
        rails_env = get_rails_env()

    # deal with scale env
    if scale_home_val is not None:
        if not scale_home_val:
            # False, "", 0 unsets
            SCALE_HOME = scale_home = os.environ["SCALE_HOME"] = None
            scale_dir = base_dir
        else:
            scale_home_val = os.path.abspath(scale_home_val)
            SCALE_HOME = scale_home = \
                os.environ["SCALE_HOME"] = scale_home_val
            scale_dir = os.path.join(scale_home, "scale.app")
    elif scale_dir_val is not None:
        # ignored if scale_home was provided
        if not scale_dir_val:
            # False, "", 0, resets
            scale_dir = os.path.join(get_scale_home(), "scale.app")
        else:
            scale_dir = os.path.abspath(scale_dir_val)
            scale_home = os.path.abspath(os.path.join(scale_dir, ".."))
            SCALE_HOME = os.environ["SCALE_HOME"] = scale_home
    else:
        # don't alter SCALE_HOME or env var SCALE_HOME unless handed settings
        scale_home = get_scale_home()
        scale_dir = os.path.join(scale_home, "scale.app")

    # set dependents
    internal_db = os.path.join(scale_dir, db_config()[rails_env]["database"])
    db_dir = os.path.dirname(internal_db)
    external_db = os.path.join(scale_dir, db_config()["external"]["database"])
    external_db_name = os.path.basename(external_db)
    # e.g. scale.app/db/development/backup
    db_backup_dir = os.path.join(db_dir, rails_env, "backup")
    # e.g. scale.app/archive/development/backup
    db_archive_dir = os.path.join(scale_dir, "archive", rails_env, "backup")
    # no clean way to do this per-env (development, test) without
    # exposing in the URLs
    gnu_dir = os.path.join(scale_dir, "public/GNU")

# first initialization of env and data vars
set_env()

### project specific paths

def project_backup_dir(project_id):
    return os.path.join(db_backup_dir, str(project_id))

def project_backup_db(project_id):
    return os.path.join(project_backup_dir(project_id), external_db_name)

def project_archive_dir(project_id):
    return os.path.join(db_archive_dir, str(project_id))

def project_archive_db(project_id):
    return os.path.join(project_archive_dir(project_id), "db.sqlite")

def project_supplemental_dir(project_id):
    return os.path.join(project_archive_dir(project_id), "supplemental")

def project_gnu_dir(project_id):
    return os.path.join(gnu_dir, str(project_id))

def find_project_db(project_id):
    # use either of these external DBs, in order of preference.
    backup_db = project_backup_db(project_id)
    archive_db = project_archive_db(project_id)
    for db_file in (backup_db, archive_db):
        # the backup db, if present, is by definition more up to date
        # than the archive db
        if os.path.exists(db_file):
            return db_file
    return None

def rel2scale_path(path):
    path = os.path.abspath(path)
    if path.startswith(scale_dir):
        path = os.path.relpath(path, scale_dir)
    else:
        # probably in a docker container
        abs_scale_dir = os.path.realpath(scale_dir)
        if path.startswith(abs_scale_dir):
            path = os.path.relpath(path, abs_scale_dir)
    return path

# The data in these JSON files is destined to initialize both the
# internal and external databases.

tool_file = os.path.join(scripts_dir, "tools.json")
tools_table = "Tools"

languages_file = os.path.join(scripts_dir, "languages.json")
languages_table = "Languages"

taxonomies_file = os.path.join(scripts_dir, "taxonomies.json")
taxonomies_table = "Taxonomies"

# tmp dir/file management -- guarantee that they get zapped (optionally)
# on program exit; if keeping them around for development and debugging,
# scale.app/tmp is used rather than /tmp

_tmp_dir = None

def get_tmp_dir(ephemeral=True, suffix=None, purge=True, uniq=True):
    global _tmp_dir
    tdir = None
    if ephemeral:
        if not _tmp_dir:
            _tmp_dir = tempfile.mkdtemp()
            def _tmp_cleanup():
                shutil.rmtree(_tmp_dir, True)
            atexit.register(_tmp_cleanup)
        tdir = _tmp_dir
    else:
        # use scale.app/tmp
        tdir = tmp_dir
    if suffix:
        tdir = os.path.join(tdir, suffix)
        # only purge if keeping results and suffix subdir is provided
        if purge:
            if not ephemeral and suffix and os.path.exists(tdir):
                shutil.rmtree(tdir)
        elif uniq:
            cnt = len(glob("%s*" % tdir))
            while os.path.exists("%s.%03d" % (tdir, cnt)):
                cnt += 1
            tdir = "%s.%03d" % (tdir, cnt)
        if not os.path.exists(tdir):
            os.makedirs(tdir)
    return tdir

def get_tmp_file(basename=None, ephemeral=True):
    suffix = None
    if basename:
        basename = os.path.basename(basename)
        suffix = os.path.dirname(basename)
        if suffix == "/" or not suffix:
            suffix = None
    tmp_dir = get_tmp_dir(ephemeral=ephemeral, suffix=suffix)
    if basename:
        tmp_file = os.path.join(tmp_dir, basename)
    else:
        tmp_file = tempfile.mkstemp(dir=tmp_dir)[-1]
    return tmp_file

### Utility for unpacking various archive formats

unpack_formats = {
        "zip": dict(
            cmd     = "unzip",
            verbose = "--",
            quiet   = "-q",
        ),
        "tar.gz": dict(
            cmd     = "tar",
            verbose = "xvf",
            quiet   = "xf",
        ),
        "tar.bz2": dict(
            cmd     = "tar",
            verbose = "xjfv",
            quiet   = "xjf",
        ),
    }
unpack_formats["tgz"] = unpack_formats["tar.gz"]
unpack_ext_pat = re.compile(r"(%s)$" % '|'.join(unpack_formats.keys()), re.I)

def unpack(fname, tgt_dir=None, verbose=None):
    loud = VERBOSE if verbose is None else verbose
    m = unpack_ext_pat.search(fname)
    if not m:
        raise ValueError("unknown archive type: %s" % fname)
    ext = m.group(1)
    spec = unpack_formats[ext]
    cmd = [spec["cmd"], spec["verbose"] if loud else spec["quiet"], fname]
    pwd = os.getcwd()
    res = None
    try:
        if tgt_dir:
            os.chdir(tgt_dir)
        try:
            res = subprocess.check_output(cmd, stderr=subprocess.STDOUT)
        except CalledProcessError as e:
            msg = str(e)
            if e.output:
                msg += "\nOUTPUT:\n%s" % e.output
            raise Exception(msg)
    finally:
        os.chdir(pwd)
    return res

### handy pythonisms

def is_stringish(item):
    try:
        # python 2
        return isinstance(item, basestring)
    except NameError:
        # python 3
        return isinstance(item, str)

def is_listish(item):
    try:
        () + item
        return True
    except TypeError:
        pass
    try:
        [] + item
        return True
    except TypeError:
        pass
    return False

### Make rails itself do things for us when needed

class RailsCmdError(ScriptsError):
    pass

def run_rails_cmd(rails_cmd, requires=None):
    requires = set(requires or [])
    cwd = os.getcwd()
    dbf = None
    try:
        os.chdir(base_dir)
        cmd = ["bin/rails", "-r", "./config/environment"]
        for req in requires:
            cmd.extend(["-r", req])
        cmd.extend(["-e", rails_cmd])
        res = subprocess.check_output(cmd, stderr=subprocess.STDOUT).strip()
    except CalledProcessError as e:
        msg = "ruby command failed:\n%s" % e.output
        raise RailsCmdError(msg)
    finally:
        os.chdir(cwd)
    return res

_rails_config = None

def rails_config():
    # This is handy if you really need it, but it will take about 10
    # seconds to initialize -- better to make assumtions with the
    # RAILS_ENV environment variable if it is present.
    global _rails_config
    if _rails_config is None:
        cwd = os.getcwd()
        try:
            os.chdir(base_dir)
            cmd = ["bin/rails",
                "-r", "./config/environment",
                "-r", "application_controller",
                "-e", "print ApplicationController.export_config.to_json"]
            res = subprocess.check_output(cmd, stderr=subprocess.STDOUT).strip()
            _rails_config = json.loads(res)
        except CalledProcessError as e:
            msg = "ruby command failed:\n%s" % e.output
            raise RuntimeError(msg)
        finally:
            os.chdir(cwd)
    return _rails_config

### Process and normalize the JSON files for populating newly
### created DBs

_languages_info = None

def languages_info():
    global _languages_info
    if not _languages_info:
        _languages_info = json.load(open(languages_file))
        for name, info in _languages_info.items():
            vers_raw = info["versions"]
            vers_set = set(vers_raw)
            vers = []
            for ver in vers_raw:
                if ver in vers_set:
                    vers.append(ver)
                    vers_set.remove(ver)
            info["versions"] = tuple(vers)
            exts_raw = info["file_extensions"]
            exts_set = set(exts_raw)
            exts = []
            for ext in exts_raw:
                if ext in exts_set:
                    exts.append(ext)
                    exts_set.remove(ext)
            info["file_extensions"] = tuple(exts)
    return _languages_info

def file_exts_to_languages(langs_info=None):
    if not langs_info:
        langs_info = languages_info()
    ext2langs = {}
    for lang_name, li in langs_info.items():
        for ext in li["file_extensions"]:
            ext = ext.lower()
            if ext not in ext2langs:
                ext2langs[ext] = set()
            ext2langs[ext].add(lang_name)
    return ext2langs

def code_archive_ext2lang_map(src_files):
    # frequency distribution on possible languages for each file
    # extension -- the idea being that an ambiguous extension such as .h
    # will be amongst other files, such as .c or .cpp, that will lend
    # heavier weight to disambiguating the original file extension
    ext2langs = file_exts_to_languages()
    exts_seen = set()
    lang_freq = {}
    unknown_exts = set()
    for fname in src_files:
        ext = os.path.splitext(fname)[-1].lower()
        if not ext:
            continue
        if ext.startswith('.'):
            ext = ext[1:]
        if ext not in ext2langs:
            unknown_exts.add(ext)
            continue
        exts_seen.add(ext)
        for lang in ext2langs[ext]:
            if lang not in lang_freq:
                lang_freq[lang] = 0
            lang_freq[lang] += 1
    ext2lang = {}
    for ext in exts_seen:
        lang = None
        last_cnt = 0
        for l in ext2langs[ext]:
            if lang_freq[l] > last_cnt:
                last_cnt = lang_freq[l]
                lang = l
        ext2lang[ext] = lang
    return ext2lang, unknown_exts

class Language(object):
    # utility objects for code languages
    def __init__(self, name, platform, version=None, id_=None):
        self.id_ = id_
        self.name = name
        self.platform = platform
        self.version = version or ""

def lang_by_name(db, name, platform, version=None, table=languages_table):
    con = sqlite3.connect(db)
    cur = con.cursor()
    sql = """
        SELECT * FROM %s
        WHERE name = ? AND platform = ?
    """.strip() % table
    if version is not None:
        sql += " AND version = ?"
        cur.execute(sql, (name, platform, version))
    else:
        cur.execute(sql, (name, platform))
    rows = list(cur.fetchall())
    if len(rows) > 1:
        raise ValueError("language query collision on (%s)"
                % ','.join([name, platform, version or "none"]))
    if rows:
        id_, name, platform, version, scaife_language_id = rows[0]
        return Language(name, platform, version=version, id_=id_)
    else:
        raise ValueError("unknown language for db: %s (%s)" \
            % (','.join([name, platform, version or "none"]), db))

def lang_by_id(db, lang_id, table=languages_table):
    con = sqlite3.connect(db)
    cur = con.cursor()
    cur.execute("SELECT * FROM %s WHERE id = ?" % table, (lang_id,))
    row = cur.fetchone()
    if row:
        id_, name, platform, version, scaife_lang_id = row
        return Tool(name, platform, version=version, id_=id_)
    else:
        raise ValueError("unknown language id for db: %d (%s)" % (lang_id, db))

def load_languages(db, table=languages_table):
    con = sqlite3.connect(db)
    cur = con.cursor()
    cur.execute("SELECT * FROM %s" % table)
    for id_, name, platform, version, _scaife_id in cur:
        yield Language(name, platform, version=version, id_=id_)

###

_tools_info = None

def tools_info():
    global _tools_info
    if not _tools_info:
        lang_info = languages_info()
        tools_seen = set()
        _tools_info = json.load(open(tool_file))
        for ti in _tools_info:
            if ti["name"] in tools_seen:
                raise ValueError("tool definition collision: %s" % ti["name"])
            tools_seen.add(ti["name"])
            ti["type"] = tool_type = ti.get("type", "sca")
            vers = []
            for ver in ti["versions"]:
                if ver not in vers:
                    vers.append(ver)
            ti["versions"] = tuple(vers)
            oses = []
            for os in ti["oses"]:
                if os not in oses:
                    oses.append(os)
            ti["oses"] = tuple(oses)
            raw_langs = ti["languages"]
            ti["languages"] = []
            for lang_group in raw_langs:
                if list != type(lang_group):
                    lang_group = [lang_group]
                lang_group = tuple(lang_group)
                if lang_group not in ti["languages"]:
                    ti["languages"].append(lang_group)
            ti["languages"] = tuple(ti["languages"])
            platforms = []
            for lang_group in ti["languages"]:
                if ti["type"] == "metric":
                    platforms = ["metric"]
                    break
                plats = []
                for lang in lang_group:
                    if lang not in lang_info:
                        raise ValueError("unknown language for tool '%s': %s" \
                                % (ti["name"], lang))
                    else:
                        p = lang_info[lang]["platform"]
                        if p not in plats:
                            plats.append(p)
                platforms.append(tuple(plats))
            ti["platforms"] = tuple(platforms)
    return tuple(_tools_info)

class Tool(object):
    # utility object for tools
    def __init__(self, name, platforms, version=None, label=None, id_=None):
        self.id_ = id_
        self.name = name
        self.version = version or ""
        self.label = label or ""
        if list != type(platforms):
            try:
                platforms = json.loads(platforms)
            except ValueError:
                if '/' in platforms:
                    platforms = platforms.split('/')
                else:
                    platforms = [platforms]
        self.platforms = platforms

    @property
    def platform_str(self):
        return '/'.join(self.platforms)

    @property
    def platform_json(self):
        return json.dumps(self.platforms)

    @property
    def tool_group_key(self):
        # this is the form parameter used in SCALe web queries
        return '-'.join([self.name, '-'.join(self.platforms)])


def tool_by_name(db, name, platforms, version=None, table=tools_table):
    if list != type(platforms):
        try:
            platforms = json.loads(platforms)
        except ValueError:
            platforms = platforms.split('/')
    platform_json = json.dumps(platforms)
    con = sqlite3.connect(db)
    cur = con.cursor()
    sql = """
        SELECT * FROM %s
        WHERE name = ? AND platform = ?
    """.strip() % table
    if version is not None:
        sql += " AND version = ?"
        cur.execute(sql, (name, platform_json, version))
    else:
        cur.execute(sql, (name, platform_json))
    rows = list(cur.fetchall())
    if len(rows) > 1:
        raise ValueError("tool query collision on (%s)"
                % ','.join([name, '/'.join(platforms), version or "none"]))
    if rows:
        id_, name, platform_json, version, label, scaife_tool_id = rows[0]
        platforms = json.loads(platform_json)
        return Tool(name, platforms, version=version, label=label, id_=id_)
    else:
        raise ValueError("unknown tool for db: %s (%s)" \
            % (','.join([name, '/'.join(platforms), version or "none"]), db))

def tool_by_id(db, tool_id, table=tools_table):
    con = sqlite3.connect(db)
    cur = con.cursor()
    cur.execute("SELECT * FROM %s WHERE id = ?" % table, (tool_id,))
    row = cur.fetchone()
    if row:
        id_, name, platforms, version, label, scaife_tool_id = row
        return Tool(name, platforms, version=version, label=label, id_=id_)
    else:
        raise ValueError("unknown tool id for db: %d (%s)" % (tool_id, db))

def load_tools(db, table=tools_table):
    con = sqlite3.connect(db)
    cur = con.cursor()
    cur.execute("SELECT * FROM %s" % table)
    for id_, name, platforms, version, language, label in cur.fetchall():
        yield Tool(name, platforms, version=version, label=label, id_=id_)

###

_taxonomies_info = None

def taxonomies_info():
    global _taxonomies_info
    if not _taxonomies_info:
        _taxonomies_info = []
        raw = json.load(open(taxonomies_file))
        for tgroup in raw:
            ti = {}
            version_order = 0.0
            for group_key in (
                    "user_org_id", "user_id", "author_source", "type"):
                ti[group_key] = tgroup[group_key]
            default_format = tgroup.get("default_format", None)
            for taxonomy in tgroup["taxonomies"]:
                versions = taxonomy.pop("versions")
                tti = copy(ti)
                tti.update(taxonomy)
                # version_brief is for finding taxonomy filenames to import
                # version (full) eventually ends up in the database
                for vi in versions:
                    version = vi.get("version")
                    version_brief = vi.get("version_brief")
                    if not version_brief and version:
                        version_brief = version.lower()
                        version_brief = re.sub(r"\s+", "_", version_brief)
                    elif version_brief.lower() in ("default", "none"):
                        version_brief = None
                    tti["version_brief"] = version_brief
                    tti["version"] = version or version_brief
                    tti["format"] = vi.get("format", default_format)
                    tti["version_order"] = version_order
                    _taxonomies_info.append(tti)
                    version_order += 1
    return _taxonomies_info

### Whenever a script needs to deal with properties files, this is handy

_properties_walk = None

def properties_files(tool):
    global _properties_walk
    if not _properties_walk:
        _properties_walk = tuple(os.walk(properties_dir))
    prop_files = []
    for platform in tool.platforms:
        paths = []
        plat_tool = '.'.join([platform, tool.name])
        for root, sub_directories, file_list in _properties_walk:
            for f in file_list:
                if plat_tool in f:
                    paths.append(os.path.join(root, f))

        # Handle files with versions
        for file_path in paths:
            if ".v." in file_path:
                file_version = file_path.split(".v.")[1].split(".properties")[0]
                if (file_version == tool.version):
                    prop_files.append(file_path)
            else:
                # always include versionless file if present
                prop_files.append(file_path)

    # need to normalize the filesystem order across systems
    # for when comparing DBs in tests
    return sorted(prop_files)

###

def version_sort(versions):
    return [p[1] for p in sorted((version_split(v), v) for v in versions)]

def version_split(vstr):
    parts = []
    def num(x):
        return re.match(r"\d", x)
    def let(x):
        return re.match(r"[a-z]", x, re.I)
    for i, c in enumerate(vstr):
        if not parts:
            parts.append(c)
            continue
        state = parts[-1]
        new = vstr[i]
        if num(state):
            if num(new):
                parts[-1] += new
                continue
            else:
                parts[-1] = int(parts[-1])
                parts.append(new)
                continue
        elif let(state):
            if let(new):
                parts[-1] += new
                continue
            else:
                parts.append(new)
                continue
        else:
            if num(new) or let(new):
                parts.append(new)
                continue
            else:
                parts[-1] += new
                continue
    return parts

###

class ServiceException(Exception):
    pass

class ServiceTimeout(ServiceException):
    pass

class ServiceUnknown(ServiceException):
    pass

default_svc_timeout = 30

def scale_server_uses_ssl():
    return os.path.exists(server_crt_file)

def service_is_up(host, port=None):
    import socket
    if not port and ':' in host:
        m = re.search(r"^([^:]+):(\d+)", host)
        host, port = m.group(1), m.group(2)
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        res = sock.connect_ex((host, int(port)))
        return True if res == 0 else False
    except socket.error:
        return None
    finally:
        sock.close()

def wait_for_service(host, port=None, timeout=None, label=None, loud=False):
    if timeout is None:
        # allow timeout=0 or timeout=False
        timeout = default_svc_timeout
    timeout = abs(int(timeout))
    mark = time.time()
    while (time.time() - mark) < timeout or not timeout:
        status = service_is_up(host, port=port)
        if status:
            if VERBOSE:
                if label:
                    print("service is up for %s: %s:%s" % (label, host, port))
                else:
                    print("service is up: %s:%s" % (host, port))
            return True
        if status is None:
            if label:
                msg = "service does not exist for %s: %s %s" \
                        % (label, host, port)
            else:
                msg = "service does not exist: %s %s" % (host, port)
            raise ServiceTimeout(msg)
        if not timeout:
            # just looking for immediate status
            break
        elapsed = int(time.time() - mark)
        if loud and not elapsed % 5:
            if label:
                print("waiting for service for %s: %s %s (%s/%s secs)"
                        % (label, host, port, elapsed, timeout))
            else:
                print("waiting for service: %s %s (%s/%s secs)"
                        % (host, port, elapsed, timeout))
            sys.stdout.flush()
        time.sleep(1)
    if label:
        msg = "service timed out for %s: %s:%s after %d secs" \
                % (label, host, port, timeout)
    else:
        msg = "service timed out: %s:%s after %d secs" \
                % (host, port, timeout)
    raise ServiceTimeout(msg)


class Service(object):

    def __init__(self, name=None, host=None, port=None, url=None,
            expected_response=None, check_json=True, label=None,
            loud=None):
        # can be a named service, but doesn't have to be, can
        # just be host:port or a url
        if not host and not name and not url:
            raise ValueError("service name or host name required, " \
                    "either directly or via url")
        self._name = name
        if not host and name:
            host = name
        if url and host is None:
            # possibly pull host out of url if host not provided
            u = urlparse.urlparse(url)
            if u.netloc:
                host, p = urllib2.splitport(u.netloc)
        if not host:
            host = "localhost"
        if port is None:
            # this might only happen if no url was provided but
            # "host:port" was
            host, port = urllib2.splitport(host)
        if port is None and url:
            u = urlparse.urlparse(url)
            h, port = urllib2.splitport(u.netloc)
            if port is None:
                if u.scheme == "http":
                    port = 80
                elif u.scheme == "https":
                    port = 443
        if port is None:
            raise ValueError("port must be provided directly or via url")
        self.expected_response = expected_response
        self.check_json = check_json
        self.host = host
        self.port = int(port)
        self.url = url
        self.loud = (VERBOSE > 1) if loud is None else loud
        self._label = label
        self._status = None

    @property
    def name(self):
        return self._name if self._name else str(self)

    def port_status(self):
        return service_is_up(self.host, self.port)

    def status(self):
        # immediately report status
        try:
            self.wait_until_up(timeout=0)
            return True
        except ServiceTimeout:
            return False

    def cached_status(self):
        if self._status is None:
            self._status = self.status()
        return self._status

    @property
    def label(self):
        # for labeling test messages with module name or other info
        label = None
        if self._label:
            if self.name:
                if self.name not in self._label:
                    label = "%s/%s" % (self._label, self.name)
                else:
                    label = self.name
            else:
                label = self._label
        else:
            label = self.name
        return label

    def wait_until_up(self, timeout=None, loud=None):
        # wait for port to be active, then also wait for valid response
        # if service url has been defined
        loud = self.loud if loud is None else loud
        try:
            if self.wait_until_port_active(timeout=timeout, loud=loud):
                if self.url:
                    self.wait_until_valid_response(timeout=timeout, loud=loud)
                    self._status = True
                else:
                    self._status = True
            else:
                self._status = False
        except ServiceTimeout as e:
            self._status = False
            raise e
        return self._status

    def wait_until_port_active(self, timeout=None, loud=None):
        loud = self.loud if loud is None else loud
        return wait_for_service(self.host, port=self.port,
                    timeout=timeout, label=self.label, loud=loud)

    def wait_until_valid_response(self, timeout=None, loud=None):
        if not self.url:
            return True
        loud = self.loud if loud is None else loud
        if timeout is None:
            timeout = default_svc_timeout
        sleep_interval = 2
        timeout = abs(int(timeout))
        if self.check_json:
            headers = {'Content-Type': 'application/json'}
        else:
            headers = None
        mark = time.time()
        while (time.time() - mark) < timeout or not timeout:
            try:
                response = requests.get(self.url, headers=headers,
                        timeout=sleep_interval)
            except ConnectionError as e:
                if not timeout:
                    break
                time.sleep(sleep_interval)
                continue
            if response.status_code != 200:
                if not timeout:
                    break
                elapsed = int(time.time() - mark)
                if loud and not elapsed % 5:
                    elapsed = int(time.time() - mark)
                    if self.label:
                        print("wait for service response for %s: "
                                "%s (%s/%s secs)"
                                % (self.label, self.url, elapsed, timeout))
                    else:
                        print("wait for service response: %s (%s/%s secs)"
                                % (self.url, elapsed, timeout))
                    sys.stdout.flush()
                time.sleep(sleep_interval)
                continue
            if self.expected_response:
                content = response.json() \
                        if self.check_json else response.text
                if callable(self.expected_response):
                    # outsource the check to the caller
                    valid = self.expected_response(content)
                else:
                    valid = (content == self.expected_response)
                if valid:
                    if VERBOSE:
                        if self.label:
                            print("service is responding for %s: %s"
                                    % (self.label, self.url))
                        else:
                            print("service is responding: %s" % self.url)
                    # response is valid
                    return content
                elif not timeout:
                    return False
            else:
                # not comparing content, just http 200
                return True
            time.sleep(sleep_interval)
        if self.label:
            msg = "service response timed out for %s after %d secs: %s" \
                    % (self.label, timeout, self.url)
        else:
            msg = "service response timed out after %d secs: %s" \
                    % (timeout, self.url)
        raise ServiceTimeout(msg)

    @property
    def up(self):
        return self.cached_status()

    def clear(self):
        self._status = None

    @property
    def message(self):
        status = "up" if self.cached_status() else "down"
        if self.label:
            msg = "service is %s for %s: %s:%s" \
                    % (status, self.label, self.host, self.port)
        else:
            msg = "service is %s : %s:%s" % (status, self.host, self.port)
        return msg

    def __str__(self):
        return "%s:%s" % (self.host, self.port)

    # the Service object will evaluate to True/False depending on status

    # python 2
    __nonzero__ = cached_status
    # python 3
    __bool__ = cached_status


def load_services_from_config(config_file=None, env=None,
        localhost=False, label=None):
    services = {}
    config = scaife_config(config_file=config_file, env=env)
    for svc, host in config.items():
        if svc == "automation":
            continue
        url = expected = None
        host, port = urllib2.splitport(host)
        if localhost:
            host = "localhost"
        if svc == "pulsar":
            # need a better way to handle fancy services than making
            # exceptions here by name
            url = "http://%s:%s/admin/v2/worker/cluster" % (host, 8080)
            def _expected(data):
                data = data[0]
                keys = ("workerId", "workerHostname", "port")
                return all(x in data for x in keys)
            expected = _expected
        services[svc] = Service(name=svc, host=host, port=port,
                url=url, expected_response=expected, label=label)
    return services

def assert_services_are_up(include=None, exclude=None, localhost=False):
    services = this_module(localhost=localhost)._filter_services(
            include=include, exclude=exclude)
    services_up = []
    services_down = []
    for svc in services:
        if svc:
            services_up.append(svc)
        else:
            services_down.append(svc)
    message = "services not up: %s" \
            % ', '.join(svc.name for svc in services_down)
    assert not services_down, message
    return services_up

def wait_for_services(timeout=None, include=None, exclude=None,
        localhost=False, loud=None):
    module = this_module(localhost=localhost)
    mod_found = None
    if include:
        if module.name in include:
            mod_found = True
        include = [x for x in include if x != module.name]
    if exclude:
        if module.name in exclude:
            mod_found = False
        exclude = [x for x in exclude if x != module.name]
    # If no includes or excludes were provided, wait for the module and
    # all services. If anything at all was included or excluded, only
    # pay attention to those; if the only thing included was the module
    # itself then test for the module but not its services.
    if mod_found or mod_found is None:
        module.wait_until_up(timeout=timeout, loud=loud)
    if include or exclude or (include is None and exclude is None):
        module.wait_for_services(timeout=timeout, include=include,
                exclude=exclude, loud=loud)


class ScaifeModuleError(Exception):
    pass

class ScaifeModule(object):

    _service = None
    _services = {}

    def __init__(self, name=None, localhost=False, loud=None):
        # some of this logic makes more sense for the other SCAIFE
        # modules, adapted for SCALe here
        if name is None:
            name = "default"
        self.name = name
        self.localhost = localhost
        self.base_dir = base_dir
        self.config_dir = os.path.join(self.base_dir, "config")
        self.config_file = os.path.join(self.config_dir, "scaife_servers.yml")
        self.db_config_file = os.path.join(config_dir, "database.yml")
        self.loud = (VERBOSE > 1) if loud is None else loud

    def _load_services(self):
        if os.path.exists(self.config_file):
            self._services = \
                load_services_from_config(self.config_file,
                        localhost=self.localhost)
            if self.name in self._services:
                self._service = self._services.pop(self.name)
        return self._services

    @property
    def service(self):
        if not self._service:
            self._load_services()
        return self._service

    @property
    def services(self):
        # other services defined in servers.conf
        if not self._services:
            self._load_services()
        return list(self._services.values())

    @property
    def services_by_name(self):
        return dict((x.name, x) for x in self.services)

    def wait_until_up(self, timeout=None, include_services=False,
            loud=None):
        loud = self.loud if loud is None else loud
        self.service.wait_until_up(timeout=timeout, loud=loud)
        if include_services:
            self.wait_for_services(timeout=timeout, loud=loud)

    # the ScaifeModule object will evaluate to True/False depending
    # on primary service status (which also evaluates boolean)
    def __bool__(self):
        return self.service

    def _filter_services(self, include=None, exclude=None):
        if not self._services:
            self._load_services()
        svcs_present = self._services
        if not svcs_present:
            raise ValueError(
                "no services for %s" % self.name)
        if not include:
            include = svcs_present
        include = set(include or [])
        inc_unknown = include.difference(svcs_present)
        if inc_unknown:
            raise ValueError("cannot include unknown services for %s: %s"
                % (self.name, ', '.join(sorted(inc_unknown))))
        exclude = set(exclude or [])
        if exclude:
            exc_unknown = exclude.difference(svcs_present)
            if exc_unknown:
                raise ValueError("cannot exclude unknown modules for %s: %s" 
                    % (self.name, ', '.join(sorted(exc_unknown))))
            include.difference_update(exclude)
        if not include:
            raise ValueError("no services selected for %s from: %s"
                % (self.name, ', '.join(svcs_present)))
        return [svcs_present[x] for x in sorted(include)]

    def wait_for_services(self, timeout=None, include=None, exclude=None,
            loud=None):
        # waiting for everything besides this module
        loud = self.loud if loud is None else loud
        for svc in self._filter_services(include=include, exclude=exclude):
            if VERBOSE == 2 and not loud and timeout is not False:
                print("waiting for service: %s" % svc.name)
                sys.stdout.flush()
            svc.wait_until_up(timeout=timeout, loud=loud)


def this_module(localhost=False):
    return ScaifeModule("scale", localhost=localhost)

def this_service(localhost=False):
    return this_module(localhost=localhost).service

def scale_service(localhost=False):
    return this_service(localhost=localhost)


### Some useful database integrations and utilities

def get_project_ids():
    con = sqlite3.connect(internal_db)
    cur = con.cursor()
    cur.execute("SELECT id FROM projects")
    ids = sorted(int(row[0]) for row in cur)
    return ids

def get_latest_project_id():
    pids = get_project_ids()
    return pids[-1] if pids else None

def get_project_id_and_name(project_name_or_id):
    project_name = project_id = None
    try:
        project_id = int(project_name_or_id)
    except ValueError:
        project_name = project_name_or_id
    if project_id == 0:
        return 0, ""
    found_id = found_name = None
    with sqlite3.connect(internal_db) as con:
        cur = con.cursor()
        for pid, name in cur.execute("SELECT id, name FROM projects"):
            pid = int(pid)
            if project_name and name == project_name:
                found_id = pid
                found_name = name
                break
            elif project_id and pid == project_id:
                found_name = name
                found_id = pid
                break
    if not found_id:
        raise ValueError(
            "Project '%s' not found in SCALe app" % project_name_or_id)
    return found_id, found_name

def get_project_id(project_name_or_id):
    return get_project_id_and_name(project_name_or_id)[0]

# rudimentary ORDB hook for representing tables

class DBObject(object):

    def __init__(self, obj_id, table, db=None):
        self.id_ = int(obj_id)
        self.table = table
        self.db = db or internal_db
        self._con = None
        self._columns = None
        self._values = None
        # initialize object attributes to table schema
        self.columns()
        self.values()

    @property
    def con(self):
        # persistent DB connection for lifetime of object
        if not self._con:
            self._con = sqlite3.connect(self.db)
        return self._con

    def columns(self):
        if self._columns is None:
            # initialize column names
            cur = self.con.cursor()
            cur.execute(
                "SELECT name, type FROM pragma_table_info(?)", (self.table,))
            self._columns = []
            for name, typ in ((x.lower(), y.lower()) for x, y in cur):
                if name != "id":
                    setattr(self, name, None) 
                    if typ == "int":
                        typ = int
                    elif typ == "float":
                        typ = float
                    elif typ == "datetime":
                        typ = date_parse
                    else:
                        typ = None
                    self._columns.append((name, typ))
            self._columns = tuple(self._columns)
        return self._columns

    def values(self):
        # map a single row of this table into this object, creating an
        # attribute named after the column name and setting the value to
        # the corresponding row data.
        cols = self.columns()
        cur = self.con.cursor()
        cur.execute("""
            SELECT %s FROM %s WHERE id = ?
        """.strip() % (', '.join(x[0] for x in cols), self.table), (self.id_,))
        self._values = []
        for (c, typ), v in itertools.izip(cols, cur.fetchone()):
            if typ and v not in (True, False, None):
                v = typ(v)
            self._values.append(v)
            setattr(self, c, v)

# these all inherit from the DB superclass

class Project(DBObject):

    def __init__(self, project_name_or_id=None, db=None, external=False):
        if project_name_or_id is None:
            project_name_or_id = 1
        pid = get_project_id(project_name_or_id)
        if db is None:
            if external:
                for db in project_backup_db(pid), project_archive_db(pid):
                    if os.path.exists(db):
                        self.db = db
                        break
            else:
                db = internal_db
        table = "Projects" if external else "projects"
        if external:
            DBObject.__init__(self, 0, table, db=db)
        else:
            DBObject.__init__(self, pid, table, db=db)
        self.external = external

    def language_ids(self):
        table = "ProjectLanguages" if self.external else "project_languages"
        cur = self.con.cursor()
        cur.execute("""
            SELECT language_id FROM project_languages
            WHERE project_id = ?
        """.strip(), (self.id_,))
        ids = set(int(row[0]) for row in cur)
        return ids

    def taxonomy_ids(self):
        table = "ProjectTaxonomies" if self.external else "project_taxonomies"
        cur = self.con.cursor()
        cur.execute("""
            SELECT taxonomy_id FROM project_taxonomies
            WHERE project_id = ?
        """.strip(), (self.id_,))
        ids = set(int(row[0]) for row in cur)
        return ids

    def tool_ids(self):
        table = "ProjectTools" if self.external else "project_tools"
        cur = self.con.cursor()
        cur.execute("""
            SELECT tool_id FROM project_tools
            WHERE project_id = ?
        """.strip(), (self.id_,))
        ids = set(int(row[0]) for row in cur)
        return ids

    def checker_ids(self):
        tables = {}
        if self.external:
            tables["checkers"] = "Checkers"
            tables["project_tools"] = "ProjectTools"
        else:
            tables["checkers"] = "checkers"
            tables["project_tools"] = "project_tools"
        cur = self.con.cursor()
        cur.execute("""
            SELECT DISTINCT %(checkers)s.id FROM %(checkers)s
            JOIN %(project_tools)s
              ON %(project_tools)s.tool_id = %(checkers)s.tool_id
            WHERE %(project_tools)s.project_id = ?
        """.strip() % tables, (self.id_,))
        ids = set(int(row[0]) for row in cur)
        return ids

    def condition_ids(self):
        tables = {}
        if self.external:
            tables["conditions"] = "Conditions"
            tables["project_taxonomies"] = "ProjectTaxonomies"
        else:
            tables["conditions"] = "conditions"
            tables["project_taxonomies"] = "project_taxonomies"
        cur = self.con.cursor()
        cur.execute("""
            SELECT DISTINCT %(conditions)s.id FROM %(conditions)s
            JOIN %(project_taxonomies)s
              ON %(project_taxonomies)s.taxonomy_id = %(conditions)s.taxonomy_id
            WHERE %(project_taxonomies)s.project_id = ?
        """.strip() % tables, (self.id_,))
        ids = set(int(row[0]) for row in cur)
        return ids

    def alert_ids(self):
        tables = {}
        if self.external:
            tables["alerts"] = "Alerts"
            tables["messages"] = "Messages"
        else:
            tables["displays"] = "displays"
        cur = self.con.cursor()
        if self.external:
            cur.execute("""
                SELECT DISTINCT %(alerts)s.id FROM %(alerts)s
                JOIN %(messages)s
                  ON %(messages)s.alert_id = %(alerts)s.id
            """.strip() % tables)
        else:
            cur.execute("""
                SELECT DISTINCT %(displays)s.alert_id FROM %(displays)s
                WHERE %(displays)s.project_id = ?
            """.strip() % tables, (self.id_,))
        ids = set(int(row[0]) for row in cur)
        return ids

    def meta_alert_ids(self):
        tables = {}
        if self.external:
            tables["meta_alerts"] = "MetaAlerts"
            tables["meta_alert_links"] = "MetaAlertLinks"
            tables["alerts"] = "Alerts"
            tables["messages"] = "Messages"
        else:
            tables["displays"] = "displays"
        cur = self.con.cursor()
        if self.external:
            cur.execute("""
    SELECT DISTINCT %(meta_alerts)s.id FROM %(meta_alerts)s
    JOIN %(meta_alert_links)s ON %(meta_alert_links)s.meta_alert_id = %(meta_alerts)s.id
    JOIN %(alerts)s ON %(alerts)s.id == %(meta_alert_links)s.alert_id
    JOIN %(messages)s
      ON %(messages)s.alert_id = %(alerts)s.id
            """.strip() % tables)
        else:
            cur.execute("""
                SELECT DISTINCT %(displays)s.meta_alert_id FROM %(displays)s
                WHERE %(displays)s.project_id = ?
            """.strip() % tables, (self.id_,))
        ids = set(int(row[0]) for row in cur)
        return ids
