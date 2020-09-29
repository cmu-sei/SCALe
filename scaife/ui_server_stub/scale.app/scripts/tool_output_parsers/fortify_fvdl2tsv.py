# <legal>
# SCALe version r.6.2.2.2.A
# 
# Copyright 2020 Carnegie Mellon University.
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

import re
import sys
import xml.etree.ElementTree as ET
from HTMLParser import HTMLParser

from toolparser import tool_parser_args

class FortifyNode(object):

    def __init__(self):
        self.line = None
        self.line_end = None
        self.col_start = None
        self.col_end = None
        self.path = None
        self.context_id = None
        self.action_type = None
        self.action_text = None
        self.label = None
        self.is_default = False

    @classmethod
    def from_xml(cls, node):
        line = None
        line_end = None
        col_start = None
        col_end = None
        path = None
        context_id = None
        action_type = None
        action_text = None

        loc = node.find(".//SourceLocation")
        if loc is not None:
            line = loc.get("line")
            line_end = loc.get("lineEnd")
            col_start = loc.get("colStart")
            col_end = loc.get("colEnd")
            path = loc.get("path")
            context_id = loc.get("contextId")

        action = node.find(".//Action")
        if action is not None:
            action_type = action.get("type")
            action_text = action.text

        label = node.get("label")
        is_default = node.get("isDefault")

        result = cls()
        result.line = line
        result.line_end = line_end
        result.col_start = col_start
        result.col_end = col_end
        result.path = path
        result.context_id = context_id
        result.is_default = is_default
        result.label = label
        result.action_type = action_type
        result.action_text = action_text
        return result

    def format_action(self):
        result = ""
        if self.action_text is not None:
            if self.action_type is not None:
                result += "(" + self.action_type + ") "
            result += self.action_text
        elif self.label is not None:
            result += self.label

        return result


class AbstractParser(HTMLParser):

    def __init__(self, replace):
        HTMLParser.__init__(self)
        self.text = ""
        self.alttext = ""
        self.in_alt = False
        self.replace = replace
        self.replace_failed = False

    def append_text(self, text):
        if self.in_alt:
            self.alttext += text
        else:
            self.text += text

    def handle_starttag(self, tag, attrs):
        if tag.lower() == "altparagraph":
            self.in_alt = True
        elif tag.lower() == "replace":
            replacement = None
            for (name, value) in attrs:
                if name == "key":
                    if value in self.replace:
                        replacement = self.replace[value]
                    else:
                        self.replace_failed = True
                    break

            if replacement is not None:
                self.append_text(replacement)

    def handle_endtag(self, tag):
        if tag.lower() == "altparagraph":
            self.in_alt = False

    def handle_data(self, data):
        self.append_text(data)

    def get_message(self):
        if self.replace_failed:
            return self.alttext
        else:
            return self.text


def parse_replacements(node):
    replace = {}
    if node is not None:
        for defn in node.iter("Def"):
            replace[defn.get("key")] = defn.get("value")
    return replace


def get_xml_text(root, query):
    result = None
    node = root.find(query)
    if node is not None:
        result = node.text
    return result


def fortify_fvdl_parse(input_file, output_file):
    tree = ET.iterparse(input_file)

    # Strip out the namespace
    for _, el in tree:
        if '}' in el.tag:
            el.tag = el.tag.split('}', 1)[1]

    root = tree.root
    abstracts = {}
    trace_nodes = {}

    for node in root.iter("Description"):
        class_id = node.attrib["classID"]
        abstracts[node.get("classID")] = node.find(".//Abstract").text

    if root.find(".//UnifiedNodePool") is not None:
        for node in root.find(".//UnifiedNodePool").iter("Node"):
            trace_nodes[node.get("id")] = FortifyNode.from_xml(node)

    for vuln in root.iter("Vulnerability"):

        # Create a checker name equivalent to that in the developer xml file
        class_type = get_xml_text(vuln, ".//ClassInfo/Type")
        class_subtype = get_xml_text(vuln, ".//ClassInfo/Subtype")
        if class_type is not None:
            checker = class_type
            if class_subtype is not None:
                checker += ": " + class_subtype
        p = re.compile(r"[^A-Za-z0-9_]")
        checker = p.sub("_", checker)

        message = None
        replace_xml = vuln.find(".//ReplacementDefinitions")
        message_replacements = parse_replacements(replace_xml)
        class_id = get_xml_text(vuln, ".//ClassInfo/ClassID")
        if class_id is not None:
            abstract_parser = AbstractParser(message_replacements)
            abstract_parser.feed(abstracts[class_id])
            message = abstract_parser.get_message()

        primary_node = None
        secondary_nodes = []
        for entry in vuln.find(".//Trace/Primary").iter("Entry"):
            node_ref = entry.find(".//NodeRef")
            node_xml = entry.find(".//Node")

            node = None
            if node_ref is not None:
                node = trace_nodes[node_ref.get("id")]
            elif node_xml is not None:
                node = FortifyNode.from_xml(node_xml)

            if node is not None:
                if node.is_default:
                    primary_node = node
                else:
                    secondary_nodes.append(node)

        output_file.write("\t".join([checker, primary_node.path,
                                          primary_node.line, message]))
        for node in secondary_nodes:
            output_file.write("\t" + "\t".join([node.path, node.line, node.format_action()]))
            # path, line, msg
        output_file.write("\n")


if __name__ == "__main__":
    args = tool_parser_args()

    input_file = open(args.input_file, "r")
    output_file = open(args.output_file, "w")

    with open(input_file, "r") as input_fh:
        with open(output_file, "w") as output_fh:
            fortify_fvdl_parse(input_fh, output_fh)
