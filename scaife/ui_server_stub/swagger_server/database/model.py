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

from mongoengine import *
import re

class Flag(EmbeddedDocument):
    flag = BooleanField(default=False)
    timestamp = DateTimeField()


class Verdict(EmbeddedDocument):
    verdict = StringField(options=['Unknown', 'Complex', 'False', 'Dependent','True'], default='Unknown')
    timestamp = DateTimeField()


class Ignored(EmbeddedDocument):
    ignored = StringField(options=['Unknown', 'True', 'False'], default='Unknown')
    timestamp = DateTimeField()


class Dead(EmbeddedDocument):
    dead = StringField(options=['Unknown', 'True', 'False'], default='Unknown')
    timestamp = DateTimeField()


class InapplicableEnvironment(EmbeddedDocument):
    inapplicable_environment = StringField(options=['Unknown', 'True', 'False'], default='Unknown')
    timestamp = DateTimeField()


class DangerousConstruct(EmbeddedDocument):
    dangerous_construct = StringField(options=['Unknown', 'No', 'Low Risk', 'Medium Risk', 'High Risk'], default='Unknown')
    timestamp = DateTimeField()


class Notes(EmbeddedDocument):
    notes = StringField()
    timestamp = DateTimeField()


class Determination(EmbeddedDocument):
    flag_list = EmbeddedDocumentListField(Flag)
    verdict_list = EmbeddedDocumentListField(Verdict)
    ignored_list = EmbeddedDocumentListField(Ignored)
    dead_list = EmbeddedDocumentListField(Dead)
    inapplicable_environment_list = EmbeddedDocumentListField(InapplicableEnvironment)
    dangerous_construct_list = EmbeddedDocumentListField(DangerousConstruct)
    notes_list = EmbeddedDocumentListField(Notes)
    uploader_id = StringField()
    auditor = StringField()
    audit_condition = StringField()  # Used to track old mappings against more current ones. Mappings are done differently.

class CodeLanguage(Document):
    language = StringField()
    version = StringField()
    
# Values are used in the load scripts
class ToolName(object):
    Coverity = "coverity"
    Cppcheck = "cppcheck"
    LDRA = "ldra"
    Parasoft = "parasoft"
    PCLint = "pclint"
    MSVS = "msvs"
    MSCA = "msca"
    GCC = "gcc"
    Findbugs = "findbugs"
    Eclipse = "eclipse"
    Rosecheckers = "rosecheckers"


class DefectInfo(EmbeddedDocument):
    line_start = IntField()
    line_end = IntField()
    present_defects = ListField(StringField())
    absent_defects = ListField(StringField())
    exist_in_sard = BooleanField(default=False)


class SourceFunction(Document):
    package_id = StringField(required=True) # Required to ensure the SourceFunctions are associated with a package
    name = StringField()
    line_start = IntField()
    line_end = IntField()
    sourcefile = ReferenceField('SourceFile') # Field name in ophelia db
    metrics_data = DictField()


class SourceFile(Document):
    package_id = StringField(required=True) # Required to ensure the SourceFiles are associated with a package
    suite_id = StringField()
    test_id = StringField()
    filename = StringField()
    filepath = StringField()
    filepath_depth = IntField()
    line_count = IntField()
    metrics_data = DictField()
    defect_info = EmbeddedDocumentListField(DefectInfo)
    functions = ListField(ReferenceField(SourceFunction))

    meta = {
        'indexes': [
            'filename',
        ]
    }


class Message(EmbeddedDocument):
    message_text = StringField()
    line_start = IntField(required=True)
    line_end = IntField()
    index = IntField()
    filepath = StringField()
    source_file = ReferenceField(SourceFile)
    source_function = ReferenceField(SourceFunction)


class Condition(Document): 
    condition_name = StringField(required=True) # The condition name, i.e INT32-C; for CWEs its just the number (e.g., 398)
    title = StringField() #required=True) 
    taxonomy = ReferenceField('Taxonomy') # Parent node
    platforms = ListField(StringField())
    languages = ListField(ReferenceField(CodeLanguage), default=[])
    condition_id = StringField() # Used to populate Stats database (statswork/scripts/db/ophelia2testDB.py)
    condition_fields = DictField() # Fields and values like {'remediation': 1}
    

class CheckerCondition(Document): # Checkers map to conditions
    checker = ReferenceField('Checker')
    conditions = ListField(ReferenceField(Condition)) # 'rules' from previous CheckerMapping table
    

