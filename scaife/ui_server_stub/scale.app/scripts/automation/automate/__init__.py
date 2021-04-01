# -*- coding: UTF-8 -*-

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

import sys, os, re, sqlite3, json, yaml, subprocess
#from urllib import urljoin
from subprocess import CalledProcessError
from urlparse import urljoin
from glob import glob
from bs4 import BeautifulSoup

import bootstrap

# Notes on usage
#
# Create an instance of ScaleSession, the defaults are typically sufficient:
#  s = ScaleSession()
#
# The methods begining with query_* correspond to a single
# controller/action in the SCALe rails app.

# The methods begining with event_* correspond to a user interaction
# that triggers more than one controller/action to be called in the
# SCALe app. This is usually due to ajax calls from the web browser or
# redirects within the rails framework. but the individual actions have
# to be explicitly called here in order to replicate the equivalent
# effect in the SCALe project (and session cookie, etc).
#
# So a "recipe" for accomplishing a task in SCALe using this module will
# end up looking something like:
#
#  1. query
#  2. query
#  2. event, which calls:
#     2a. query
#     2b. query
#  3. query
#
# Events do just fine calling other events as well, not just queries.
#
# To see an example of how to set up a basic dos2unix/rosecheckers
# project, see scripts/automation/create_manual_project. It demonstrates
# a basic template and uses the event_project_create() query cascade.
#
# There is an authentication token that rails supposedly uses to prevent
# session hijacking. It is extracted from the html of the page preceding
# any form submissions that theoreticaly check for the presence of the
# token. In practice this token doesn't seem to be required all the
# time, but it is included by default in the methods below. In many
# cases the page that would have naturally been loaded prior to an
# action will be loaded below in order to fully simulate what would be
# happening during a real user session. This pre-load (and auth token
# extraction) is referred to as "priming" in the code below.

# True, False, 1, 2, ... a value of 2 or higher will print out full
# command line invocations of curl
from bootstrap import VERBOSE

# disable this in order to use persistent (not deleted afterwards) tmp
# file names in scale.app/tmp -- mostly for use in curl invocations
# during development of new automation recipes
EPHEMERAL_TMP = True

