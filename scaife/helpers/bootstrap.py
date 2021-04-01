# This module is a grab bag of utility settings, functions, and objects
# that are generally useful for most of the scripts in this directory.
#
# Note: The master copy of this module is scaife/helpers/bootstrap.py
#       If updates are made to it, the copies in the various
#       *_stub/swagger_server directories should also be updated.
#       Eventually it would be nice to have a separate repository shared
#       across all modules for common functionality such as this.

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

import os, sys, re, time
import argparse, requests
from urllib import parse as urlparse
from pathlib import Path
from configparser import ConfigParser
from requests.exceptions import ConnectionError

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
    def __bool__(self):
        return bool(self.value)
    def __lt__(self, other):
        return self.value < other
    def __gt__(self, other):
            return self.value > other
    def __le__(self, other):
        return self.value <= other
    def __ge__(self, other):
        return self.value >= other
    def __eq__(self, other):
        return self.value == other
    def __ne__(self, other):
        return self.value != other
    def __pos__(self):
        return self.value
    def __neg__(self):
        return -self.value
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

# we are either in scaife/helpers or in *_server_stub/swagger_server
# base_dir is the scaife repo dir unless in a container; this module
# lives in both scaife/helpers as well as in each
# *_server_stub/swagger_server
basename = __file__
if basename.endswith(".pyc"):
    basename = basename[:-1]
bootstrap_dir = Path(basename).resolve().parent
is_container = is_module = False
if bootstrap_dir.name == "swagger_server":
    # we're in a module; base_dir doesn't mean much if we're in a container
    base_dir = bootstrap_dir.parent.parent
    is_module = True
else:
    # we are scaife/helpers/bootstrap.py, base_dir is scaife repo dir
    base_dir = bootstrap_dir.parent
    is_module = False
if not base_dir.joinpath("helpers/%s" % basename).exists():
    # helpers/bootstrap.py isn't around, we're probably a container
    is_container = True

tmp_dir = base_dir.joinpath("tmp")
if not tmp_dir.is_dir():
    os.makedirs(tmp_dir)

class ServiceTimeout(Exception):
    pass

default_svc_timeout = 30

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
            raise ValueError("service name or host name required, "
                    "either directly or via url")
        self._name = name
        if not host and name:
            host = name
        if url:
            u = urlparse.urlparse(url)
            if u.hostname and host is None:
                host = u.hostname
        if not host:
            raise ValueError("service name or host name or url required")
        if port is None:
            if ':' in host:
                # this might only happen if no url was provided
                m = re.search(r"^([^:]+):(\d+)", host)
                host, port = m.group(1), int(m.group(2))
        if url:
            u = urlparse.urlparse(url)
            if u.port is not None and port is None:
                port = u.port
            if port is None:
                if u.scheme == "http":
                    port = 80
                elif u.scheme == "https":
                    port = 443
        if port is None:
            raise ValueError("port must be provided directly or via url")
        self.expected_response = expected_response
        self.check_json = check_json
        self.host, self.port = host, int(port)
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

    def __str__(self):
        return "%s:%s" % (self.host, self.port)

    # the Service object will evaluate to True/False depending on status
    __bool__ = cached_status


def load_services_from_config(module_name, filename,
        localhost=False, label=None):
    if label is None:
        label = module_name
    conf = ConfigParser()
    conf.read(filename)
    services = {module_name: {}}
    for k, v in conf.items("DEFAULT"):
        services[module_name][k] = v
    for section in conf.sections():
        svc = re.sub(r"_DEFAULT", "", section).lower()
        if svc == "dh":
            svc = "datahub"
        services[svc] = {}
        for k, v in conf.items(section):
            services[svc][k] = v
    for svc in services.keys():
        conf = services[svc]
        host = "localhost" if localhost else conf.get("host", "localhost")
        port = int(conf.get("port"))
        url = expected = None
        if svc == "pulsar":
            # need a better way to handle fancy services than making
            # exceptions here by name
            test_port = 8080
            url = "http://%s:%s/admin/v2/worker/cluster" % (host, test_port)
            def _expected(data):
                data = data[0]
                keys = ("workerId", "workerHostname", "port")
                return all(x in data for x in keys)
            expected = _expected
        services[svc] = Service(name=svc,
                host=host, port=port,
                url=url, expected_response=expected, label=label)

    return services


class ScaifeModuleError(Exception):
    pass

