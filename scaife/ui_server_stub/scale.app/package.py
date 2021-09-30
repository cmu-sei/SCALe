#!/usr/bin/env python

# In general, this script should be used to make any changes to the
# filesystem that do NOT go into git.  This script should be run using
# python version 2.  Mostly, this script makes changes required for
# releasing code (substitutes copyright text for legal placeholder
# markings, adjusts the initial copyright text for particular files
# like SCAIFE manual HTML pages, removes proprietary files that should
# not be released, adds a PDF download of the CWEs used by SCALe,
# builds the SCAIFE/SCALe HTML manual from the markdown files, and
# creates one or more tarballs of release code).  In one way, the
# script should be used to *identify* changes that need to be made to
# the filesystem that SHOULD go into git. The script can be used to
# identify files that do not have legal markings but should have them.

# See the following example command run, for full SCAIFE tarball build
# for an online deployment. Note you would need to substitute your own
# filepath to the scaife directory.

# Example command, run from the scaife directory:
# python ui_server_stub/scale.app/package.py --target=scaife-online --top-dir=/home/lflynn/temp/code-release-for-containers/scaife

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


import fnmatch
import json
import io
import os
import re
import subprocess
import sys
import tarfile
import urllib


# for other versions see: https://cwe.mitre.org/data/archive.html
CWE_PDF_SRC = "https://cwe.mitre.org/data/published/cwe_v2.11.pdf"
CWE_PDF_DST = './public/doc/CWE.pdf'

SCAIFE_SCALE_PATH = "ui_server_stub/scale.app"

TAR_CONFIGS = {
    "offline":
        {
            "name": "Offline Tarball",
            "format": "scale.offline.%s.tar.gz",
        },
    "online":
        {
            "name": "Online Tarball",
            "format": "scale.online.%s.tar.gz",
        },
    "scaife-offline":
        {
            "name": "Offline Tarball",
            "format": "scaife.offline.%s.tar.gz",
        },
    "scaife-online":
        {
            "name": "Online Tarball",
            "format": "scaife.online.%s.tar.gz",
        },
    "scaife-scale-online":
        {
            "name": "SCALe-only online Tarball",
            "format": "scaife-scale.%s.tar.gz",
        }
}
# Functions may add to this list of files before it gets consulted
# when creating the tarball
IGNORED_FILES = [
     "db/*.sqlite3",
    ".DS_Store",
    ".git/*",
    ".vagrant/*",
    "Gemfile.lock"
    "TAGS",
    "archive/*",
    "cert/*",
    "db/back/*",
    "db/backup/*",
    "log/*",
    "packages/*",
    "scale.*.tar.gz",
    "scripts/*.pyc",
    "test-output/*",
    "test/junit/test/src/test/java/test_config.json",
    "tmp/*",
    "vendor/bundle/*",
]
SCAIFE_IGNORED_FILES = [
    ".DS_Store",
    ".git/*",
    ".vagrant/*",
    "packages/*",
    "tmp/*",
]
IGNORED_SCAIFE_SCALE_FILES = [
    "public/doc/android/*",
    "public/doc/c/*",
    "public/doc/cplusplus/*",
    "public/doc/java/*",
    "public/doc/perl/*",
]
SCAIFE_IGNORED_SCAIFE_SCALE_FILES = [
    "datahub_server_stub/*",
    "priority_server_stub/*",
    "registration_server_stub/*",
    "stats_server_stub/*",
    "scaife.copyright.html",
]
PROPRIETARY_CODE_DIRS = [
    "demo/dos2unix/analysis",
    "scripts/data",
    "scripts/data/properties/cert_rules",
    "scripts/data/properties/cwes",
    "scripts/data/properties/regex",
    "scripts/deprecated",
    "scripts/deprecated/deprecated_tests",
    "test/junit/test/scale_input/dos2unix/analysis",
    "test/junit/test/scale_input/misc/proprietary",
    "test/junit/test/scale_input/src100/analysis",
    "test/python/data/digestalerts/analysis/",
    "test/python/data/good",
    "test/python/data/input",
]
SCAIFE_PROPRIETARY_CODE_DIRS = [
    "datahub_server_stub/swagger_server/rapidclass_scripts/statswork",
    "stats_server_stub/swagger_server/rapidclass_scripts/archived",
    "stats_server_stub/swagger_server/rapidclass_scripts/statswork",
]
PROPRIETARY_IGNORABLE_FILES = [
    "scripts/deprecated/deprecated_tests/fortify_input.py",
    "scripts/deprecated/deprecated_tests/coverity_input.py",
]
SCAIFE_SCALE_FILES_TO_CLOBBER = [
    "datahub_server_stub/.gitignore",
    "priority_server_stub/.gitignore",
    "registration_server_stub/.gitignore",
    "stats_server_stub/.gitignore"
]

