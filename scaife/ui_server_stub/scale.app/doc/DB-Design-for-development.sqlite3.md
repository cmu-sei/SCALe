---
title: 'SCALe : DB Design for development.sqlite3'
---

[SCALe](index.md) / [Source Code Analysis Lab (SCALe)](Welcome.md)
<!-- <legal> -->
<!-- SCALe version r.6.7.0.0.A -->
<!--  -->
<!-- Copyright 2021 Carnegie Mellon University. -->
<!--  -->
<!-- NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING -->
<!-- INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON -->
<!-- UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR -->
<!-- IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF -->
<!-- FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS -->
<!-- OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT -->
<!-- MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT, -->
<!-- TRADEMARK, OR COPYRIGHT INFRINGEMENT. -->
<!--  -->
<!-- Released under a MIT (SEI)-style license, please see COPYRIGHT file or -->
<!-- contact permission@sei.cmu.edu for full terms. -->
<!--  -->
<!-- [DISTRIBUTION STATEMENT A] This material has been approved for public -->
<!-- release and unlimited distribution.  Please see Copyright notice for -->
<!-- non-US Government use and distribution. -->
<!--  -->
<!-- DM19-1274 -->
<!-- </legal> -->

SCALe : DB Design for development.sqlite3
==========================================

The database location is:
`$SCALE_HOME/scale.app/db/development.sqlite3 `

Updates to development.sqlite3 happen when the user:

-   creates a new project
-   creates a project from database
-   changes a verdict or flag
-   creates a new alert
-   “set all selected” (mass update verdict and flag)
-   edits a project (updates a project)
-   destroys a project

For the minnow branch of scale.app, tables in development.sqlite3 are
detailed below.

## Tables

### displays

There is one `displays` table '`id`' entry for each unique
"alertCondition". An alertCondition holds information about a single
alert *with* information about only one of the conditions its checker
maps to.

Each `displays.id` entry is for a unique combination of a single alert
(`displays.alert_id`) and one of the conditions its checker maps to
(that condition ID can be looked up using the
`displays.meta_alert_id `field). If that alert's checker maps to
multiple conditions, there will be a separate entry (`displays.id`) for
each of the conditions it maps to.

There can be multiple `displays` table entries with the same
`displays.meta_alert_id`, because each alertCondition within a meta-alert's fused
alertConditions has a separate `displays.id` table entry). A meta-alert is
identified by at minimum a 3-tuple: filepath, line number, code flaw condition but
we are moving to identifying it with a 4-tuple: filepath, line number, code flaw condition, and unique message and/or
unique set of secondary messages.

| column_name | type | notes |
|---|:---:|---------------------------|
| id | INTEGER | The primary key on the table entry (values start at 1 and are incremented by 1 for each new alertCondition).  There is one `displays` table '`id`' entry for each unique "alertCondition". An alertCondition holds information about a single alert *with* information about only one of the conditions its checker maps to. Each `displays.id` entry is for a unique combination of a single alert (`displays.alert_id`) and one of the conditions its checker maps to (that condition ID can be looked up using the `displays.meta_alert_id `field). If that alert's checker maps to multiple conditions, there will be a separate entry (`displays.id`) for each of the conditions it maps to. There can be multiple `displays` table entries with the same `displays.meta_alert_id`, because each alert within a meta-alert's fused alertCondition has a separate `displays.id` table entry). A meta-alert is identified by a 3-tuple: filepath, line number, code flaw condition. |
| flag | BOOLEAN | This contains the latest value (from the Determinations table) |
| verdict | INTEGER | This contains the latest value (from the Determinations table) |
| previous | INTEGER | Previously unused, this indicates how many verdicts exist besides the current one. If &gt; 1, it brings up the Determinations display (see below) |
| path | VARCHAR(255) | |
| line | INTEGER | |
| link | VARCHAR(255) | |
| message | VARCHAR(255) | |
| checker | VARCHAR(255) | |
| tool_name | VARCHAR(255) | |
| condition | VARCHAR(255) | |
| title | VARCHAR(255) | |
| severity | INTEGER | This is CERT coding rule field "severity". |
| likelihood | INTEGER | This is CERT coding rule field "likelihood". |
| remediation | INTEGER | This is CERT coding rule field "remediation". |
| priority | INTEGER | This is CERT coding rule field "priority". |
| level | INTEGER | This is CERT coding rule field "level". |
| cwe_likelihood | VARCHAR(255) | This is CWE field "likelihood", which means a different thing than the CERT coding rule's field "likelihood". |
| notes | VARCHAR(255) | This contains the latest value (from the Determinations table) |
| ignored | BOOLEAN | This contains the latest value (from the Determinations table) |
| dead | BOOLEAN | This contains the latest value (from the Determinations table) |
| inapplicable_environment | BOOLEAN | This contains the latest value (from the Determinations table) |
| dangerous_construct | INTEGER | This contains the latest value (from the Determinations table) |
| class_label | VARCHAR(255) | This is really the **meta-alert label (which comes from a classifier (or an emulator of a classifier)),** not a per-alert label. |
| confidence | DECIMAL | This is really the **meta-alert confidence (which comes from a classifier (or an emulator of a classifier)),** not a per-alert confidence. |
| meta_alert_priority | INTEGER | This is really the **meta-alert priority,** not a per-alert priority. |
| project_id | INTEGER | |
| meta_alert_id | INTEGER | Meta-alert id (in the external.sqlite3 DB). |
| alert_id | INTEGER | Alert id (in the external.sqlite3 DB). |
| scaife_alert_id | VARCHAR(255) | |
| scaife_meta_alert_id | VARCHAR(255) | |
| taxonomy_id | INTEGER | |
| taxonomy_name | VARCHAR(255) | |
| taxonomy_version | VARCHAR(255) | |
| tool_id | INTEGER | |
| tool_version | VARCHAR(255) | |
| code_language | VARCHAR(255) | |