class ScaifeModule(object):

    _service = None
    _services = {}

    def __init__(self, name=None, stub_dir=None, localhost=False, loud=None):
        if name is None:
            name = "default"
        self.name = name
        self.localhost = localhost
        if stub_dir:
            # override stub dir
            stub_dir = Path(stub_dir)
            if stub_dir.is_absolute():
                self.stub_dir = stub_dir
            else:
                self.stub_dir = base_dir.joinpath(stub_dir)
            if not self.stub_dir.exists():
                raise ValueError("stub dir does not exist: %s" % self.stub_dir)
        else:
            stub_dir = base_dir.joinpath("%s_server_stub" % name)
            if stub_dir.exists():
                self.stub_dir = stub_dir
            else:
                self.stub_dir = bootstrap_dir.parent
        if not self.stub_dir.exists():
            raise ScaifeModuleError(
                "stub dir does not exist: %s" % self.stub_dir)
        if name == "scale":
            self.app_dir = self.stub_dir.joinpath("scale.app")
        else:
            self.app_dir = self.stub_dir
        self.loud = (VERBOSE > 1) if loud is None else loud
        self.server_dir = self.stub_dir.joinpath("swagger_server")
        self.config_file = self.server_dir.joinpath("servers.conf")

    def _load_services(self):
        if os.path.exists(self.config_file):
            self._services = \
                load_services_from_config(self.name, self.config_file,
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
    if str(bootstrap_dir.parent).endswith("_server_stub"):
        name = bootstrap_dir.parent.name.split("_")[-3]
    else:
        name = "default"
    return ScaifeModule(name, localhost=localhost)

def modules_present_by_name(localhost=False):
    modules = {}
    for p in sorted(base_dir.glob("*_server_stub")):
        if p.is_dir():
            name = re.sub(r"_server_stub$", "", p.stem)
            if name == "ui":
                # non-ui modules don't care about ui -- let ui
                # handle itself
                continue
            modules[name] = ScaifeModule(name=name, localhost=localhost)
    if not modules:
        # we are in a container probably
        modules["default"] = ScaifeModule(name="default", localhost=localhost)
    return modules

def modules_present(localhost=False):
    return list(modules_present_by_name(localhost=localhost).values())

def _filter_modules(include=None, exclude=None, localhost=False):
    mods_present = modules_present_by_name(localhost=localhost)
    if not include:
        include = mods_present
    include = set(include)
    inc_unknown = include.difference(mods_present)
    if inc_unknown:
        raise ValueError("cannot include unknown modules: %s"
            % ', '.join(sorted(inc_unknown)))
    if exclude:
        exc_unknown = set(exclude).difference(mods_present)
        if exc_unknown:
            raise ValueError("cannot exclude unknown modules: %s"
                % ', '.join(sorted(exc_unknown)))
        include.difference_update(exclude)
    if not include:
        raise ValueError("no modules selected from: %s"
            % ', '.join(mods_present))
    return (mods_present[x] for x in sorted(include))

def assert_modules_are_up(include=None, exclude=None, localhost=False):
    modules = _filter_modules(include=include, exclude=exclude,
            localhost=localhost)
    modules_up = []
    modules_down = []
    for module in modules:
        if module:
            modules_up.append(module)
        else:
            modules_down.append(module)
    message = "modules not up: %s" \
            % ', '.join(module.name for module in modules_down)
    assert not modules_down, message
    return modules_up

def wait_for_modules(timeout=None, include=None, exclude=None,
        include_services=False, localhost=False, loud=False):
    # wait for modules, possibly also for their secondary services
    modules = _filter_modules(include=include, exclude=exclude,
            localhost=localhost)
    for mod in modules:
        mod.wait_until_up(timeout=timeout, include_services=include_services,
                loud=loud)

def wait_for_module_services(timeout=None, include=None, exclude=None,
        localhost=False, loud=False):
    # wait for secondary services for moduels, but not the modules themselves
    all_known = set()
    mods_present = modules_present(localhost=localhost)
    for module in mods_present:
        for svc in module.services_by_name:
            all_known.add(svc)
            all_known.add("%s/%s" % (module.name, svc))
    unknown = set()
    includes = {}
    if include:
        for svc in include:
            if svc not in all_known:
                unknown.add(svc)
                continue
            try:
                module_name, svc = svc.split("/", 1)
            except ValueError:
                module_name = None
            if module_name:
                if module_name not in includes:
                    includes[module_name] = set()
                includes[module_name].add(svc)
            else:
                # all modules that have this particular service
                for module in mods_present:
                    if svc in module.services_by_name:
                        if module.name not in includes:
                            includes[module.name] = set()
                        includes[module.name].add(svc)
    if not includes:
        for module in mods_present:
            includes[module.name] = set(module.services_by_name)
    excludes = {}
    if exclude:
        for svc in exclude:
            if svc not in all_known:
                unknown.add(svc)
                continue
            try:
                module, svc = svc.split("/", 1)
            except ValueError:
                module = None
            if module:
                if module.name not in excludes:
                    excludes[module.name] = set()
                excludes[module.name].add(svc)
            else:
                # all modules that have this particular service
                for module in mods_present:
                    if svc in module.services_by_name:
                        if module.name not in excludes:
                            excludes[module.name] = set()
                        excludes[module.name].add(svc)
    if unknown:
        raise ValueError("unknown services: %s" % ', '.join(sorted(unknown)))
    if not includes and not excludes:
        for module in mods_present:
            module.wait_for_services(timeout=timeout, loud=loud)
    else:
        for module in mods_present:
            if module.name in includes or module.name in excludes:
                module.wait_for_services(timeout=timeout,
                    include=includes.get(module.name),
                    exclude=excludes.get(module.name), loud=loud)

def _load_module(name, localhost=False):
    try:
        return ScaifeModule(name, localhost=localhost)
    except ScaifeModuleError:
        print("scaife module not found: %s" % name, file=sys.stderr)
    return None

def default_module(localhost=False):
    return _load_module("default")

def datahub_module(localhost=False):
    return _load_module("datahub")

def stats_module(localhost=False):
    return _load_module("stats")

def priority_module(localhost=False):
    return _load_module("priority")

def registration_module(localhost=False):
    return _load_module("registration")

def ui_module(localhost=False):
    return _load_module("ui")
