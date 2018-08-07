# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved.
# See COPYRIGHT file for details.

from features import *
import xml.etree.ElementTree as ET
from HTMLParser import HTMLParser


def fortify_dev_xml_parser(input_file):
    tree = ET.parse(input_file)
    root = tree.getroot()
    diags = []
    for node in root.iter("Issue"):
        primary = node.find("Primary")
        category = node.find("Category").text
        abstract = node.find("Abstract").text
        diag = Diagnostic(tool=Tool.Fortify)
        diag.add_feature(CheckerFeature(category))

        if primary is not None:
            diag.add_feature(FilePathFeature(primary.find("FilePath").text))
            diag.add_feature(
                LineStartFeature(int(primary.find("LineStart").text)))
            diag.add_feature(MessageFeature(abstract))
        for other in node.iter("Source"):
            subdiag = Diagnostic(tool=Tool.Fortify)
            subdiag.add_feature(FilePathFeature(other.find("FilePath").text))
            subdiag.add_feature(
                LineStartFeature(int(other.find("LineStart").text)))
            diag.add_sub_measurement(subdiag)
        diags.append(diag)
    return diags


class FortifyContext(object):

    def __init__(self):
        self.func = None
        self.clazz = None
        self.namespace = None

    @classmethod
    def from_xml(cls, node):
        func = ""
        clazz = ""
        namespace = ""
        if node is not None:
            function = node.find(".//Function")
            class_ident = node.find(".//ClassIdent")
            if function is not None:
                func = function.get("name")
                namespace = function.get("namespace")
                clazz = function.get("enclosingClass")
            if class_ident is not None:
                namespace = class_ident.get("namespace")
                clazz = class_ident.get("name")

        result = cls()
        result.func = func
        result.clazz = clazz
        result.namespace = namespace
        return result


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


def fortify_fvdl_parser(input_file):
    tree = ET.iterparse(input_file)

    # Strip out the namespace
    for _, el in tree:
        if '}' in el.tag:
            el.tag = el.tag.split('}', 1)[1]

    root = tree.root
    diags = []
    abstracts = {}
    trace_nodes = {}
    contexts = {}

    for node in root.iter("Description"):
        class_id = node.attrib["classID"]
        abstracts[node.get("classID")] = node.find(".//Abstract").text

    for node in root.find(".//UnifiedNodePool").iter("Node"):
        trace_nodes[node.get("id")] = FortifyNode.from_xml(node)

    for node in root.find(".//ContextPool").iter("Context"):
        contexts[node.get("id")] = FortifyContext.from_xml(node)

    for vuln in root.iter("Vulnerability"):
        # Class Info
        class_id = get_xml_text(vuln, ".//ClassInfo/ClassID")
        kingdom = get_xml_text(vuln, ".//ClassInfo/Kingdom")
        class_type = get_xml_text(vuln, ".//ClassInfo/Type")
        class_subtype = get_xml_text(vuln, ".//ClassInfo/Subtype")
        analyzer_name = get_xml_text(vuln, ".//ClassInfo/AnalyzerName")
        default_severity = get_xml_text(vuln, ".//ClassInfo/DefaultSeverity")

        # Create a checker name equivalent to that in the developer xml file
        if class_type is not None:
            checker = class_type
            if class_subtype is not None:
                checker += ": " + class_subtype

        # Instance info
        instance_id = get_xml_text(vuln, ".//InstanceInfo/InstanceID")
        instance_severity = get_xml_text(
            vuln, ".//InstanceInfo/InstanceSeverity")
        confidence = get_xml_text(vuln, ".//InstanceInfo/Confidence")

        message = None
        replace_xml = vuln.find(".//ReplacementDefinitions")
        message_replacements = parse_replacements(replace_xml)
        if class_id is not None:
            abstract_parser = AbstractParser(message_replacements)
            abstract_parser.feed(abstracts[class_id])
            message = abstract_parser.get_message()

        # Parse the source context
        src_context = FortifyContext.from_xml(vuln.find(".//Context"))

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

        diag = Diagnostic(tool=Tool.Fortify)
        diag.add_feature(CheckerFeature(checker))

        if primary_node is not None:
            diag.add_feature(FilePathFeature(primary_node.path))
            diag.add_feature(LineStartFeature(primary_node.line))
            diag.add_feature(LineEndFeature(primary_node.line_end))
            diag.add_feature(ColStartFeature(primary_node.col_start))
            diag.add_feature(ColEndFeature(primary_node.col_end))
            diag.add_feature(MessageFeature(message))
            diag.add_feature(FunctionOrMethodFeature(src_context.func))
            diag.add_feature(ClassFeature(src_context.clazz))
            diag.add_feature(NamespaceFeature(src_context.namespace))

            diag.add_feature(FortifyKingdomFeature(kingdom))
            diag.add_feature(FortifyClassTypeFeature(class_type))
            diag.add_feature(FortifyClassSubTypeFeature(class_subtype))
            diag.add_feature(FortifyAnalyzerNameFeature(analyzer_name))
            diag.add_feature(FortifyDefaultSeverityFeature(default_severity))

            diag.add_feature(FortifyInstanceIdFeature(instance_id))
            diag.add_feature(FortifyInstanceSeverityFeature(instance_severity))
            diag.add_feature(FortifyConfidenceFeature(confidence))

        for node in secondary_nodes:
            sub = Diagnostic(tool=Tool.Fortify)
            sub.add_feature(FilePathFeature(node.path))
            sub.add_feature(LineStartFeature(node.line))
            sub.add_feature(LineEndFeature(node.line_end))
            sub.add_feature(ColStartFeature(node.col_start))
            sub.add_feature(ColEndFeature(node.col_end))
            sub.add_feature(MessageFeature(node.format_action()))

            node_context = contexts.get(node.context_id)
            if node_context:
                sub.add_feature(FunctionOrMethodFeature(node_context.func))
                sub.add_feature(ClassFeature(node_context.clazz))
                sub.add_feature(NamespaceFeature(node_context.namespace))

            diag.add_sub_measurement(sub)

        diags.append(diag)

    return diags
