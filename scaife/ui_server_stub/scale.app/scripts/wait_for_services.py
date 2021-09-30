#!/usr/bin/env python

# Simple command line interface to wait for SCALe and all SCAIFE
# services to be up and running. An optional timeout value (in seconds)
# can be provided; each service will be given that long to become
# active. Services can be explicitly included or excluded. Exits with
# status code 0 if all services are up within the the alloted time.

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
from bootstrap import VERBOSE, ServiceException

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Wait for SCALe and SCAIFE services to be up")
    parser.add_argument("-t", "--timeout", help="""
        Time in seconds before giving up on each service. Default: %d
        """ % bootstrap.default_svc_timeout)
    parser.add_argument("-i", "--include", help="""
        Comma-separated list of services to include; if unspecified,
        all services are included.
        """)
    parser.add_argument("-e", "--exclude", help="""
        Comma-separated list of services to exclude; if any.
        """)
    parser.add_argument("--localhost", action="store_true", help="""
        Substitue hostnames from config with "localhost"
        """)
    parser.add_argument("-l", "--list", action="store_true", help="""
        Print available services.
        """)
    parser.add_argument("-v", "--verbose", action=bootstrap.Verbosity)
    args = parser.parse_args()
    scale_module = bootstrap.this_module()
    if args.list:
        print "available services: %s" \
            % ', '.join([scale_module.name] + \
            sorted(x.name for x in scale_module.services))
        sys.exit(0)
    include = args.include
    if include:
        include = [x.strip() for x in re.split(r",", include)]
    exclude = args.exclude
    if exclude:
        exclude = [x.strip() for x in re.split(r",", exclude)]
    try:
        bootstrap.wait_for_services(timeout=args.timeout,
                include=include, exclude=exclude, localhost=args.localhost,
                loud=(VERBOSE > 1))
    except ServiceException as e:
        print e.message
        sys.exit(1)
