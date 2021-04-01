import os, re

# This is the automation module that uses the automate module to perform
# various scenarios and operations on SCALe. Submodules include
# "scenarios" that perform specific compound tasks such as creating the
# "manual test projects" described in the SCALe-SCAIFE interaction
# document.
#
# The "scenarios" correspond to particular submodules within this
# directory. These must be imported down below, thereby causing each
# submodule to register itself. Each of those scenario modules should
# register itself with a label using the functions below. The import of
# this top level module must happen towards the end of the scenario
# module. NOTE: yes, this means that this top level module imports each
# of the scenario modules, and each of those scenario modules import
# this top level module in order to register themselves.
#
# Each scenario module registers itself using
# register_scenario_function() below. Its arguments are the main
# function (the actual function, not the name of the function), the
# scenario label, and, optionally the name of the module/script that is
# implementing the scenario. This will look similar to this at the
# bottom of the scenario module:
#
# ...
#
# import automation
# automation.register_scenario_function(func, "scenario_label", script=__file__)
#
# if __name__ == "__main__":
#    parser = argparse.ArgumentParser(
#        description="Create project scenario_label: main_method_name")
#    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
#    args = parser.parse_args()
#    main()
#
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

_scenario_functions = {}

def register_scenario_function(func, label=None, script=None):
    # note: 'func' is the actual function object, not its name
    if label:
        if label in _scenario_functions:
            existing_func = _scenario_functions[label]
            if existing_func is not func:
                print(existing_func)
                print(func)
                raise ValueError("scenario label already registered: %s" % label)
        _scenario_functions[label] = func
    if script:
        name = os.path.basename(script)
        name = re.sub(r"\.py$", "", name)
        if name in _scenario_functions:
            existing_func = _scenario_functions[label]
            if existing_func is not func:
                raise ValueError("scenario script already registered: %s" % name)
        _scenario_functions[name] = func
    if not label and not script:
        fname = func.__name__
        if fname in _scenario_functions:
            existing_func = _scenario_functions[fname]
            if existing_func is not func:
                raise ValueError("scenario func already registered: %s" % fname)
        _scenario_functions[fname] = func

def scenario_function(label_or_name):
    if not _scenario_functions:
        # make sure automation scenarios register themselves
        import create_manual_test_project_1_dos2unix_rosecheckers
        import create_manual_test_project_1_microjuliet_cppcheck
    return _scenario_functions[label_or_name]
