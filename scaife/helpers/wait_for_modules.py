#!/usr/bin/env python3

# Simple command line interface to wait for SCALe and all SCAIFE
# services to be up and running. An optional timeout value (in seconds)
# can be provided; each service will be given that long to become
# active. Services can be explicitly included or excluded. Exits with
# status code 0 if all services are up within the the alloted time.
#
# NOTE: By default this script/module will use the the hostnames for the
# various services as defined in the servers.conf files in each module's
# swagger directory. If running from a host operating system, such as
# bamboo, use the --localhost option for service detection -- this will
# overide the servers.conf hostnames with 'localhost' on the same port.

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

import sys, re, argparse
import bootstrap
from bootstrap import VERBOSE, ServiceTimeout

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Wait for SCAIFE services to be up")
    parser.add_argument("-t", "--timeout", type=int, help="""
        Time in seconds before giving up on each service. Default: %d
        """ % bootstrap.default_svc_timeout)
    parser.add_argument("-i", "--include", help="""
        Comma-separated list of SCAIFE services to include; if unspecified,
        all services are included.
        """)
    parser.add_argument("-e", "--exclude", help="""
        Comma-separated list of SCAIFE services to exclude; if any.
        """)
    parser.add_argument("--include-services", action="store_true", help="""
        Include client services defined for selected
        modules (e.g. mongodb, etc)
        """)
    parser.add_argument("--localhost", action="store_true", help="""
        Substitue hostnames from config with "localhost"
        """)
    parser.add_argument("-l", "--list", action="store_true", help="""
        Print available modules.
        """)
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    args = parser.parse_args()
    if args.list:
        print("available services: %s" \
            % ', '.join(x.name for x in bootstrap.modules_present()))
        sys.exit(0)
    include = args.include
    if include:
        include = [x.strip() for x in re.split(r",", include)]
    exclude = args.exclude
    if exclude:
        exclude = [x.strip() for x in re.split(r",", exclude)]
    try:
        bootstrap.wait_for_modules(timeout=args.timeout,
                include=include, exclude=exclude,
                include_services=args.include_services,
                localhost=args.localhost)
    except ServiceTimeout as e:
        print(e)
        sys.exit(1)