class Taxonomy(Document):
    taxonomy_name = StringField(options=['cwe', 'cert'], required=True)
    taxonomy_version = StringField(default="generic") #required=True)
    conditions = ListField(ReferenceField(Condition))
    description = StringField()
    uploader_id = StringField(required=True)
    uploader_organization_id = StringField(required=True)
    author_source = StringField()


class CheckerMapping(Document):
    tool_id = StringField()
    description = StringField()
    mapper_identity = ListField(StringField()) # Vendor-public, SC-team, etc.
    mapping_source = StringField() # Origin of mapping data
    mapping_version = StringField()
    publishable_public_or_not = BooleanField(default=False)
    dod_publication = BooleanField(default=False)
    deprecated_or_not = BooleanField(default=False)
    license_information = StringField()
    additional_notes = StringField()
    filename = StringField()
    mappings = ListField(ReferenceField(CheckerCondition))
    mapping_date = DateTimeField()
    

class SpeculativeMapping(Document):
    tool_id = StringField()
    tool_name = StringField(required=True) # Field name in ophelia db
    checker_id = StringField(required=True)
    cwe_id = StringField(required=True)
    matches = IntField()


class Checker(Document):
    checker_name = StringField(required=True)
    tool = ReferenceField('Tool') 
    tool_name = StringField(required=True) #this field name is required by rapidclass_scripts/src/rclib/rclib/__init__.py REMOVE

    meta = { 
        'indexes': [
            'tool',
            ('tool')
        ]
    }
    

class Alert(Document):
    tool_id = StringField()
    code_language = ReferenceField(CodeLanguage)
    package_id = StringField(required=True) # Required to ensure the Alerts are associated with a package
    primary_message = EmbeddedDocumentField(Message)
    secondary_messages = EmbeddedDocumentListField(Message)
    verdict = DictField()  # Speculative mappings for a test suite. The verdict field will not be populated if the alert is not associated with a test suite.
    checker_id = StringField()


class TestSuite(Document):
    test_suite_name = StringField()
    test_suite_version = StringField()
    test_suite_type = StringField(options=['juliet', 'stonesoup'], required=True)
    sard_test_suite_id = StringField()
    manifest_files = ListField(StringField())
    code_languages = ListField(ReferenceField(CodeLanguage))
    manifest_urls = ListField(StringField()) # Safe URL field
    source_file_filenames = ListField(StringField()) # Names of sourcefile CSVs uploaded for this test suite
    source_function_filenames = ListField(StringField()) # Names of sourcefile CSVs uploaded for this test suite
    use_license_file = FileField()
    uploader_id = StringField(required=True)
    uploader_organization_id = StringField(required=True)
    author_source = StringField()


class Tool(Document):
    tool_name = StringField(required=True)
    category = StringField(options=['Metrics', 'FFSA'], required=True) #tool_type
    code_languages = ListField(ReferenceField(CodeLanguage))
    tool_output_file = FileField() #to be used in future updates
    tool_version = StringField(default="generic")
    tool_parser_name = StringField()
    language_platforms = ListField(StringField())
    checkers = ListField(ReferenceField(Checker))
    checker_mappings = ListField(ReferenceField(CheckerMapping))  # for FFSA tools
    code_metrics_headers = ListField()  # for metrics tools
    uploader_id = StringField(required=True)
    uploader_organization_id = StringField(required=True)
    author_source = StringField(default="No Author Source Provided")


class MetaAlert(Document):
    condition_id = StringField()
    checker_id = StringField(default=None) # Meta Alerts may use checkers instead of conditions 
    filepath = StringField()
    line_number = IntField()
    determination = EmbeddedDocumentField(Determination)
    alerts = ListField(ReferenceField(Alert), default=[]) #, unique_with='condition_id')
    auto_verdict = DictField()
    ct_pm_verdict = DictField()
    project_id = StringField(required=True) # Meta-alerts are per-project, required to ensure the meta-alerts are associated with a project
    timestamp = DateTimeField()
    
    def clean(self):
        if self.condition_id is None and self.checker_id is None:
            raise TypeError("`Checker_id` and `condition_id` must not be `None`")
            
        if self.checker_id is None and not re.match(r'^[a-f0-9]{24}$', str(self.condition_id)):
            raise TypeError("`Condition_id` is not a valid ID")
            
        if self.condition_id is None and not re.match(r'^[a-f0-9]{24}$', str(self.checker_id)):
            raise TypeError("`Checker_id` is not a valid ID")

        super(MetaAlert, self).clean()

    #Currently unique attribute is not working with ListField (it only uses one value from the list)
    #Uncomment when mongoengine becomes more stable in regards to uniqueness constraints
  #  meta = {
  #      'indexes': [
  #          { 'fields': ('condition_id', 'alerts'), 'unique': True }
  #      ]
  #  }