The Determinations table is browse-able, but cannot be edited directly
via the GUI. The most recent determination will also appear in the
Displays table.

### determinations
| column_name | type | notes |
|---|:---:|---|
| id | INTEGER | Starts at 0, increments by 1. |
| project_id | INTEGER | |
| meta_alert_id | INTEGER | |
| time | DATETIME | |
| verdict | TINYINT | |
| flag | BOOLEAN | |
| notes | TEXT | |
| ignored | BOOLEAN | |
| dead | BOOLEAN | |
| inapplicable_environment | BOOLEAN | |
| dangerous_construct | INTEGER | |

### messages
| column_name | type |
|---|:---:|
| id | INTEGER |
| project_id | INTEGER |
| alert_id | INTEGER |
| path | VARCHAR(255) |
| line | INTEGER |
| link | VARCHAR(255) |
| message | VARCHAR(255) |

### projects

| column_name | type | notes |
|---|:---:|---------------------------|
| id | INTEGER | |
| name | VARCHAR(255) | |
| description | TEXT | |
| created_at | DATETIME | |
| updated_at | DATETIME | |
| version | VARCHAR | |
| last\_used\_confidence\_scheme | INTEGER | The id of the last classifier scheme that stored a confidence score in the displays table |
| last\_used\_priority\_scheme | INTEGER | The id of the last priority scheme that stored a priority score in the displays table |
| current_classifier_scheme | VARCHAR(255) | The last-trained classifier name, which is not necessarily the last\_used\_confidence\_scheme. |
| source_file | VARCHAR(255) | The filename of the source code archive if one was uploaded
| source_url | VARCHAR(255) | The URL of the source code archive if one was used to download it
| test_suite_name | VARCHAR(255) | Test suite name if this project is a test suite
| test_suite_version | VARCHAR(255) | Test suite version if applicable
| test_suite_type | VARCHAR(255) | Test suite type (i.e., juliet, stonesoup)
| test_suite_sard_id | VARCHAR(255) | Test suite NIST SARD test suite version if available
| author_source | VARCHAR(255) | Name of the author/org of this test suite
| manifest_file | VARCHAR(255) | Manifest filename if one was used for this test suite
| manifest_url | VARCHAR(255) | Manifest URL if one was used to download the manifest for this test suite
| function_info_file | VARCHAR(255) | Function information file if one was used for this test suite
| file_info_file | VARCHAR(255) | File information file if one was used for this test suite
| license_file | VARCHAR(255) | Terms under which this test suite is licensed
| scaife_test_suite_id | VARCHAR(255) | |
| scaife_package_id | VARCHAR(255) | |
| scaife_project_id | VARCHAR(255) | |

### schema_migrations
| column_name | type | notes |
|---|:---:|---|
| version | VARCHAR(255) | |