class ScaleSession(object):

    # class variable shared across session instances
    engines = {}

    @classmethod
    def register_engine(cls, name, f):
        cls.engines[name] = f

    def __init__(self, host="localhost", port="8083", user=None, passwd=None,
            engine="curl", use_ssl=None):
        if use_ssl is None:
            self.use_ssl = bootstrap.scale_server_uses_ssl()
        else:
            self.use_ssl = use_ssl
        protocol = "https" if self.use_ssl else "http"
        self.base_url = "%s://%s:%s" % (protocol, host, port)
        if not (user and passwd):
            user, passwd = default_user_pass()
        self.user = user
        self.passwd = passwd
        self.scaife_active = False
        self.scaife_registered = set()
        self.scaife_user = None
        self.scaife_passwd = None
        self.auth_token = None
        self.last_url = None
        self.db_file = bootstrap.internal_db
        self.db_con = None
        self.cookie_file = bootstrap.get_tmp_file(
                basename="auto.cookies.txt", ephemeral=EPHEMERAL_TMP)
        self._newest_project_id = None
        self._current_project_id = None
        if engine not in self.engines:
            raise ValueError("unknown query engine: '%s'" % engine)
        self.engine = engine

    @property
    def con(self):
        if not self.db_con:
            self.db_con = sqlite3.connect(self.db_file)
        return self.db_con

    def post(self, url, params, auth=True, set_referrer=True):
        if "authenticity_token" not in params and self.auth_token and auth:
            params["authenticity_token"] = self.auth_token
        res = self.engines[self.engine](url, params,
                cookie_file=self.cookie_file, use_ssl=self.use_ssl,
                user=self.user, passwd=self.passwd,
                referrer=self.last_url, method="POST")
        if auth:
            self.extract_auth_token(res)
        if set_referrer:
            self.last_url = url
        return res

    def get(self, url, params=None, auth=True, set_referrer=True):
        res = self.engines[self.engine](url, params=params,
                cookie_file=self.cookie_file, use_ssl=self.use_ssl,
                user=self.user, passwd=self.passwd,
                referrer=self.last_url, method="GET")
        if auth:
            self.extract_auth_token(res)
        if set_referrer:
            self.last_url = url
        return res

    def put(self, url, params, auth=True, set_referrer=True):
        params["_method"] = "put"
        res = self.engines[self.engine](url, params=params,
                cookie_file=self.cookie_file, use_ssl=self.use_ssl,
                user=self.user, passwd=self.passwd,
                referrer=self.last_url, method="PUT")
        if auth:
            self.extract_auth_token(res)
        if set_referrer:
            self.last_url = url
        return res

    def delete(self, url, params=None, auth=True,
            set_referrer=True, follow_redirects=False):
        res = self.engines[self.engine](url, params=params,
                cookie_file=self.cookie_file, use_ssl=self.use_ssl,
                user=self.user, passwd=self.passwd,
                referrer=self.last_url, accept_json=True,
                accept_additional_codes=[204],
                method="DELETE")
        if auth:
            self.extract_auth_token(res)
        if set_referrer:
            self.last_url = url
        return res

    def current_project_ids(self):
        cur = self.con.cursor()
        cur.execute(
            "SELECT id, created_at FROM projects ORDER BY created_at, id")
        ids = [int(r[0]) for r in cur.fetchall()]
        return ids

    def project_name(self, project_id=None):
        if not project_id:
            project_id = self.project_id
        cur = self.con.cursor()
        cur.execute("SELECT name FROM projects WHERE id = ?", (project_id,))
        try:
            return cur.fetchone()[0]
        except TypeError:
            raise ValueError("invalid project ID: %s" % project_id)

    def update_project_ids(self):
        pids = self.current_project_ids() or []
        if pids:
            self._newest_project_id = pids[-1]
            self._current_project_id = pids[-1]
        else:
            self._newest_project_id = None
            self._current_project_id = None
        return pids

    def set_project_id(self, pid):
        pids = self.update_project_ids()
        if pid not in pids:
            raise ValueError("project id does not exists: %s" % pid)
        self._current_project_id = pid

    def set_project_id_to_newest(self):
        self.update_project_ids()
        return self.project_id

    @property
    def project_id(self):
        if self._current_project_id is None:
            self.update_project_ids()
        return self._current_project_id

    @property
    def newest_project_id(self):
        if self._newest_project_id is None:
            self.update_project_ids()
        return self._newest_project_id

    def extract_auth_token(self, html):
        try:
            soup = BeautifulSoup(html, 'lxml')
        except TypeError:
            return None
        token = None
        # the statically rendered form field value gets overwritten
        # by javascript apparently, so isn't the right token
        #for tag in soup.find_all("input"):
        #    if tag.get("name") == "authenticity_token":
        #        token = tag["value"]
        csrf = None
        for tag in soup.find_all("meta"):
            if tag.get("name") == "csrf-token":
                csrf = tag.get("content")
        if token or csrf:
            self.auth_token = token or csrf
        return token

    def route(self, path=None):
        return urljoin(self.base_url, path or "")

    def _normalize_bool_param(self, val, short=False):
        if val is not None:
            if str(val) == "0" or not val or str(val).lower()[0] == 'f':
                val = 'false'
            else:
                val = 'true'
            if short:
                val = val[0]
        return val

    def default_params(self):
        return {
            "utf8": "✓",
            #"scaife_mode_select": "Demo",
        }

    ### these are just page loaders (not updating the database)

    def query_index(self):
        # splash page
        if VERBOSE:
            print("query_index()")
        return self.get(self.route())

    def query_project(self, fused=None):
        # load the alerts page for a project
        # note: in order to change fused vs unfused, this is the place
        #       if it hasn't been set yet it will default to 'fused'
        if VERBOSE:
            print("query_project()")
        path = "projects/%s" % self.project_id
        if fused is not None:
            if not fused or str(fused).lower() == "unfused":
                path += "/unfused"
            else:
                path += "/fused"
        return self.get(self.route(path))

    def query_project_new_form(self):
        # pulls up the create project form
        if VERBOSE:
            print("query_project_new_form()")
        path = "projects/new"
        return self.get(self.route(path))

    def query_project_database_form(self):
        # pulls up the database page (select tools, etc)
        if VERBOSE:
            print("query_project_database_form()")
        path = "projects/%s/database" % self.project_id
        return self.get(self.route(path))

    ### these actually make updates to a SCALe project

    def query_project_create_submit(self, name,
            description=None, primed=False):
        # create project with name and description
        if VERBOSE:
            print("query_project_create_submit()")
        path = "projects"
        params = self.default_params()
        params.update({
            "project_type": "scale",
            "project": {
              "name": name,
              "description": description,
            },
            "commit": "Create Project",
        })
        # requires auth token (but still works without it...)
        if not primed:
            self.query_project_new_form()
        html = self.post(self.route(path), params)
        # set self.project_id to newly created project
        self.update_project_ids()
        return html

    def query_project_destroy(self, primed=True):
        if VERBOSE:
            print("query_project_destroy()")
        path = "projects/%s" % self.project_id
        if not primed:
            self.query_index()
        return self.delete(self.route(path))

    def query_project_database_submit(self, primed=False,
            src_file  = None,
            src_url   = None,
            tools     = {},
            languages = [],
            is_test_suite      = "false",
            test_suite_name    = "",
            test_suite_version = "",
            test_suite_type    = "",
            test_suite_sard_id = "",
            author_source      = "",
            license_string     = "",
            manifest_file      = "",
            manifest_url       = "",
            file_info_file     = "",
            func_info_file     = "" ):
        # upload src archive, tool outputs, test suite info
        #
        # example:
        #   tools = { "tool1": ["version_str", "filename"] }
        #   languages = [1, 2, 3]
        if VERBOSE:
            print("query_project_database_submit()")
        path = "projects/%s/database" % self.project_id
        if not src_file:
            raise ValueError("src file required")
        if not os.path.exists(src_file):
            raise ValueError("src file does not exist: %s" % src_file)
        if not tools:
            raise ValueError("tools to upload required")
        project = {}
        project["is_test_suite"] = \
            self._normalize_bool_param(is_test_suite) or "false"
        project["test_suite_name"] = test_suite_name or ""
        project["test_suite_version"] = test_suite_version or ""
        project["test_suite_type"] = test_suite_type or ""
        project["test_suite_sard_id"] = test_suite_sard_id or ""
        project["manifest_url"] = manifest_url or ""
        project["author_source"] = author_source or ""
        # this is still called 'license_file' in the form, oops
        project["license_file"] = license_string or ""
        project["source_url"] = src_url or ""
        files = {}
        if src_file:
            if not os.path.exists(src_file):
                raise ValueError("src archive does not exist: %s" % src_file)
            # indicate file to curl with '@'
            files["source"] = "@%s" % src_file
        if manifest_file:
            if not os.path.exists(manifest_file):
                raise ValueError(
                    "manifest file does not exist: %s" % manifest_file)
            # indicate file to curl with '@'
            files["manifest_file"] = "@%s" % manifest_file
        if func_info_file:
            if not os.path.exists(func_info_file):
                raise ValueError(
                    "function file does not exist: %s" % func_info_file)
            # indicate file to curl with '@'
            files["function_info_file"] = "@%s" % func_info_file
        if file_info_file:
            if not os.path.exists(file_info_file):
                raise ValueError(
                    "file info file does not exist: %s" % file_info_file)
            # indicate file to curl with '@'
            files["file_info_file"] = "@%s" % file_info_file
        tool_versions = {}
        tool_names = []
        for tool_name, (f, version) in tools.items():
            tool_names.append(tool_name)
            tool_versions[tool_name] = str(version) or ""
            if not os.path.exists(f):
                raise ValueError(
                        "file does not exist for tool %s: %s" % (tool_name, f))
            # indicate file to curl with '@'
            files[tool_name] = "@%s" % f
        langs = {}
        for lang_id in languages:
            langs[str(lang_id)] = str(lang_id)
        params = self.default_params()
        params.update({
            # project_id is in the URL
            "project": project,
            "file": files,
            "tool_versions": tool_versions,
            "selectedTools": tool_names,
            "select_langs": langs,
        })
        if not primed:
            self.query_project_database_form()
        # note: project_tools, project_taxonomies in dev db not present
        # yet until query_project_from_database() is called
        return self.post(self.route(path), params)

    def query_project_from_database(self, primed=True):
        # this normally should happen after query_project_database_submit()
        if VERBOSE:
            print("query_project_from_database()")
        path = "projects/%s/database/fromdatabase" % self.project_id
        params = self.default_params()
        if not primed:
            self.query_project_database_form()
        return self.post(self.route(path), self.default_params())

    def event_project_create(self,
            name=None, description=None, project_id=None,
            primed=False, fused=None,
            src_file  = None,
            src_url   = "",
            tools     = {},
            languages = [],
            is_test_suite      = "",
            test_suite_name    = "",
            test_suite_version = "",
            test_suite_type    = "",
            test_suite_sard_id = "",
            author_source      = "",
            license_string     = "",
            manifest_url       = "",
            manifest_file      = None,
            file_info_file     = None,
            func_info_file     = None ):
        if VERBOSE:
            print("event_project_create()")
        if not name and not project_id:
            raise ValueError("no project name/description or existing project id provided")
        if not primed:
            self.query_index()
        if project_id is None:
            self.query_project_create_submit(name=name, description=description,
                    primed=True)
            project_id = self.project_id
        self.assert_project_ids_exist(project_id)
        if not src_file:
            raise ValueError("src_file required")
        if src_file and not os.path.exists(src_file):
            raise ValueError("src_file does not exist: %s" % src_file)
        if not tools:
            raise ValueError("tools to upload required")
        # upload everything, process it
        self.query_project_database_submit(primed=True,
            src_file = src_file,
            src_url = src_url,
            tools = tools,
            languages = languages,
            is_test_suite = is_test_suite,
            test_suite_name = test_suite_name,
            test_suite_version = test_suite_version,
            test_suite_type = test_suite_type,
            test_suite_sard_id = test_suite_sard_id,
            author_source = author_source,
            license_string = license_string,
            manifest_file = manifest_file,
            manifest_url = manifest_url,
            file_info_file = file_info_file,
            func_info_file = func_info_file)
        # import it all into dev db
        self.query_project_from_database(primed=True)
        # sets fused mode in session cookie -- important!
        self.query_project(fused=fused)

    def query_mass_update(self, alert_conditions, primed=False,
            scaife_mode_select = "Demo",
            verdict = -1,
            flag    = -1,
            ignored = -1,
            dead    = -1,
            ie      = -1,
            dc      = -1 ):
        if VERBOSE:
            print("query_mass_update()")
        # routes to alert_conditions#massUpdate
        path = "alertConditions/update"
        params = self.default_params()
        if flag != -1:
            flag = self._normalize_bool(flag)
        if ignored != -1:
            ignored = self._normalize_bool(ignored)
        if dead != -1:
            dead = self._normalize_bool(dead)
        if ie != -1:
            ie = self._normalize_bool(ie)
        params.update({
            # only requires project_id in fused view
            "project_id": self.project_id,
            "mass_update_verdict": verdict,
            "flag": flag,
            "ignored": ignored,
            "dead": dead,
            "inapplicable_environment": ie,
            "mass_update_dc": dc,
            "selectedAlertConditions": alert_conditions,
            # misc
            "scaife_mode_select": scaife_mode_select,
            "classifier_alert_instance": { "chosen": "" },
            "commit": "Update",
        })
        # this one works without auth token somehow...sending it anyway
        if not primed:
            self.query_project()
        return self.post(self.route(path), params)

    def query_update_display(self, display_id, primed=False,
            flag    = None,
            verdict = None,
            notes   = None,
            ignored = None,
            dead    = None,
            ie      = None,
            dc      = None ):
        # part 1 of event_update_alert_determinations()
        if VERBOSE:
            print("query_update_display()")
        path = "displays/%s" % display_id
        display_params = {}
        flag = self._normalize_bool_param(flag)
        if flag is not None:
            display_params["flag"] = flag
        if verdict is not None:
            display_params["verdict"] = verdict
        if notes is not None:
            display_params["notes"] = notes
        ignored = self._normalize_bool_param(ignored)
        if ignored is not None:
            display_params["ignored"] = ignored
        dead = self._normalize_bool_param(dead)
        if dead is not None:
            display_params["dead"] = dead
        ie = self._normalize_bool_param(ie)
        if ie is not None:
            display_params["inapplicable_environment"] = ie
        if dc is not None:
            display_params["dangerous_construct"] = dc
        params = self.default_params()
        params.update({
            # does not require project_id
            "id": display_id,
            "display": display_params,
        })
        if not primed:
            self.query_project()
        return self.put(self.route(path), params)

    def query_update_alert_condition(self, meta_alert_id, primed=False,
            flag         = None,
            verdict      = None,
            notes        = None,
            supplemental = None ):
        # part 2 of event_update_alert_determinations()
        if VERBOSE:
            print("query_update_alert_condition()")
        path = "alertConditions/update-alerts"
        for v in (flag, verdict, notes, supplemental):
            if v is not None:
                elems_to_set += 1
                break
        if elems_to_set == 0 or elems_to_set > 1:
            raise ValueError("only one element at a time can be set")
        params = self.default_params()
        params.update({
            # does not require project_id
            "row_id": display_id,
            "meta_alert_id": meta_alert_id,
        })
        if flag is not None:
            params["elem"] = "flag"
            params["value"] = flag
        elif verdict is not None:
            params["elem"] = "verdict"
            params["value"] = verdict
        elif notes is not None:
            params["elem"] = "notes"
            params["value"] = notes
        elif supplemental is not None:
            cur = self.con.cursor()
            cur.execute("""
SELECT ignored, dead, inapplicable_environment, dangerous_construct
FROM displays WHERE meta_alert_id = ?
            """.strip(), (meta_alert_id,))
            cur_ign, cur_dead, cur_ia, cur_dc = cur.fetch_one()
            ign, dead, ia, dc = supplemental
            ign = self._normalize_bool_param(ign, short=True) or cur_ign
            dead = self._normalize_bool_param(dead, short=True) or cur_dead
            ia = self._normalize_bool_param(ia, short=True) or cur_ia
            if dc is None:
                dc = cur_dc
            params["elem"] = "supplemental"
            params["value"] = [ign, dead, ia, dc]
        if not primed:
            self.query_project()
        return self.post(self.route(path), params)

    def event_update_alert_determinations(self, meta_alert_id, row_id,
            flag    = None,
            verdict = None,
            notes   = None,
            ignored = None,
            dead    = None,
            ie      = None,
            dc      = None ):
        # this is updating a single alert row, the non-mass-update way
        # it triggers two queries/actions
        if VERBOSE:
            print("event_update_alert_determinations()")
        vals_present = False
        for v in (flag, verdict, supplemental, notes,
                ignored, dead, ie, dc):
            if v is not None:
                vals_present = True
                break
        if not vals_present:
            raise ValueError("at least one value must be set")
        # auth token (doesn't seem to be required though)
        self.query_project()
        # first action
        res1 = self.query_update_display(row_id, primed=True,
            flag=flag,
            verdict=verdict,
            notes=notes,
            ignored=ignored,
            dead=dead,
            ie=ie,
            dc=dc
        )
        # second action (row_id isn't actually used in this action?
        # why is it even submitted?)
        if any(x is not None for x in (ignored, dead, ie, dc)):
            supp = [ignored, dead, ie, dc]
        else:
            supp = None
        res2 = self.query_update_alert_condition(
            meta_alert_id, row_id, primed=True,
            flag=flag,
            verdict=verdict,
            notes=notes,
            supplemental=supp
        )

    def query_langs_select_submit(self, primed=False,
            select_lang_ids=None, deselect_lang_ids=None):
        if VERBOSE:
            print("query_langs_select_submit()")
        path = "language_select_submit"
        if select_lang_ids:
            self.assert_lang_ids_exist(select_lang_ids)
        if deselect_lang_ids:
            self.assert_langs_ids_exist(deselect_lang_ids)
        if not lang_ids:
            # langs already selected
            return
        select_langs = dict(((str(x), str(x)) for x in select_lang_ids))
        deselect_langs = dict(((str(x), str(x)) for x in deselect_lang_ids))
        if not primed:
            self.query_project()
        params = self.default_params()
        params.update({
            "project_id": self.project_id,
            "select_langs":  select_langs,
            "deselect_langs":  deselect_langs,
        })
        self.post(self.route(path), params)

    def query_taxos_select_submit(self, select_taxo_ids=None,
            deselect_taxo_ids=None, primed=False):
        if VERBOSE:
            print("query_taxos_select_submit()")
        path = "taxonomy_select_submit"
        if select_taxo_ids:
            self.assert_taxo_ids_exist(select_taxo_ids)
        if deselect_taxo_ids:
            self.assert_taxo_ids_exist(deselect_taxo_ids)
        select_taxos = dict(((str(x), str(x)) for x in select_taxo_ids or []))
        deselect_taxos = \
                dict(((str(x), str(x)) for x in deselect_taxo_ids or []))
        if not primed:
            self.query_project()
        params = self.default_params()
        x = self.project_taxo_ids()
        cur = self.con.cursor()
        params["project_id"] = self.project_id
        if select_taxos:
            params["select_taxos"] = select_taxos
        if deselect_taxos:
            params["deselect_taxos"] = select_taxos
        self.post(self.route(path), params)

    ### SCAIFE integration

    def query_scaife_register_submit(self, account=None, primed=False):
        if VERBOSE:
            print("query_scaife_register_submit()")
        if account is None:
            account = default_account_scaife()
        path = "scaife-registration/register-submit"
        if not primed:
            self.query_index()
        if self.scaife_active:
            self.query_scaife_logout(primed=True)
        params = self.default_params()
        params.update({
            "firstname_field": account["first_name"],
            "lastname_field": account["last_name"],
            "org_field": "acme",
            "user_field": account["name"],
            "password_field": account["password"],
            "commit": "Register",
        })
        res = self.post(self.route(path), params)
        if re.search(r"Invalid", res, re.I):
            raise ScaifeError("account exists")
        self.scaife_registered.add(account["name"])
        self.scaife_active = True
        return res

    def query_scaife_login_submit(self, account=None, primed=False):
        if VERBOSE:
            print("query_scaife_login_submit()")
        if account is None:
            account = default_account_scaife()
        path = "scaife-registration/login-submit"
        if not primed:
            self.query_index()
        if self.scaife_active:
            self.query_scaife_logout(primed=True)
        params = self.default_params()
        params.update({
            "user_field": account["name"],
            "password_field": account["password"],
            "commit": "Log In",
        })
        res = self.post(self.route(path), params)
        if re.search(r"Invalid", res, re.I):
            raise ScaifeError("invalid login")
        self.scaife_active = True
        return res

    def query_scaife_logout(self, primed=False):
        if VERBOSE:
            print("query_scaife_logout()")
        path = "scaife-registration/logout"
        if not primed:
            self.query_index()
        res = self.post(self.route(path), self.default_params())
        self.scaife_active = False
        return res

    def event_scaife_session_establish(self, renew=False,
            account=None, primed=False):
        if VERBOSE:
            print("event_scaife_session_establish()")
        if renew or not self.scaife_active:
            if not primed:
               self.query_index()
            if account is None:
                account = default_account_scaife()
            if self.scaife_active:
                self.query_scaife_logout(primed=True)
            if account["name"] not in self.scaife_registered:
                try:
                    self.query_scaife_register_submit(
                            account=account, primed=True)
                except ScaifeError:
                    if VERBOSE:
                        print("scaife account already registered")
                    pass
            if not self.scaife_active:
                self.query_scaife_login_submit(account=account, primed=True)

    def query_scaife_langs_upload_submit(self, lang_ids, primed=False):
        # upload languages to scaife
        if VERBOSE:
           print("query_scaife_langs_upload_submit()")
        if not self.scaife_active:
            raise RuntimeError("scaife session not active")
        lang_ids = self.assert_lang_ids_exist(lang_ids)
        if not primed:
            self.query_index()
        path = "language_upload_submit"
        langs = dict(((str(x), str(x)) for x in lang_ids))
        params = self.default_params()
        params.update({
            "upload_langs": langs,
            "commit": "Upload Languages",
        })
        res = self.post(self.route(path), params)
        return res

    def query_scaife_taxos_upload_submit(self, taxo_ids, primed=False):
        # upload taxonomies to scaife
        if VERBOSE:
            print("query_scaife_taxos_upload_submit()")
        if not self.scaife_active:
            raise RuntimeError("scaife session not active")
        taxo_ids = self.assert_taxo_ids_exist(taxo_ids)
        if not primed:
            self.query_index()
        path = "taxonomy_upload_submit"
        taxos = dict(((str(x), str(x)) for x in taxo_ids))
        params = self.default_params()
        params.update({
            "upload_taxos": taxos,
            "commit": "Upload Taxonomies",
        })
        res = self.post(self.route(path), params)
        return res

    def query_scaife_tools_upload_submit(self, tool_ids, primed=False):
        if VERBOSE:
            print("query_scaife_tools_upload_submit()")
        if not self.scaife_active:
            raise RuntimeError("scaife session not active")
        tool_ids = self.assert_tool_ids_exist(tool_ids)
        if not primed:
            self.query_index()
        path = "tool_upload_submit"
        tools = dict(((str(x), str(x)) for x in tool_ids))
        params = self.default_params()
        params.update({
            "upload_tools": tools,
            "commit": "Upload Tools",
        })
        try:
            res = self.post(self.route(path), params)
        except FetchError as e:
            if e.code == 500:
                raise ScaifeError(
                    "probable language selection/upload requirement unmet")
        #if re.search(r"scaife-integration-error-msg", res):
        #    # this would happen if there was no self.project_id submitted,
        #    # i.e. from the splash page modal
        #    if re.search(r"languages", res, re.I):
        #        raise ScaifeError("language upload requirement unmet")
        #    else:
        #        raise ScaifeError("tool upload error")
        return res

    def query_scaife_project_upload(self, primed=False):
        if VERBOSE:
            print("query_scaife_project_upload()")
        if not self.scaife_active:
            raise RuntimeError("scaife session not active")
        path = "projects/%s/upload_project" % self.project_id
        if not primed:
            self.query_index()
        self.get(self.route(path))

    def query_scaife_classifier_create_form(self, classifier_type=None,
            primed=False):
        # this one doesn't return html, it extracts the scaife
        # classifier_id and returns that
        if VERBOSE:
            print("query_scaife_classifier_create_form()")
        if not self.scaife_active:
            raise RuntimeError("scaife session not active")
        path = "modals/open"
        params = {
            "className": "classifier",
            "chosen": classifier_type or "XGBoost",
            # project_id isn't actually *used* but it's required by getModals()
            "project_id": self.project_id,
        }
        # we want the params as part of the url, so use get()
        res = self.get(self.route(path), params)
        try:
            soup = BeautifulSoup(res, 'lxml')
        except TypeError:
            raise RuntimeError("problem loading classifier modal")
        scaife_id = None
        tag = soup.find(id="classifier_id")
        if tag:
            scaife_id = tag.text.strip()
        if not scaife_id:
            raise ValueError("unable to extract scaife classifier_id from page")
        return scaife_id

    def event_scaife_classifier_create(self, primed=False,
            classifier_name = None,
            classifier_type = "XGBoost",
            source_domain   = None,
            ahpo_name       = "None",
            ahpo_parameters = "",
            adaptive_heur_name = "None",
            adaptive_heur_parameters = "",
            semantic_features = 'false',
            use_pca = 'false',
            feature_category = "intersection",
            num_meta_alert_threshold = 100 ):
        if VERBOSE:
            print("query_scaife_classifier_create()")
        if not self.scaife_active:
            raise RuntimeError("scaife session not active")
        path = "modals/classifier/create"
        if not classifier_type:
            raise ValueError("classifier type required")
        if not classifier_name:
            classifier_name = self.new_classifier_name(classifier_type)
        try:
            self.assert_classifier_exists(classifier_name)
        except ValueError:
            # classifier does not exist yet
            pass
        if not primed:
            self.query_project()
        scaife_class_id = self.query_scaife_classifier_create_form(
                classifier_type, primed=True)
        if not scaife_class_id:
            raise RuntimeError("could not discover scaife classifier_id")
        if not source_domain:
            source_domain = self.project_name()
        # don't need self.default_params() for this
        if VERBOSE:
            print("creating classifier: %s" % classifier_name)
        params = {
          "project_id": self.project_id,
          "classifier_instance_name": classifier_name,
          "classifier_type": classifier_type,
          "source_domain": source_domain,
          "adaptive_heuristic_name": adaptive_heur_name,
          "adaptive_heuristic_parameters": adaptive_heur_parameters,
          "use_pca": self._normalize_bool_param(use_pca, short=True),
          "feature_category": feature_category,
          "semantic_features": self._normalize_bool_param(semantic_features, short=True),
          "ahpo_name": ahpo_name,
          "ahpo_parameters": ahpo_parameters,
          "num_meta_alert_threshold": num_meta_alert_threshold,
          "scaife_classifier_id": scaife_class_id,
        }
        res = self.post(self.route(path), params)
        return classifier_name

    def query_scaife_classifier_run(self, classifier_name, primed=False):
        if VERBOSE:
            print("query_scaife_classifier_run()")
        if not self.scaife_active:
            raise RuntimeError("scaife session not active")
        path = "alertConditions/%s/classifier/run" % self.project_id
        self.assert_classifier_exists(classifier_name)
        if not primed:
            self.query_project()
        params = {
            # project_id in url
            "classifier_scheme_name": classifier_name,
        }
        res = self.post(self.route(path), params)

        return res

    ### database utilites and assertions (development db)

    def project_lang_ids(self, project_id=None):
        if not project_id:
            project_id = self.project_id
        if not project_id:
            raise ValueError("project_id required")
        cur = self.con.cursor()
        cur.execute("""
            SELECT language_id FROM project_languages WHERE project_id = ?
        """.strip(), (project_id,))
        lang_ids = [int(x[0]) for x in cur]
        return lang_ids

    def project_taxo_ids(self, project_id=None):
        if not project_id:
            project_id = self.project_id
        if not project_id:
            raise ValueError("project_id required")
        cur = self.con.cursor()
        cur.execute("""
            SELECT taxonomy_id FROM project_taxonomies WHERE project_id = ?
        """.strip(), (project_id,))
        taxo_ids = [int(x[0]) for x in cur]
        return taxo_ids

    def project_tool_ids(self, project_id=None):
        if not project_id:
            project_id = self.project_id
        if not project_id:
            raise ValueError("project_id required")
        cur = self.con.cursor()
        cur.execute("""
            SELECT tool_id FROM project_tools WHERE project_id = ?
        """.strip(), (project_id,))
        tool_ids = [int(x[0]) for x in cur]
        return tool_ids

    def tool_lang_ids(self, tool_ids):
        try:
            tool_ids = [int(tool_ids)]
        except TypeError:
            pass
        if not tool_ids:
            raise ValueError("tool_ids required")
        plats = set()
        cur = self.con.cursor()
        for tool_id in tool_ids:
            tool = bootstrap.tool_by_id(self.db_file, tool_id)
            plats.update(tool.platforms)
        cur.execute("""
            SELECT id FROM languages WHERE platform IN (%s)
        """.strip() % ','.join(("'%s'" % x for x in plats)))
        lang_ids = sorted([int(x[0]) for x in cur])
        return lang_ids

    def project_lang_upload_ids(self, project_id=None):
        # return all lang_ids relevant to uploading a project; this
        # includes all languages associated with selected tools as well
        # as languages explicitly selected by the user that might not
        # pertain to any selected tools
        if not project_id:
            project_id = self.project_id
        if not project_id:
            raise ValueError("project_id required")
        lang_ids = set(self.project_lang_ids(project_id))
        tool_ids = self.project_tool_ids(project_id)
        if tool_ids:
            lang_ids.update(self.tool_lang_ids(tool_ids))
        else:
            print("warning: no tool_ids for project_id: %s" % project_id)
        return sorted(lang_ids)

    def assert_project_ids_exist(self, proj_ids):
        try:
            proj_ids = [int(proj_ids)]
        except TypeError:
            pass
        if not proj_ids:
            raise ValueError("no project_ids provided")
        all_proj_ids = set(self.current_project_ids())
        given_proj_ids = set([int(x) for x in proj_ids])
        diff = given_proj_ids.difference(all_proj_ids)
        if diff:
            raise ValueError(
                "invalid project IDs: %s" % ', '.join(sorted(diff)))
        return True

    def assert_lang_ids_exist(self, lang_ids):
        try:
            lang_ids = [int(lang_ids)]
        except TypeError:
            pass
        if not lang_ids:
            raise ValueError("no language IDs provided")
        cur = self.con.cursor()
        cur.execute("SELECT id FROM languages")
        all_lang_ids = set([int(r[0]) for r in cur])
        given_lang_ids = set([int(x) for x in lang_ids])
        diff = given_lang_ids.difference(all_lang_ids)
        if diff:
            raise ValueError(
                "invalid language IDs: %s" % ', '.join(sorted(diff)))
        return lang_ids

    def assert_taxo_ids_exist(self, taxo_ids):
        try:
            taxo_ids = [int(taxo_ids)]
        except TypeError:
            pass
        if not taxo_ids:
            raise ValueError("no taxonomy IDs provided")
        cur = self.con.cursor()
        cur.execute("SELECT id FROM taxonomies")
        all_taxo_ids = set([int(r[0]) for r in cur])
        given_taxo_ids = set([int(x) for x in taxo_ids])
        diff = given_taxo_ids.difference(all_taxo_ids)
        if diff:
            raise ValueError(
                "invalid taxonomy IDs: %s" % ', '.join(sorted(diff)))
        return taxo_ids

    def assert_tool_ids_exist(self, tool_ids):
        try:
            tool_ids = [int(tool_ids)]
        except TypeError:
            pass
        if not tool_ids:
            raise ValueError("no tool IDs provided")
        cur = self.con.cursor()
        cur.execute("SELECT id FROM tools")
        all_tool_ids = set([int(r[0]) for r in cur])
        given_tool_ids = set([int(x) for x in tool_ids])
        diff = given_tool_ids.difference(all_tool_ids)
        if diff:
            raise ValueError(
                "invalid tool IDs: %s" % ', '.join(sorted(diff)))
        return tool_ids

    def assert_classifier_exists(self, name):
        cur = self.con.cursor()
        cur.execute("""
            SELECT id FROM classifier_schemes
            WHERE classifier_instance_name = ?
        """.strip(), (name,))
        try:
            classifier_id = int(cur.fetchone()[0])
        except TypeError:
            raise ValueError("unknown classifier name: %s" % name)
        return True

    def new_classifier_name(self, classifier_type="XGBoost"):
        highest_cnt = -1
        cur = self.con.cursor()
        cur.execute("SELECT classifier_instance_name FROM classifier_schemes")
        pfx = "automation:"
        #classifier_type = re.sub(r"\s+", "_", classifier_type)
        for name in (x[0] for x in cur.fetchall()):
            #if not name.startswith("%s_%s" % (pfx, classifier_type)):
            if not name.startswith("%s %s" % (pfx, classifier_type)):
                continue
            m = re.search(r"(\d+)$", name)
            if m:
                cnt = int(m.group(1))
                if cnt > highest_cnt:
                    highest_cnt = cnt
        return "%s %s %d" % (pfx, classifier_type, highest_cnt + 1)