class Package(Document):
    package_name = StringField(required=True)
    package_description = StringField()
    code_languages = ListField(ReferenceField(CodeLanguage, unique=True))
    uploader_id = StringField(required=True)
    author_source = StringField()
    uploader_organization_id = StringField(required=True)
    source_files = ListField(ReferenceField(SourceFile))
    code_source_filename = StringField()
    source_code_url = StringField() #Should be URIField when implemented
    source_file_url = StringField()
    source_function_url = StringField()
    source_file_extensions = ListField(StringField(), default=[])
    on_hold = BooleanField(default=False)
    on_hold_data = ReferenceField('Package_On_Hold')
    alerts = ListField(ReferenceField(Alert))
    tools = ListField(ReferenceField(Tool))
    package_sharing_status = StringField(default="Global")  #field used to limit user access to the package
    test_suite = ReferenceField(TestSuite) 
    created_at = DateTimeField(required=True)
    updated_at = DateTimeField()
  
 
class Project(Document):
   project_name = StringField(required=True)
   project_description = StringField()
   uploader_id = StringField(required=True)
   author_source = StringField()
   uploader_organization_id = StringField(required=True)
   is_test_suite = BooleanField(default=False)
   adaptive_heuristic_is_active = BooleanField(default=False)
   publish_data_updates = BooleanField(default=False)
   use_checkers_on_meta_alerts = BooleanField(default=False)
   on_hold = BooleanField(default=False)
   on_hold_data = ReferenceField('Project_On_Hold')
   project_sharing_status = StringField(default="Global") #field used to limit user access to the project
   meta_alerts = ListField(ReferenceField(MetaAlert))
   package = ReferenceField(Package)
   taxonomies = ListField(ReferenceField(Taxonomy))
   created_at = DateTimeField(required=True)
   updated_at = DateTimeField()


class CrossTaxonomyTestSuiteMappings(Document):
    '''
    `Condition` constitutes our standard taxonomy of flaw types, but other such taxonomies exists,
    such as CERT rules or FFSA tool-specific taxonomies. This document states that a known flaw of type `condition`
    in a test suite file at `file-path` can also be described as an instance of some `related_condition`
    '''
    test_suite_types = ListField(StringField()) # Types of test suites associated with this mapping
    condition = ReferenceField(Condition)
    related_condition = ReferenceField(Condition)
    source_file = ReferenceField(SourceFile)


class PerformanceMetrics(Document):
    function_name = StringField(required=True)
    transaction_timestamp = DateTimeField(required=True)
    user_id = StringField(required=True)
    user_organization_id = StringField(required=True)
    request_id = StringField()
    elapsed_time = FloatField() #wall-clock time in fractional seconds
    cpu_time = FloatField() #in fractional seconds



class Ahpo(EmbeddedDocument):
    '''
    Automatic hyperparameter optimizer

    ahpo_id: a user-friendly ID to support selection in the GUI (and nowhere else)
    name: a brief description of the this Ahpo
    parameters: A dict of parameters
    docstring: A description the exact form that `parameters` should take and what each parameter means
    '''
    name = StringField()
    parameters = DictField()
    docstring = StringField()


class AdaptiveHeuristic(EmbeddedDocument):
    '''
    adaptive_heuristic_id: a user-friendly ID to support selection in the GUI (and nowhere else)
    name: a brief description of the this adaptive heuristic
    docstring: A description the exact form that `parameters` should take and what each parameter means
    '''
    name = StringField()
    parameters = DictField()
    docstring = StringField()
    binary = BinaryField() #for binarized adaptive heuristic object


class Classifier(Document):
    '''
    classifier_id: a user-friendly ID to support selection in the GUI (and nowhere else)
    '''
    classifier_type = StringField()
    ahpos = EmbeddedDocumentListField(Ahpo)
    adaptive_heuristics = EmbeddedDocumentListField(AdaptiveHeuristic)