changes in the rc_317 branch of SCALe:

### priority_schemes

| column_name | type | notes |
|---|:---:|---------------------------|
| id | INTEGER | |
| name | VARCHAR(255) | |
| formula | TEXT | |
| project_id | INTEGER  | |
| created_at | DATETIME | |
| updated_at | DATETIME | |
| cert_severity | INTEGER | |
| cert_likelihood | INTEGER | |
| cert_remediation | INTEGER  | |
| cert_priority | INTEGER  | |
| cert_level | INTEGER  | |
| cwe_likelihood | INTEGER  | |
| confidence | INTEGER | |
| weighted_columns** | TEXT | **Field names vary and are dynamically updated based on user input. |
| scaife_p_scheme_id | VARCHAR(255) | priority scheme id from SCAIFE |
| p_scheme_type | VARCHAR(255) | priority scheme save type for SCAIFE |

### classifier_schemes
| column_name | type | notes |
|---|:---:|---------------------------|
| id | INTEGER | |
| classifier_instance_name | VARCHAR(255) | |
| classifier_type | VARCHAR(255) | Type of classifier being trained (Logistic Regression, XGBoost, etc.) |
| source_domain | TEXT | This is the list of projects used to create the classifier. |
| feature_category | TEXT | Determines whether to (a) select classifier features only if they are available in all projects' data (intersection), or (b) select all available features (union).  Note that Option (b) may degrade classifier peformance. |
| semantic_features | BOOLEAN | Determines whether to consider semantic features when training the classifier. |
| use_pca | BOOLEAN | Determines whether to apply principal component analysis (PCA) when training and running the classifier. |
| created_at | DATETIME | |
| updated_at | DATETIME | |
| adaptive_heuristic_name | TEXT | name field of the adaptive_heuristic represented by the title of tabs in the classifier schemes modal in the adaptive heuristics section. |
|  adaptive_heuristic_parameters** | TEXT |  **Field names vary and are dynamically updated based on user input. These are the parameters for the adaptive_heuristic (They vary depending on the type of adaptive_heuristic). |
| ahpo_name | TEXT  | Automated Hyper-Parameter Optimization. name field represented by the AHPO selected from the dropdown in the classifier schemes model in the AHPO section. There will be options, but none implemented yet. |
|  ahpo_parameters** | TEXT |  **Field names vary and are dynamically updated based on user input. These are the parameters for the ahpo (They vary depending on the type of ahpo). |
| num_meta_alert_threshold | INTEGER | Specifies the number of new meta-alerts received before retraining the classifier. |
| scaife_classifier_instance_id | VARCHAR(255) | classifier scheme instance id from SCAIFE |

### user_uploads

| column_name | type | notes |
|---|:---:|---|
| id | INTEGER | |
| meta\_alert\_id | INTEGER | |
| user_columns | TEXT | JSON formatted |
| created_at | DATETIME | |
| updated_at | DATETIME | |

NOTE: data only populated if user uploads CSV with appropriate data

### taxonomies

| column_name | type | notes |
|---|:---:|---|
| id | INTEGER | |
| name | VARCHAR(255) | e.g. 'CWEs' |
| version_string | VARCHAR(255) | |
| version_number | FLOAT | For ordinality |
| type |  VARCHAR(255) | Used for finding filenames on the system |
| author_source | VARCHAR(255) | e.g. 'SEI' |
| user_id | VARCHAR(255) | User ID that uploaded this taxonomy |
| user_org_id | VARCHAR(255) | Organization name of the user that uploaded this taxonomy |
| format | VARCHAR(255) | JSON list of additional field names |
| scaife_tax_id | VARCHAR(255) | |

### conditions

| column_name | type | notes |
|---|:---:|---|
| id | INTEGER | |
| taxonomy_id | INTEGER | The taxonomy to which this condition belongs to |
| name | VARCHAR(255) | |
| title | VARCHAR(255) | |
| formatted_data | VARCHAR(255) | JSON encoded list of additional field values |
| scaife_cond_id | VARCHAR(255) | |

### tools

| column_name | type | notes |
|---|:---:|---|
| id | INTEGER | |
| name | VARCHAR(255) | e.g. 'rosecheckers' |
| platform | VARCHAR(255) | e.g. 'cpp' for C++ |
| version | VARCHAR(255) | |
| label | VARCHAR(255) | full name of tool, e.g. 'CERT RoseCheckers' |
| scaife_tool_id | VARCHAR(255) | |

