import os

"""
1) mappings from checkerIDs to CERT coding rules 
(these mappings are found in the java.TOOLNAME.properties 
files here: scale.app/scripts/data/properties/cert_rules/ ); and

2) mappings from CERT coding rules to CWE.

3) For a given checker ID named "C" for tool "T", you will 
create an entry in the  file scale.app/scripts/data/properties/cwe/java.TOOLNAME.properties  
that is on its own line (a new mapping) that has "T: W" where "W" is a CWE ID.

4) Specifically, for checker ID "C", from the cert_rules' .properties file, 
obtain the CERT coding rule(s) that  match to it. In this example, let's say 
it only matches to one coding rule "R". Then, from the mappings from (2) 
determine if one or more CWE IDs map to "R". 

5) For each CWE ID mapped that way, enter a new line into the 
scale.app/scripts/data/properties/cwe/java.TOOLNAME.properties 
file, for that CWE ID and the checker "C".

"""

cert_coding_rules_dir = "../data/properties/cert_rules/"
cwe_mappings_dir = "../data/properties/cwe/"
checkers_to_cert_coding_rules = []
cert_coding_rules_to_cwe = []

# (1)
print("Loading the cert coding rules files...")
for file in os.listdir(cert_coding_rules_dir):
    if file.startswith("java") and file.endswith("properties"):
        tool = file.replace("java.","").replace(".properties","")
        # get mappings
        with open("{}/{}".format(cert_coding_rules_dir, file), 'r') as f:
            reader = f.readlines()
            for line in reader:
                # get relevant lines
                if not line.startswith("#") and line != "\n":
                    checker_id = line.split(":")[0].strip()
                    cert_coding_rule = line.split(":")[1].strip()
                    checkers_to_cert_coding_rules.append([tool, checker_id, cert_coding_rule])

# (2)
print("Loading the cert coding rules to CWE mappings...")
with open('java_to_cwe.txt', 'r') as f:
    reader = f.readlines()
    for row in reader:
        cert_coding_rule = row.split("\t")[0].strip()
        cwe_id = row.split("\t")[1].strip()
        cert_coding_rules_to_cwe.append([cert_coding_rule, cwe_id])

# (3)
print("Getting unique tools...")
unique_tools = []
for c in checkers_to_cert_coding_rules:
    if c[0] not in unique_tools:
        unique_tools.append(c[0])

print("Creating the java.TOOLNAME.properties files...")
for tool in unique_tools:
    with open("{}/java.{}.properties".format(cwe_mappings_dir, tool), 'a') as f:
        f.write("# Mappings data for {} error identifiers (checkers) to CWE IDs\n".format(tool))
        f.write("# from the {} CERT rules + CERT->CWE mappings\n".format(tool))
        f.write("#\n")
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
        f.write("\n")
        print("Creating java.{}.properties files...".format(tool))
        for c in checkers_to_cert_coding_rules:
            t = c[0]
            if t == tool:
                checker_id = c[1]
                cert_coding_rule = c[2]
                for cwe in cert_coding_rules_to_cwe:
                    if cert_coding_rule == cwe[0]:
                        # create a new line in the java.TOOLNAME.properties file
                        f.write("{}: {}\n".format(checker_id, cwe[1]))
                        print("Writing record {} {}...".format(checker_id, cwe[1]), end='\r')

print("\nProperties file creation complete")