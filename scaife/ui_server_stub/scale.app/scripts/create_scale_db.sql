-- <legal>
-- SCALe version r.6.7.0.0.A
-- 
-- Copyright 2021 Carnegie Mellon University.
-- 
-- NO WARRANTY. THIS CARNEGIE MELLON UNIVERSITY AND SOFTWARE ENGINEERING
-- INSTITUTE MATERIAL IS FURNISHED ON AN "AS-IS" BASIS. CARNEGIE MELLON
-- UNIVERSITY MAKES NO WARRANTIES OF ANY KIND, EITHER EXPRESSED OR
-- IMPLIED, AS TO ANY MATTER INCLUDING, BUT NOT LIMITED TO, WARRANTY OF
-- FITNESS FOR PURPOSE OR MERCHANTABILITY, EXCLUSIVITY, OR RESULTS
-- OBTAINED FROM USE OF THE MATERIAL. CARNEGIE MELLON UNIVERSITY DOES NOT
-- MAKE ANY WARRANTY OF ANY KIND WITH RESPECT TO FREEDOM FROM PATENT,
-- TRADEMARK, OR COPYRIGHT INFRINGEMENT.
-- 
-- Released under a MIT (SEI)-style license, please see COPYRIGHT file or
-- contact permission@sei.cmu.edu for full terms.
-- 
-- [DISTRIBUTION STATEMENT A] This material has been approved for public
-- release and unlimited distribution.  Please see Copyright notice for
-- non-US Government use and distribution.
-- 
-- DM19-1274
-- </legal>

CREATE TABLE Projects (
  id INTEGER PRIMARY KEY,
  name VARCHAR,
  description TEXT,
  created_at DATETIME,
  updated_at DATETIME,
  version VARCHAR,
  last_used_confidence_scheme INTEGER,
  last_used_priority_scheme INTEGER,
  current_classifier_scheme INTEGER,
  source_file VARCHAR,
  source_url VARCHAR,
  test_suite_name VARCHAR,
  test_suite_version VARCHAR,
  test_suite_type VARCHAR,
  test_suite_sard_id VARCHAR,
  author_source VARCHAR,
  manifest_file VARCHAR,
  manifest_url VARCHAR,
  function_info_file VARCHAR,
  file_info_file VARCHAR,
  license_file VARCHAR,
  project_data_source VARCHAR,
  scaife_uploaded_on DATETIME,
  publish_data_updates BOOLEAN,
  subscribe_to_data_updates BOOLEAN,
  data_subscription_id VARCHAR,
  scaife_test_suite_id VARCHAR,
  scaife_package_id VARCHAR,
  scaife_project_id VARCHAR,
  ci_enabled BOOLEAN,
  meta_alert_counts_type VARCHAR,
  confidence_threshold REAL,
  git_url VARCHAR,
  git_user VARCHAR,
  git_access_token VARCHAR,
  git_hash VARCHAR,
  efp_confidence_threshold REAL
);
INSERT INTO Projects (id, name, description, created_at, updated_at, version, last_used_confidence_scheme, last_used_priority_scheme, current_classifier_scheme) VALUES(0, 'new project', '', DATETIME('now'), DATETIME('now'), 'SCALe_research_db_6', -1, -1, -1);
-- Note that all these fields are placeholders, they are only useful for projects exported from the web app.
CREATE TABLE Messages (
  id INTEGER PRIMARY KEY,
  project_id INTEGER,
  alert_id INTEGER,
  path TEXT,
  line INTEGER,
  link VARCHAR,
  message TEXT
);
CREATE TABLE Alerts (
  id INTEGER PRIMARY KEY,
  checker_id INTEGER,
  primary_msg INTEGER,
  scaife_alert_id VARCHAR
);
CREATE TABLE Checkers (
  id INTEGER PRIMARY KEY,
  name TEXT,
  tool_id INTEGER,
  regex BOOLEAN,
  scaife_checker_id VARCHAR
  );