### languages

| column_name | type | notes |
|---|:---:|---|
| id | INTEGER | |
| name | VARCHAR(255) | e.g. 'C++' |
| platform | VARCHAR(255) | e.g. 'cpp' for C++ |
| version | VARCHAR(255) | |
| scaife_language_id | VARCHAR(255) | |

### project_tools

| column_name | type | notes |
|---|:---:|---|
| project_id | INTEGER | |
| tool_id | INTEGER | |

### project_taxonomies

| column_name | type | notes |
|---|:---:|---|
| project_id | INTEGER | |
| taxonomy_id | INTEGER | |

### project_languages

| column_name | type | notes |
|---|:---:|---|
| project_id | INTEGER | |
| language_id | INTEGER | |

-   create new project
-   create project from database
-   change notes, flag, supplemental tag, verdict
-   create a new alert
-   “set all selected” (mass update verdict and flag)
-   edit project (update project)
-   destroy project

### performance_metrics

| column_name | type | notes |
|---|:---:|---------------------------|
| scaife_mode | VARCHAR(255) | The mode SCALe is being used in when the metric was collected (i.e., "Demo", "Scale-only", or "SCAIFE-connected")|
| function_name | VARCHAR(255) | The function whose performance is being measured |
| metric_description | TEXT | Contains more information about an individual performance metric |
| transaction_timestamp | DATETIME | When the metric was collected |
| user_id | VARCHAR(255) | |
| user_organization_id | VARCHAR(255) | |
| project_id | INTEGER | |
| elapsed_time | DECIMAL | The actual time taken for the transaction to complete (i.e., the wall-clock time) |
| cpu_time | DECIMAL  | The exact amount of time that the CPU spent processing data for the transaction |

### classifier_metrics

| column_name | type | notes |
|---|:---:|---------------------------|
| project_id | INTEGER | |
| scaife_classifier_instance_id | VARCHAR(255) | classifier scheme instance id from SCAIFE |
| transaction_timestamp | DATETIME | When the metric was collected |
| num_labeled_meta_alerts_used_for_classifier_evaluation | INTEGER  | For example, with a total labeled dataset of 100 meta-alerts, if 70 of them were used to train the classifier, then there would be 30 labeled meta-alerts used for classifier evaluation. These labeled meta-alerts come from the dataset the classifier is run on, which may or may not be the dataset used to create the classifier.  This dataset typically does not include any labeled data received since classifier creation. |
| train_accuracy | DECIMAL | The fraction of correct predictions made by the classifier on the training data set |
| train_precision | DECIMAL | The proportion of positive identifications that were actually correct on the training data set |
| train_recall | DECIMAL | The proportion of true positives that were correctly identified  in the training data set |
| train_f1 | DECIMAL | An overall measure of a classifier’s accuracy on the training data set that combines precision and recall |
| test_accuracy | DECIMAL | The fraction of correct predictions made by the classifier on the test data set |
| test_precision | DECIMAL | The proportion of positive identifications that were actually correct on the test data set |
| test_recall | DECIMAL | The proportion of true positives that were correctly identified in the test data set |
| test_f1 | DECIMAL | An overall measure of a classifier’s accuracy on the test data set that combines precision and recall |
| num_labeled_meta_alerts_used_for_classifier_training | INTEGER | |
| num_labeled_T_test_suite_used_for_classifier_training | INTEGER | |
| num_labeled_F_test_suite_used_for_classifier_training | INTEGER | |
| num_labeled_T_manual_verdicts_used_for_classifier_training | INTEGER | |
| num_labeled_F_manual_verdicts_used_for_classifier_training | INTEGER | |
| num_code_metrics_tools_used_for_classifier_training | INTEGER | |
| top_features_impacting_classifier | TEXT | |

------------------------------------------------------------------------

[![](attachments/arrow_left.png)](Exported-Database-Design.md)
[![](attachments/arrow_up.png)](Welcome.md)
[![](attachments/arrow_right.png)](DB-Design-for-per-project-SQLite-files-in-backup.md)

Attachments:
------------

![](images/icons/bullet_blue.gif)
[SQLiteDB_Architecture.png](attachments/SQLiteDB_Architecture.png)
(image/png)