COPYRIGHT_DENYLIST = [
    ".git",
    ".gitmodules",
    ".pytest_cache",
    ".vagrant",
    "archive",
    "demo",
    "log",
    "packages",
    "public",
    "test-input",
    "test-output",
    "test/junit/test/scale_input",
    "test/python/data",
    "tmp/cache",
    "vendor",
]
ADDITIONAL_COPYRIGHT_DENYLIST = [
    ".git",
    ".gitmodules",
    ".vagrant",
    "datahub_server_stub/swagger_server/test/test_output",
    "datahub_server_stub/swagger_server/uploaded_files",
    "ui_server_stub/swagger_server/test/data/packages",
    "ui_server_stub/.pytest_cache",
    "datahub_server_stub/scripts/api",
    "datahub_server_stub/.tox",
    "priority_server_stub/.tox",
    "registration_server_stub/.tox",
    "stats_server_stub/.tox",
    "ui_server_stub/.tox",
]
COPYRIGHT_FILENAME_MAP = {
    ".dockerignore": r'# \1',
    ".gitignore": r'# \1',
    "Dockerfile": r'# \1',
    "Gemfile": r'# \1',
    "README": r'\1',
    "Vagrantfile": r'# \1',

    ".gitkeep": None,
}
COPYRIGHT_EXTENSION_MAP = {
    ".properties": r'# \1',
    ".py": r'# \1',
    ".rb": r'# \1',
    ".service": r'# \1',
    ".sh": r'# \1',
    ".yaml": r'# \1',
    ".yml": r'# \1',

    ".java": r'// \1',
    ".js":   r'// \1',

    ".md":  r'<!-- \1 -->',

    ".sql": r'-- \1',

    # for HTML footer
    ".template": r'<p>\1',

    # For SCAIFE
    ".R":     r'# \1',
    ".Rmd":   r'<!-- \1 -->',
    ".cpp":   r'// \1',
    ".c":     r'// \1',
    ".h":     r'// \1',

    # These file extensions can be ignored
    ".class": None,
    ".conf": None,
    ".css": None,
    ".csv": None,
    ".tsv": None,
    ".docx": None,
    ".erb": None,
    ".gif": None,
    ".gz": None,
    ".html": None,
    ".ini": None,
    ".jpg": None,
    ".json": None,
    ".lua": None,
    ".org": None,
    ".pdf": None,
    ".png": None,
    ".pptx": None,
    ".prefs": None,
    ".pyc": None,
    ".tags": None,
    ".txt": None,
    ".xlsx": None,
    ".xml": None,
    ".xsl": None,
    ".zip": None,
}
WARNINGS = False


# To be precise, this function returns true if package.py was invoked
# from the 'scaife' dir. Which is to be done for both scaife releases
# and the Github scaife-scale release. It is only false for a
# scale-only release.
def is_scaife():
    return os.path.exists(SCAIFE_SCALE_PATH)


def gets_scaife_copyright(cfg, path):
    return ("scaife-scale-online" not in cfg['target'] and
            is_scaife() and
            (not path.startswith("./ui_server_stub")))

def gets_manual_copyright(cfg, path):
    return (os.path.basename(path).startswith("SCAIFE") and
            path.endswith(".md"))


def console_status(name, width=80):
    '''
        A decorator that simplifies and standardizes console status reporting.

        Output will be printed in the form:
            {name}      [{status}]
        where {name} is left aligned,
        and {status} is right aligned using `width`.

        The status will be the string returned from the decorated function.
    '''
    def _decorate(f):
        def _status(cfg):
            sys.stdout.write(name)
            sys.stdout.flush()

            status = str(f(cfg))

            for _ in xrange(width-len(name)-len(status)-2):
                sys.stdout.write(' ')
            sys.stdout.write('[')
            sys.stdout.write(status)
            sys.stdout.write(']')
            sys.stdout.write('\n')
            sys.stdout.flush()
        return _status
    return _decorate


def read_configuration(cfg_filename):
    '''
        Reads the ABOUT file, parses it as json, and returns the parsed object.
    '''
    with open(cfg_filename) as f:
        return json.load(f)