class FetchError(Exception):
    # this class is overloaded to handle both:
    #   1. HTTP exceptions, sometimes with an embedded SCAIFE exception
    #      in the message
    #   2. curl subprocess non-zero exit code conditions

    @property
    def code(self):
        if self._has_inner_status():
            # probably a SCAIFE exception
            return int(self.raw["status"])
        else:
            return self.message[0]

    @property
    def status(self):
        if self._has_inner_status():
            # probably a SCAIFE exception
            return self.raw["message"]
        else:
            return self.message[1]

    @property
    def method(self):
        return self.message[2] or 'default'

    @property
    def url(self):
        return self.message[3]

    @property
    def raw(self):
        try:
            return self.message[4] or ""
        except IndexError:
            return None

    @property
    def soup(self):
        return BeautifulSoup(self.raw or "", 'lxml')

    @property
    def text(self):
        return self.soup.text

    def _has_inner_status(self):
        # might be a scaife query error returned as json
        try:
            int(self.raw["status"])
            self.raw["message"]
            return True
        except (IndexError, TypeError):
            return False

    def __str__(self):
        if self.raw is None and "curl:" in self.status:
            # curl subprocess error
            return "exit(%d): %s" % (self.code, self.status)
            return self.status
        else:
            # unexpected HTTP response code
            label = "http"
            if self._has_inner_status():
                label += " (inner)"
            return "%s: %d %s - %s %s" % \
                    (label, self.code, self.status, self.method, self.url)

    def __repr__(self):
        return (self.code, self.status)