class Observation(Document):
    project_id = StringField(required=True)
    line_number = IntField()
    filepath = StringField()
    filepath_extension = StringField()
    filepath_depth = IntField()
    label = IntField()
    condition_name = StringField()
    taxonomy_name = StringField()
    num_alerts_per_source_file = IntField()
    num_alerts_per_source_function = IntField()
    features = ListField(StringField())
    alert_features = DictField()
    classifier_confidence_value = FloatField()
    adaptive_heuristic_confidence_value = FloatField()
    reweighted_confidence_value = FloatField()
    timestamp = DateTimeField(required=True)


class ClassifierData(Document):
    project_id = StringField(required=True)
    num_features = IntField()
    feature_names = ListField(StringField())
    categorical_feature_names = ListField(StringField())
    alert_feature_names = ListField(StringField())
    #feature_types = ListField(StringField())


class ClassifierInstance(Document):
    '''
    All the stuff that defines a classifier instance

    classifier_instance_id: a user-friendly ID to support selection in the GUI (and nowhere else)
    classifier: Reference to a Classifier instance
    name: A user-defined name for this classifier instance
    author_id: the owner of this classifier instance
    author_organization_id: the owner's affliation
    binary: A file binary that stores the trained classifier
    training_project: The classifier will use all labeled meta alerts in all of the project's associated
        packages for training
    ran_on_project: Indicates all packages that this classifier was ever
        run on. The `run_classifier_by_project_id` method is responsible to update this least
        each time it runs is classifier.
    n_meta_alert_updates_since_training: (int) the `handle_updates` controller function
        increments this each time the meta_alert collection gets updated for any of the packages
        in `training_projects`. `rclib.stats.classify.train_classifier` in resets
        this to 0 after each training
    last_trained: (datetime) `rclib.stats.classify.train_classifier` generates this at
        the conclusion of training
    '''
    classifier = ReferenceField(Classifier)
    name = StringField()
    author_id = StringField(required=True)
    author_organization_id = StringField(required=True)
    use_semantic_features = BooleanField(default=False)
    # Associated projects -- train and run
    training_project_ids = ListField(StringField())
    ran_on_project_ids = ListField(StringField())
    # Storing the trained classifier
    binary = BinaryField() #for binarized classifier object
    # Settings related to update handling
    n_meta_alert_updates_since_training = IntField(default=0)
    num_meta_alert_threshold = IntField(default=100)
    last_trained = DateTimeField()
    adaptive_heuristic = EmbeddedDocumentField(AdaptiveHeuristic)
    ahpo = EmbeddedDocumentField(Ahpo)
    selected_features = ListField(StringField())
    alert_features = ListField(StringField())
    probabilities = ListField(FloatField())
    encoded_feature_columns = ListField(StringField())
    encoded_feature_order = ListField(StringField())
    use_pca = BooleanField(default=False)
    pca_binary = BinaryField() #for binarized PCA object
    adaptive_heuristic_is_active = BooleanField(default=False)
    feature_selection_category = StringField(default="intersection")
    num_labeled_meta_alerts_used_for_classifier_training = IntField()
    num_labeled_T_test_suite_used_for_classifier_training = IntField()
    num_labeled_F_test_suite_used_for_classifier_training = IntField() 
    num_labeled_T_manual_verdicts_used_for_classifier_training = IntField()
    num_labeled_F_manual_verdicts_used_for_classifier_training = IntField()
    num_code_metrics_tools_used_for_classifier_training = IntField()
    top_features_impacting_classifier = ListField(StringField())
    training_classifier_metrics = DictField()
    timestamp = DateTimeField(required=True)


class ClassifierPerformanceMetrics(Document):
    classifier_instance_id = StringField(required=True)
    transaction_timestamp = DateTimeField(required=True)
    num_labeled_meta_alerts_used_for_classifier_training = IntField()
    num_labeled_T_test_suite_used_for_classifier_training = IntField()
    num_labeled_F_test_suite_used_for_classifier_training = IntField() 
    num_labeled_T_manual_verdicts_used_for_classifier_training = IntField()
    num_labeled_F_manual_verdicts_used_for_classifier_training = IntField()
    num_code_metrics_tools_used_for_classifier_training = IntField()
    top_features_impacting_classifier = ListField(StringField())