@console_status('Update copyright info')
def update_copyright(cfg):
    '''
        Updating copyright info in each file that contains it
    '''

    global WARNINGS
    # Update README for scaife-scale-online distro (b/f other copyrights)
    if "scaife-scale-online" in cfg['target']:
        with io.open("./README.md", 'r+', encoding="utf-8") as fp:
            contents = fp.read()
            match = re.search(r'</legal>', contents)
            if WARNINGS and not match:
                print("WARNING: No legal tag for README")
            else:
                with io.open("helpers/gitHubReleaseReadme.md") as extra_readme:
                    new_contents = (contents[:match.start(0)] + "</legal>\n" +
                                    extra_readme.read() +
                                    contents[match.end(0):])
                    fp.seek(0)
                    fp.write(new_contents)

    scaife_flag = is_scaife()
    if scaife_flag:
        new_legal_scale = "<legal>"+"\n".join(cfg['legal-scale'])+"</legal>"
        new_legal_scaife = "<legal>" + "\n".join(cfg['legal']) + "</legal>"
    else:
        new_legal_scale = "<legal>" + "\n".join(cfg['legal']) + "</legal>"
        new_legal_scaife = ""
    new_legal_manual = "<legal>" + "\n".join(cfg['legal-manual']) + "</legal>" if scaife_flag else "<legal></legal>"

    for dirpath, _, files in os.walk('.'):
        if any([dirpath.startswith(x) for x in COPYRIGHT_DENYLIST]):
            continue

        for filename in files:
            full_path = os.path.join(dirpath, filename)
            ext = os.path.splitext(full_path)[-1]
            regex = None
            if dirpath.endswith("/bin"):
                regex = COPYRIGHT_EXTENSION_MAP[".sh"]
            elif ext in COPYRIGHT_EXTENSION_MAP:
                regex = COPYRIGHT_EXTENSION_MAP[ext]
            elif filename in COPYRIGHT_FILENAME_MAP:
                regex = COPYRIGHT_FILENAME_MAP[filename]
            else:
                if WARNINGS:
                    print("WARNING: Not checking copyright in " + full_path)

            if not regex:
                continue

            prot_new_legal_scale = re.sub(r'(?m)(.*)', regex,
                                          new_legal_scale)
            prot_new_legal_manual = re.sub(r'(?m)(.*)', regex,
                                           new_legal_manual)
            prot_new_legal_scaife = re.sub(r'(?m)(.*)', regex,
                                           new_legal_scaife)

            with io.open(full_path, 'r+', encoding="utf-8") as fp:
                contents = fp.read()
                match = re.search(r'(?im)^.*?<legal>(.|\n)*?</legal>.*?$',
                                  contents)
                if not match:
                    if WARNINGS:
                        print("WARNING: No copyright for " + full_path)
                    continue
                if not WARNINGS:
                    legal = (prot_new_legal_manual
                             if gets_manual_copyright(cfg, full_path)
                             else prot_new_legal_scaife
                             if gets_scaife_copyright(cfg, full_path)
                             else prot_new_legal_scale)
                    new_contents = (contents[:match.start(0)] +
                                    legal +
                                    contents[match.end(0):])
                    fp.seek(0)
                    fp.write(new_contents)

    return 'DONE'


@console_status('Adjust version numbers')
def adjust_version_numbers(cfg):
    '''
        Replacing version numbers with the version from the ABOUT files.
    '''
    scale_files = ['COPYRIGHT', "doc/SCALe-copyright.md"]
    if is_scaife():
        scale_files = [SCAIFE_SCALE_PATH + "/" + x for x in scale_files]
        file_substitute(scale_files, '{{SCALE_VERSION}}', cfg['scale_version'])

        scaife_files = ["scaife.copyright.html",
                        SCAIFE_SCALE_PATH + "/doc/SCAIFE-SYSTEM-copyright.md"]
        file_substitute(scaife_files, '{{SCAIFE_VERSION}}', cfg['version'])
    else:
        file_substitute(scale_files, '{{SCALE_VERSION}}', cfg['version'])

    return 'DONE'


def file_substitute(files, old, new):
    '''
        Substitute new for old in list of files
    '''
    global WARNINGS
    if WARNINGS:
        return
    for filename in files:
        print("Changing " + filename)
        with io.open(filename, 'r', encoding="utf-8") as input_f:
            new_str = input_f.read().replace(old, new)
        with io.open(filename, 'w', encoding="utf-8") as output_f:
            output_f.write(new_str)


@console_status('Fetching SCALe manual')
def fetch_manual(cfg):
    scaife_flag = is_scaife()
    prefix = SCAIFE_SCALE_PATH+'/' if scaife_flag else "./"

    os.chdir(prefix+"scripts")
    # !!!
    proc = subprocess.Popen(['bash', 'builddocs.sh'],
                            stdout=sys.stdout,
                            stderr=sys.stderr)
    proc.wait()
    os.chdir("..")
    return 'DONE'