class ScaifeError(Exception):
    pass

###

def curl_engine(url, params=None, files=None, cookie_file=None,
        user=None, passwd=None, referrer=None, method=None, as_json=False,
        accept_json=False, follow_redirects=True, use_ssl=True,
        accept_additional_codes=None):
    header_file = bootstrap.get_tmp_file(
            basename="auto.headers.txt", ephemeral=EPHEMERAL_TMP)
    output_file = bootstrap.get_tmp_file(
        basename="auto.response.body.%s" % ("json" if as_json else "html"),
        ephemeral=EPHEMERAL_TMP)
    cmd = ["curl"]
    # silent, but show errors
    cmd += ["-s", "--show-error"]
    # follow redirects (pretty common in rails) in case the later pages
    # end up setting values in the session cookie
    if follow_redirects:
        cmd.append("-L")
    if use_ssl:
        # self-signed certificate ignore; note that it's up to the
        # caller to have properly formatted the URL to use https
        cmd.append("--insecure")
    cmd += ["--dump-header", header_file]
    cmd += ["--output", output_file]
    if as_json:
        cmd += ["-H", "Content-type: application/json"]
    if accept_json:
        cmd += ["-H", "Accept: application/json"]
    cmd += ["--compressed"]
    if referrer:
        cmd += ["-e", referrer]
    if method:
        # GET, POST, PUT, CREATE, DELETE, etc
        cmd += ["-X", method]
    if cookie_file:
        if os.path.exists(cookie_file):
            # load cookies from
            cmd += ["--cookie", cookie_file]
        # save updated cookies to
        cmd += ["--cookie-jar", cookie_file]
    if user and passwd:
        cmd += ["--user", "%s:%s" % (user, passwd)]
    elif bool(user) != bool(passwd):
        raise ValueError("only one of user/password was provided")
    if params:
        # if files are being uploaded, it's form fields or bust, no json
        # shortcut
        if as_json and not files:
            cmd += ["-d", json.dumps(params)]
        else:
            for f in to_curl_form_fields(params):
                cmd += ["-F", f]
    if files:
        for f in to_curl_form_fields(files, as_files=True):
            cmd += ["-F", f]
    # and finally...
    cmd.append(url)
    if VERBOSE > 1:
        cmd_str = []
        for x in cmd:
            if not x.startswith('-') and x != "curl":
                x = "'%s'" % x
            cmd_str.append(x)
        print("\n%s\n" % ' '.join(cmd_str))
    try:
        stuff = subprocess.check_output(cmd, stderr=subprocess.STDOUT)
    except CalledProcessError as e:
        output = re.sub(r"curl:\s+\(\d+\)\s+", "curl: ", e.output.strip())
        raise FetchError((e.returncode, output, method, url))
    res = open(output_file).read()
    hline = open(header_file).next().strip()
    m = re.search(r"HTTP/\d\.\d\s+(\d+)\s+(.*)$", hline)
    if m:
        code, status = int(m.group(1)), m.group(2)
    for hline in (x.strip() for x in open(header_file)):
        m = re.search(r"^Content-Type:\s+application/([^;]+)", hline)
        if m and m.group(1) == "json":
            res = json.loads(res)
    # 302 redirects are ok, although the -L option to curl should have
    # piled through them
    if code not in (200, 302) and code not in (accept_additional_codes or []):
        raise FetchError((code, status, method, url, res))
    return res

