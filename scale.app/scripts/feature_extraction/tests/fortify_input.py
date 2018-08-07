from xml.etree import ElementTree

from feature_extraction.tests.test_util import indent


base_template = """
<ReportDefinition type="standard">
    <TemplateName>Fortify Developer Workbook</TemplateName>
    <LogoPath>/fortify.jpg</LogoPath>
    <Footnote>Copyright 2014 Fortify Software Inc.</Footnote>
    <UserName/>
    <ReportSection enabled="true" optionalSubsections="true">
        <Title>Results Outline</Title>
        <SubSection enabled="true">
            <Title>Vulnerability Examples by Category</Title>
            <Description>Results summary of all issue categories. Vulnerability examples are provided by category.</Description>
            <IssueListing listing="true" limit="5">
                <Refinement/>
                <Chart chartType="list">
                    <Axis>Category</Axis>
                    <MajorAttribute>Analysis</MajorAttribute>
                    {groups}
                </Chart>
            </IssueListing>
        </SubSection>
    </ReportSection>
</ReportDefinition>
"""
class FortifyDeveloperXml(object):
    def __init__(self):
        self.data = {}
        self.groups = []
        self.data["groups"] = ""

    def __str__(self):
        self.data["groups"] = ""
        for group in self.groups:
            self.data["groups"] += str(group)
        root = ElementTree.fromstring(base_template.format(**self.data))
        indent(root)
        return ElementTree.tostring(root)

group_template = """
<GroupingSection count="{count}">
    <groupTitle>{title}</groupTitle>
    <MajorAttributeSummary>This section is omitted.</MajorAttributeSummary>
    {issues}
</GroupingSection>
"""
class FortifyDeveloperXmlGrouping(object):
    def __init__(self):
        self.data = {}
        self.issues = []
        
        self.data["count"] = 1
        self.data["title"] = "Title"
        self.data["issues"] = ""
        
    def __str__(self):
        self.data["issues"] = ""
        for issue in self.issues:
            self.data["issues"] += str(issue)
        return group_template.format(**self.data)

issue_template = """
<Issue iid="{issue_id}" ruleID="{rule_id}">
    <Category>{category}</Category>
    <Folder>{folder}</Folder>
    <Kingdom>{kingdom}</Kingdom>
    <Abstract>{abstract}</Abstract>
    <Friority>{friority}</Friority>
    {primary_source}
    {secondary_sources}
</Issue>
"""
class FortifyDeveloperXmlIssue(object):
    def __init__(self):
        self.data = {}
        self.primary_source = None
        self.secondary_sources = []
        
        self.data["issue_id"] = "IssueId"
        self.data["rule_id"] = "RuleId"
        self.data["category"] = "Category"
        self.data["folder"] = "Folder"
        self.data["kingdom"] = "Kingdom"
        self.data["abstract"] = "Abstract"
        self.data["friority"] = "High"
        self.data["primary_source"] = ""
        self.data["secondary_sources"] = ""

    def __str__(self):
        if self.primary_source:
            self.data["primary_source"] = "<Primary>" + str(self.primary_source) + "</Primary>"
        self.data["secondary_sources"] = ""
        for source in self.secondary_sources:          
            self.data["secondary_sources"] += "<Source>" + str(source) + "</Source>"
        return issue_template.format(**self.data)

source_template = """
    <FileName>{filename}</FileName>
    <FilePath>{filepath}</FilePath>
    <LineStart>{linestart}</LineStart>
    <Snippet>{snippet}</Snippet>
"""
class FortifyDeveloperXmlSource(object):
    def __init__(self):
        self.data = {}
        self.data["filename"] = "FileName"
        self.data["filepath"] = "FilePath"
        self.data["linestart"] = 1
        self.data["snippet"] = "Snippet"       

    def __str__(self):
        return source_template.format(**self.data)