@console_status('Fetching CERT Coding Guidelines')
def fetch_cert_coding_guidelines(cfg):
    return 'NYI'


@console_status('Create vendor bundle')
def fetch_vendor_bundle(cfg):
    '''
        Uses `bundle` to pull down neccessary dependencies.
    '''
    proc = subprocess.Popen(['bundle', 'package',
                             '--path', 'vendor/bundle',
                             '--no-install'],
                            stdout=sys.stdout,
                            stderr=sys.stderr)
    proc.wait()
    return 'DONE'


@console_status('Fetch CWE.pdf')
def fetch_cwe_pdf(cfg):
    if is_scaife():
        cwe_pdf_dst = SCAIFE_SCALE_PATH + os.path.sep + CWE_PDF_DST
    else:
        cwe_pdf_dst = CWE_PDF_DST
    if not os.path.exists(cwe_pdf_dst):
        urllib.urlretrieve(CWE_PDF_SRC, cwe_pdf_dst)
        return 'DONE'
    else:
        return 'SKIP'


def ignore_proprietary_code(keep_list, targets):
    suffixes = {".json", ".xml", ".fvdl", ".csv", ".tsv",
                ".properties", ".sqlite", ".sqlite3", ".sql", ".org", ".txt",
                ".rpf", ".rps"}
    for dir in PROPRIETARY_CODE_DIRS:
        if os.path.exists(dir):
            for filename in os.listdir(dir):
                if os.path.isfile(os.path.join(dir, filename)) and \
                   os.path.splitext(filename)[1] in suffixes and \
                   "_oss" not in filename and \
                   len(filter(lambda keep: keep in filename, keep_list)) == 0:
                    for tarcfg in (TAR_CONFIGS[k] for k in targets):
                        IGNORED_FILES.append(os.path.join(dir, filename))
        else:
            print("WARNING: expected PROPRIETARY_CODE_DIRS directory ", dir, " does not exist.")

    for file in PROPRIETARY_IGNORABLE_FILES:
        if len(filter(lambda keep: keep in file, keep_list)) == 0:
            for tarcfg in (TAR_CONFIGS[k] for k in targets):
                IGNORED_FILES.append(file)


def _remove_user_info(tarinfo):
    tarinfo.uid = tarinfo.gid = 0
    tarinfo.uname = tarinfo.gname = "root"
    return tarinfo

def _walk_with_dir_links(rootpath):
    def _dir_links(dpath):
        dir_links = []
        for entry in os.listdir(dpath):
            fullpath = os.path.join(dpath, entry)
            if os.path.islink(fullpath) and os.path.isdir(fullpath):
                dir_links.append(entry)
        return dir_links
    for dirpath, _, files in os.walk(rootpath):
        yield dirpath, files + _dir_links(dirpath)

def create_tar_package(cfg, outputdir, tarcfg):
    prefix = "scaife" if is_scaife() else "scale.app"

    tarfile_path = os.path.join(outputdir, tarcfg['format'] % cfg['version'])
    with tarfile.open(tarfile_path, mode='w|gz') as tar:
        current_dir = None
        for dirpath, files in _walk_with_dir_links('.'):
            for file in files:
                full_path = os.path.join(dirpath, file)
                if not any((fnmatch.fnmatch(full_path, x)
                            for x in IGNORED_FILES)):
                    if dirpath != current_dir:
                        current_dir = dirpath
                        print("    %s/ ..." % current_dir)
                    tar.add(full_path, arcname=prefix+"/"+full_path,
                            filter=_remove_user_info)

        if "scaife-scale-online" in cfg['target']:
            tar.add("./README.md", arcname="./README.md")
            tar.add("./ABOUT", arcname="./ABOUT")

            for filepath in SCAIFE_SCALE_FILES_TO_CLOBBER:
                tar.add(filepath, arcname=prefix+"/"+filepath,
                        filter=_remove_user_info)


def adjust_scale_scaife_files(scale_files, scaife_files):
    scaife_flag = is_scaife()
    prefix = "./" + SCAIFE_SCALE_PATH+'/' if scaife_flag else "./"
    files = [prefix + f for f in scale_files]
    if scaife_flag:
        files += ["./" + f for f in scaife_files]
    return files