CREATE TABLE ExtraSourceContext(
  message INTEGER,
  func TEXT,
  class TEXT,
  namespace TEXT,
  lineend INTEGER,
  colstart INTEGER,
  colend INTEGER
);
CREATE TABLE ExtraFeatures(
  message INTEGER,
  name TEXT,
  value TEXT
);
CREATE TABLE Taxonomies (
  id INTEGER PRIMARY KEY,
  name TEXT,
  version_string VARCHAR,
  version_number FLOAT,
  type VARCHAR,
  author_source VARCHAR,
  user_id VARCHAR,
  user_org_id VARCHAR,
  format VARCHAR,
  scaife_tax_id VARCHAR
);
CREATE TABLE Conditions (
  id INTEGER PRIMARY KEY,
  taxonomy_id INTEGER,
  name VARCHAR,
  title VARCHAR,
  formatted_data VARCHAR,
  scaife_cond_id VARCHAR
);
CREATE TABLE ConditionCheckerLinks (
  condition_id INTEGER KEY,
  checker_id INTEGER KEY,
  UNIQUE (condition_id, checker_id)
);
CREATE TABLE MetaAlerts (
  id INTEGER PRIMARY KEY,
  condition_id INTEGER,
  class_label VARCHAR,
  confidence_score REAL,
  priority_score INTEGER,
  scaife_meta_alert_id VARCHAR,
  code_language VARCHAR
);
CREATE TABLE MetaAlertLinks (
  alert_id INTEGER KEY,
  meta_alert_id INTEGER KEY,
  UNIQUE (alert_id, meta_alert_id)
);
CREATE TABLE Users (
  id INTEGER PRIMARY KEY,
  first_name VARCHAR,
  last_name VARCHAR,
  organization VARCHAR,
  name VARCHAR,
  password_digest VARCHAR,
  created_at DATETIME
);
CREATE TABLE Determinations (
  id INTEGER PRIMARY KEY,
  project_id INTEGER,
  meta_alert_id INTEGER,
  time DATETIME,
  verdict TINYINT,
  flag BOOLEAN,
  notes TEXT,
  ignored BOOLEAN,
  dead BOOLEAN,
  inapplicable_environment BOOLEAN,
  dangerous_construct INTEGER,
  user_id INTEGER
);
CREATE TABLE PrioritySchemes (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) UNIQUE,
  project_id INTEGER,
  formula TEXT,
  weighted_columns TEXT,
  confidence INTEGER,
  created_at DATETIME,
  updated_at DATETIME,
  cert_severity INTEGER,
  cert_likelihood INTEGER,
  cert_remediation INTEGER,
  cert_priority INTEGER,
  cert_level INTEGER,
  cwe_likelihood INTEGER,
  scaife_p_scheme_id VARCHAR,
  p_scheme_type VARCHAR
);
CREATE TABLE UserUploads (
  id INTEGER PRIMARY KEY,
  meta_alert_id INTEGER,
  user_columns TEXT,
  created_at DATETIME,
  updated_at DATETIME
);
CREATE TABLE ClassifierSchemes (
  id INTEGER PRIMARY KEY,
  classifier_instance_name VARCHAR(255),
  classifier_type VARCHAR(255),
  source_domain TEXT,
  created_at DATETIME,
  updated_at DATETIME,
  adaptive_heuristic_name TEXT,
  adaptive_heuristic_parameters TEXT,
  ahpo_name TEXT,
  ahpo_parameters TEXT,
  use_pca BOOLEAN,
  feature_category TEXT,
  semantic_features BOOLEAN,
  num_meta_alert_threshold INTEGER,
  scaife_classifier_instance_id VARCHAR
);
CREATE TABLE PerformanceMetrics (
  id INTEGER PRIMARY KEY,
  scaife_mode VARCHAR(255),
  function_name VARCHAR,
  metric_description TEXT,
  transaction_timestamp DATETIME,
  user_id VARCHAR,
  user_organization_id VARCHAR,
  project_id INTEGER,
  elapsed_time REAL,
  cpu_time REAL
);
CREATE TABLE ClassifierMetrics (
  id INTEGER PRIMARY KEY,
  project_id INTEGER,
  scaife_classifier_instance_id VARCHAR,
  transaction_timestamp DATETIME,
  num_labeled_meta_alerts_used_for_classifier_evaluation INTEGER,
  train_accuracy REAL,
  train_precision REAL,
  train_recall REAL,
  train_f1 REAL,
  test_accuracy REAL,
  test_precision REAL,
  test_recall REAL,
  test_f1 REAL,
  num_labeled_meta_alerts_used_for_classifier_training INTEGER,
  num_labeled_T_test_suite_used_for_classifier_training INTEGER,
  num_labeled_F_test_suite_used_for_classifier_training INTEGER,
  num_labeled_T_manual_verdicts_used_for_classifier_training INTEGER,
  num_labeled_F_manual_verdicts_used_for_classifier_training INTEGER,
  num_code_metrics_tools_used_for_classifier_training INTEGER,
  top_features_impacting_classifier TEXT
);
CREATE TABLE Tools (
  id INTEGER PRIMARY KEY,
  name VARCHAR,
  platform VARCHAR,
  version VARCHAR,
  label VARCHAR,
  scaife_tool_id VARCHAR,
  UNIQUE (name, platform, version)
);
CREATE TABLE Languages (
  id INTEGER PRIMARY KEY,
  name VARCHAR,
  platform VARCHAR,
  version VARCHAR,
  scaife_language_id VARCHAR,
  UNIQUE (name, version)
);
CREATE TABLE ProjectTools (
  project_id INTEGER,
  tool_id INTEGER,
  UNIQUE(project_id, tool_id)
);
CREATE TABLE ProjectLanguages (
  project_id INTEGER,
  language_id INTEGER,
  UNIQUE(project_id, language_id)
);
CREATE TABLE ProjectTaxonomies (
  project_id INTEGER,
  taxonomy_id INTEGER,
  UNIQUE(project_id, taxonomy_id)
);
CREATE TABLE AuditStatusLog (
  determination_id INTEGER PRIMARY KEY,
  project_id INTEGER,
  sort_keys VARCHAR,
  filter_selected_id_type VARCHAR,
  filter_id VARCHAR,
  filter_meta_alert_id VARCHAR,
  filter_display_ids VARCHAR,
  filter_verdict VARCHAR,
  filter_previous VARCHAR,
  filter_path VARCHAR,
  filter_line VARCHAR,
  filter_checker VARCHAR,
  filter_condition VARCHAR,
  filter_tool VARCHAR,
  filter_taxonomy VARCHAR,
  filter_category VARCHAR,
  seed VARCHAR,
  alertConditionsPerPage INTEGER,
  fused BOOLEAN,
  scaife_mode VARCHAR,
  classifier_chosen VARCHAR,
  predicted_verdicts INTEGER,
  etp_confidence_threshold REAL,
  efp_confidence_threshold REAL,
  top_meta_alert INTEGER
);