# future engines, for example a pure python version, should accept the
# same parameters as implemented above for the curl engine. Once
# implemented, it should be registered as an available engine. Engines
# should have 1:1 functional parity with each other:

ScaleSession.register_engine('curl', curl_engine)

def to_curl_form_fields(params, as_files=False):
    # for use with -F in curl
    for k, v in to_curl_form_pairs(params, as_files=as_files):
        yield "%s=%s" % (k, v)

def to_curl_form_pairs(params, name="", as_files=False):
    # for eventual use with -F in curl; this will encode deep data
    # structures, I have no idea if they get unpacked correctly as form
    # parameters on the server if they go more than one level deep, e.g
    # something awful like "item[hash_key_b][0][hash_key_z][5]"
    if isinstance(params, dict):
        for k, v in params.items():
            if name:
                k = "%s[%s]" % (name, k)
            for k2, v2 in to_curl_form_pairs(v, name=k, as_files=as_files):
                yield k2, v2
    elif isinstance(params, list):
        k = "%s[]" % name
        for v in params:
            for k2, v2 in to_curl_form_pairs(v, name=k, as_files=as_files):
                yield k2, v2
    else:
        params = str(params)
        if as_files:
            # this is a very curl thing to do
            if params[0] != '@':
                params = '@' + params
        yield name, params

