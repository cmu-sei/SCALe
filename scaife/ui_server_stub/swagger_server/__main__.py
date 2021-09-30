#!/usr/bin/env python3

# This is the main launch point of the swagger/flask app. It's not
# intended to be invoked directly by a user, but does take a --mode
# argument for determing test vs production mode when automatically
# launching within a container, e.g:
#
#    python -m swagger_server
#
# or
#
#    python -m swagger_server --mode test

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

import connexion
import os, argparse
from flask_cors import CORS
from swagger_server import encoder

def main(mode=None):
    app = connexion.App(__name__, specification_dir='./swagger/')
    app.app.json_encoder = encoder.JSONEncoder
    # folder with the HTML docs
    app.app.config['templates_path'] = './templates'
    # folder to upload files to
    app.app.config['UPLOAD_FOLDER'] = './uploaded_files'
    app.app.config['DATABASE_NAME'] = 'ui_test'
    app.app.config['SECRET_KEY'] = 'secretkey'
    app.app.config['datahub_server'] = 'datahubkey'
    app.app.config['stats_server'] = 'statskey'
    # add CORS support to the app, remove cors in production
    CORS(app.app)
    app.run(host='127.0.0.1', port=8083)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="""
        This is the main launch point of the swagger/flask app. It's not
        intended to be invoked directly by a user, but does take a
        --mode argument for determing test vs production mode when
        automatically launching within a container, e.g. "python -m
        swagger_server --mode test"
    """)
    parser.add_argument("-m", "--mode", required=False,
            help="specify 'test' or 'production'")
    args = parser.parse_args()

    mode = args.mode or os.getenv("FLASK_ENV") or os.getenv("SCAIFE_MODE")
    main(mode=mode)