def parse_args():
    import argparse
    p = argparse.ArgumentParser(description='''
Packaging script for SCAIFE and alternatively for SCALe alone. This
script should be run using python version 2. It uses the Ruby 'bundle'
command, which should be installed and version >=2.1.4. In general,
this script should be used to make any changes to the filesystem that
do NOT go into git. Mostly, this script makes changes required for
releasing code (substitutes copyright text for legal placeholder
markings, adjusts the initial copyright text for particular files like
SCAIFE manual HTML pages, removes proprietary files that should not be
released, adds a PDF download of the CWEs used by SCALe, builds the
SCAIFE/SCALe HTML manual from the markdown files, and creates one or
more tarballs of release code). In one way, the script should be used
to *identify* changes that need to be made to the filesystem that
SHOULD go into git. The script can be used to identify files that do
not have legal markings but should have them.
''')

    p.add_argument('-c', '--copyright', action='store_true',
                   help="Stop after updating copyright info & versions")
    p.add_argument('-w', '--warnings', action='store_true',
                   help="Don't change info, just print warnings")
    p.add_argument('-d', '--dependent', dest='dependent', action='store_true',
                   help="Have SCAIFE build dependent containers (default is independent)")
    p.add_argument('--top-dir', dest='topdir', default=os.getcwd(), help='''
Directory the tarball starts from. Should be the scaife directory
if you are creating a full SCAIFE tarball, or should the the scale.app
directory if you are creating a SCALe-only tarball.  Defaults to
current directory.
''')
    p.add_argument('--output-dir', dest='outputdir', default='./packages/',
                   help="Directory to store tarballs in, relative to top-dir.")
    p.add_argument('--target', default=','.join(TAR_CONFIGS.iterkeys()),
                   help='''
Comma-separated list of targets to build, options include offline,
online, scaife-offline, scaife-online, and scaife-scale-online.. You
can't mix SCALe-only and SCAIFE (meaning full SCAIFE) targets in a
single build with this script.
''')
    p.add_argument('--keep', dest='keep', default='',
                   help="Comma-separated list of proprietary tools to keep")
    return p.parse_args()


def main():
    args = parse_args()
    global WARNINGS
    WARNINGS = args.warnings
    os.chdir(args.topdir)
    cfg = read_configuration('ABOUT')
    cfg['target'] = args.target.split(',')
    if is_scaife():
        cfg['scale'] = read_configuration(SCAIFE_SCALE_PATH + "/ABOUT")

    global IGNORED_FILES
    IGNORED_FILES = adjust_scale_scaife_files(
        IGNORED_FILES, SCAIFE_IGNORED_FILES)
    if "scaife-scale-online" in cfg['target']:
        IGNORED_FILES = IGNORED_FILES + adjust_scale_scaife_files(
            IGNORED_SCAIFE_SCALE_FILES, SCAIFE_IGNORED_SCAIFE_SCALE_FILES)
    global COPYRIGHT_DENYLIST
    COPYRIGHT_DENYLIST = adjust_scale_scaife_files(
        COPYRIGHT_DENYLIST, ADDITIONAL_COPYRIGHT_DENYLIST)
    global PROPRIETARY_CODE_DIRS
    PROPRIETARY_CODE_DIRS = adjust_scale_scaife_files(
        PROPRIETARY_CODE_DIRS, SCAIFE_PROPRIETARY_CODE_DIRS)
    global PROPRIETARY_IGNORABLE_FILES
    PROPRIETARY_IGNORABLE_FILES = adjust_scale_scaife_files(
        PROPRIETARY_IGNORABLE_FILES, list())

    # Setup the local directory for packaging
    if "scaife-scale-online" in cfg['target']:
        for filepath in SCAIFE_SCALE_FILES_TO_CLOBBER:
            with open(filepath, "w") as f:
                f.write("# <legal></legal>") # it's clobberin' time!
    update_copyright(cfg)
    adjust_version_numbers(cfg)
    ignore_proprietary_code(args.keep.split(",") if args.keep != '' else [],
                            cfg['target'])

    if args.copyright:
        sys.exit()

    if not WARNINGS:
        fetch_manual(cfg)
    # After calling fetch_manual, then in the scale.app directory
    # Stay in scale.app directory for next few function calls
    fetch_cert_coding_guidelines(cfg)
    fetch_cwe_pdf(cfg)
    if not WARNINGS:
        fetch_vendor_bundle(cfg)

    # Before making the tarball, make sure in the original top-level directory
    os.chdir(args.topdir)

    # Go through the configurations and produce the tar.gz files.
    if not os.path.exists(args.outputdir):
        os.makedirs(args.outputdir)

    if not args.dependent:
        IGNORED_FILES.append("./docker-compose.override.yml")

    for tarcfg in (TAR_CONFIGS[k] for k in cfg['target']):
        print("Creating %s ..." % tarcfg['name'])
        create_tar_package(cfg, args.outputdir, tarcfg)


if __name__ == '__main__':
    main()
