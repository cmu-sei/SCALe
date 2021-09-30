# -*- coding: utf-8 -*-
"""
    Script for running Swagger's CodeGen to generate the individual SCAIFE
    API HTML  and JSON files. Note Swagger CodeGen should be installed to use this script.

    From the scaife helpers directory run command:
        >> python3 api_html_generator.py <PATH_TO_SCAIFE> <PATH_TO_CODEGEN>/swagger-codegen -v 1.0.0 -li <PATH_TO_SCAIFE>/ABOUT
"""

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

import argparse
import os
import json
import subprocess
from ruamel import yaml

SWAGGER_FILE_NAME = "swagger.yaml"

def update_yaml_files(input_dir, version=None, license_path=None):
    """ Update the YAML files prior to generating the new HTML and JSON files.
    """
    updated_swagger_filepaths = []
    version_string = None
    license_string = ""

    if version: # Get the new API version
        version_string = version

    if license_path: # Get the new license information to use in the file
        if os.path.isfile(license_path):
            with open(license_path, 'r') as license_file:
                try:
                    license_data = json.loads(license_file.read())

                    if "legal-api" in license_data:
                        for line in license_data["legal-api"]:
                            if line != "":
                                license_string +=  line + " "
                            else:
                                license_string += "  "
                except Exception as license_error:
                    print("Unable to parse license information")

    if version_string or license_string != "":
        if os.path.isdir(input_dir):
            for root, dirs, files in os.walk(input_dir):
                for yaml_file in files:
                    if yaml_file == SWAGGER_FILE_NAME:
                        #print(os.path.abspath(root), yaml_file) #use absolute path of root to distinguish where the yaml file is in the directory
                        #beneficial for automating different file versions per file location.

                        yaml_data = {}

                        with open(os.path.join(root, yaml_file), 'r') as read_yaml_file:
                            try:
                                yaml_data = yaml.round_trip_load(read_yaml_file, preserve_quotes=True)

                                if yaml_data:
                                    if version_string:
                                        yaml_data["info"]["version"] = version_string

                                    if license_string:
                                        yaml_data["info"]["license"]["name"] = license_string

                            except Exception as yaml_error:
                                print("Unable to parse YAML files")

                        if yaml_data:
                            with open(os.path.join(root, yaml_file), 'w') as write_yaml_file:
                                try:
                                    write_yaml_file.write(yaml.round_trip_dump(yaml_data))
                                except Exception as yaml_error:
                                    print("Unable to write to YAML files")

                        updated_swagger_filepaths.append(os.path.abspath(root))

            return updated_swagger_filepaths


def run_swagger_code_gen(codegen_location, output_dirs):
    """ Generate the HTML and JSON files with Swagger CodeGen and place them in the correct directory
    """
    cd_command = "cd " + codegen_location

    try:
        start_directory = os.getcwd()

        # Change directory to codegen location
        os.chdir(codegen_location)

        for yaml_dir in output_dirs:

            # Get the templates directory for HTML files
            html_dir = None

            remove_swagger_dir = yaml_dir.rfind('/')

            if remove_swagger_dir != -1:
                html_dir = os.path.join(yaml_dir[:remove_swagger_dir], "templates")


            yaml_file = os.path.join(yaml_dir, SWAGGER_FILE_NAME)

            print("")
            print("*******************************************************************")
            print("GENERATING HTML AND JSON FILES FOR: ")
            print(yaml_file)
            print("")

            if html_dir:
                html_command = "java -jar modules/swagger-codegen-cli/target/swagger-codegen-cli.jar generate -i " + yaml_file  + " -l html -o " + html_dir
            else:
                print("Unable to Generate HTML File for ", yaml_file)

            json_command = "java -jar modules/swagger-codegen-cli/target/swagger-codegen-cli.jar generate -i " + yaml_file  + " -l swagger -o " + yaml_dir

            # Run commands to create html and json files
            subprocess.run(html_command, shell=True)

            subprocess.run(json_command, shell=True)

        # Return to the previous directory
        os.chdir(start_directory)

    except Exception as generation_error:
        print(generation_error)


def main():
    """Specifies common CLI to generate HTML files from Swagger YAML files. This
       can also be used to update the version number the YAML files.

    Args:
        input_dir (filepath): Path of the input directory for YAML files.
        codegen_dir (filepath): Path to CodeGen installation directory
        version (string): Version to update the swagger yaml files with.
        license_path (filepath): Path to the JSON file with license information.
            Use SCAIFE's ABOUT file: <SCAIFE_HOME_DIRECTORY>/scale.app/ABOUT

    Returns:
        None
    """

    # Define the CLI
    arg_parser = argparse.ArgumentParser(
        description="Updates Swagger's YAML files and populates HTML and JSON equivalents")
    arg_parser.add_argument("input_dir", help="Directory with YAML input files ")
    arg_parser.add_argument("codegen_dir", help="Directory where the Swagger codegen tool is located" +
                                                " (available at https://github.com/swagger-api/swagger-codegen in the master branch)")
    arg_parser.add_argument('-v', '--version', help="Version number to use in output files")
    arg_parser.add_argument(
        '-li', '--license_path', help="Path to licensing information to include in the swagger files. " +
                                      "The user may find one of the following 2 filepaths useful but can also specify their own. " +
                                      "(1) <SCAIFE_HOME_DIRECTORY>/ABOUT and (2) <SCALE_HOME_DIRECTORY>/scale.app/ABOUT")

    args = arg_parser.parse_args()

    # Update the YAML files with the input
    swagger_paths = update_yaml_files(args.input_dir, args.version, args.license_path)


    # Run CodeGen on the swagger files to create the html and json files in the same directory)
    if swagger_paths:
        run_swagger_code_gen(args.codegen_dir, swagger_paths)


if __name__ == "__main__":
    main()
