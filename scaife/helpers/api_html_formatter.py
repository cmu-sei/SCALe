# -*- coding: utf-8 -*-
"""
    Script for formatting Swagger CodeGen HTML output that generates the individual SCAIFE
    API HTML file. Sometimes the HTML file formats the data improperly, or misses some data
    specified in the Swagger YAML. Note: This script requires BeautifulSoup >= 4.8.2
        Common errors this script will fix include:
            1. Model objects ('#/definitions/{object}') declared as arrays in the API will not populate in the HTML.
                
    From the scaife helpers directory run command: 
        >> python3 api_html_formatter.py <PATH_TO_SCAIFE_YAML> <PATH_TO_SCAIFE_HTML>
"""

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

import argparse
import os
from ruamel import yaml
from bs4 import BeautifulSoup


def main():
    """Specifies common CLI to format a HTML file from a Swagger YAML file.

    Args:
        input_yaml (filepath): Path to the YAML file that the HTML was created from.
        output_html (filepath): Path to the HTML to format

    Returns:    
        None
    """

    # Define the CLI
    arg_parser = argparse.ArgumentParser(
        description="Updates Swagger HTML files based on their YAML equivalent")
    arg_parser.add_argument("input_yaml", help="Path to the YAML file that the HTML was created from")
    arg_parser.add_argument("output_html", help="Path to the HTML file that should be formatted")
        
    args = arg_parser.parse_args()
    
    if not os.path.isfile(args.input_yaml):
        raise Exception("Error finding the YAML file")
        
    if not os.path.isfile(args.output_html):
        raise Exception("Error finding the HTML file") 
        
    yaml_models = None   
    
    problematic_models = {} # Based on the errors reported on the HTML API Generation Wiki  
    
    with open(args.input_yaml, 'r') as yaml_file:
        print("")
        print("*******************************************************************")
        print("LOADING AND PARSING THE YAML FILE: ")
        print(args.input_yaml)   
        print("")

        try:
            yaml_data = yaml.safe_load(yaml_file)
            
            if yaml_data:           
                yaml_models = yaml_data["definitions"] # List of all of the API models in the YAML file

        except Exception as yaml_error:
            print(yaml_error)
            print("Unable to parse YAML files")
    
    if yaml_models:
        for model_name, model_data in yaml_models.items():
            array_value = None
            
            if "type" in model_data:
                model_type = model_data["type"]
                if model_type == "array": # There are 3 types of arrays that cause the errors
                    model_items = model_data["items"] 
                    if "$ref" in model_items: # Type 1: References to declared objects
                        array_value = model_items["$ref"].split('/')[-1]
                    else:
                        item_type = model_items["type"]
                        if item_type == "object":
                            array_value = model_name + "_inner" # Type 2: References to subobjects, declared within this model
                        else:
                            array_value = item_type # Type 3: References to primitive types (i.e., string)
                            
                    if array_value:
                        problematic_models[model_name] = array_value
    

    if not problematic_models:   
        print("No Errors found in YAML file")
        return
    
    parsed_html = None
    
    print("")
    print("*******************************************************************")
    print("PARSING HTML: ")
    print(args.output_html)   
    print("")
        
    with open(args.output_html, 'r') as html_file:
        parsed_html = BeautifulSoup(html_file, 'html.parser')  
        
        model_divs = parsed_html.find_all("div", {"class": "model"})
        
        for m_div in model_divs:
            model_name = m_div.find('a')['name'] 
            
            if model_name in problematic_models: # Find the model div for the problematic models
                referenced_object = problematic_models[model_name]
                field_items = m_div.find("div", {"class": "field-items"})
                array_insert = BeautifulSoup('<div class="param-desc"><span class="param-type"><a href="#' + 
                                   referenced_object +'">array['+ referenced_object +']</a></span></div>', 'html.parser')
                field_items.clear()
                field_items.insert(1, array_insert) # Insert the missing data into the model div
                
    with open(args.output_html, 'w') as html_output:
        html_output.write(str(parsed_html))


if __name__ == "__main__":
    main()
