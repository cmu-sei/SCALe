# -*- coding: utf-8 -*-

"""
Remove YAML examples from Swagger YAML API Definitions.

Usage: 'python3 remove_yaml_examples.py <PATH_TO_YAML_FILE>/swagger.yaml'
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
from ruamel import yaml


def update_yaml_files(yaml_file):
    """ Update the YAML file by removing the examples
    """
    yaml_data = {}
    
    if os.path.isfile(yaml_file): 
        with open(yaml_file, 'r') as read_yaml_file:
            try:
                yaml_data = yaml.round_trip_load(read_yaml_file, preserve_quotes=True)
                
                if yaml_data:
                    # Swagger 2.0 Objects
                    if "definitions" in yaml_data:
                        for model_name in yaml_data["definitions"]:
                            yaml_model = yaml_data["definitions"][model_name]
                            if "example" in yaml_model:
                                yaml_model.pop("example") # Remove the example
                                
                            yaml_data["definitions"][model_name] = yaml_model
                    
                    # Swagger 3.0 Objects        
                    if "components" in yaml_data:   
                        for model_name in yaml_data["components"]["schemas"]:
                            yaml_model = yaml_data["components"]["schemas"][model_name]
                            if "example" in yaml_model:
                                yaml_model.pop("example") # Remove the example
                                
                            yaml_data["components"]["schemas"][model_name] = yaml_model


            except Exception as yaml_error:
                print("Unable to parse YAML files: " + str(yaml_error))
                
            
        if yaml_data:
            with open(yaml_file, 'w') as write_yaml_file:
                try:
                    write_yaml_file.write(yaml.round_trip_dump(yaml_data))
                except Exception as yaml_error:
                    print("Unable to write to YAML files: " + str(yaml_error))


def main():
    """Specifies common CLI to remove examples from YAML
    """

    # Define the CLI
    arg_parser = argparse.ArgumentParser(
        description="Removes examples from YAML")
    arg_parser.add_argument("yaml_file", help="Path to the YAML input file")
    args = arg_parser.parse_args()

    update_yaml_files(args.yaml_file)
    

if __name__ == "__main__":
    main()