def default_user_pass():
    # yes, this is gross; in the future the user/pass for SCALe needs to
    # be placed in a config file, perhaps YAML, so that they can be
    # portably shared across frameworks and languages, including rails
    cfiles = glob(os.path.join(bootstrap.base_dir, "app/controllers/*.rb"))
    cfiles = glob(os.path.join(bootstrap.base_dir, "app/controllers/*.rb"))
    cmd = ["grep", "http_basic_authenticate_with"] + cfiles
    res = subprocess.check_output(cmd)
    name = passwd = None
    m = re.search(r":name\s+=>\s+['\"]([^'\"]+)", res)
    if m:
        name = m.group(1)
    m = re.search(r":password\s+=>\s+['\"]([^'\"]+)", res)
    if m:
        passwd = m.group(1)
    if not (name and passwd):
        raise ValueError("could not extract name/pass from app")
    return name, passwd

scaife_account = None

def default_account_scaife(config_file=None):
    # piggyback on the SCAIFE-style configuration file here
    global scaife_account
    if not scaife_account:
        config = bootstrap.scaife_config_all(config_file)
        try:
            config_account = config["test"]["automation"]["account"]
        except KeyError:
            raise RuntimeError(
                "config test:automation:account "
                "block not found: %s" % config_file)
        scaife_account = {}
        for f in ('name', 'password', 'first_name', 'last_name'):
            scaife_account[f] = config_account[f]
    return scaife_account
