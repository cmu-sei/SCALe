# Client code for the SCAIFE DataHub Module
#
# This is the auto-generated client code for the SCAIFE DataHub module,
# which facilitates auditing static analysis meta-alerts using
# classifiers, optional adaptive heuristics, and meta-alert
# prioritization. SCAIFE enables jump-starting labeled datasets using
# test suites. It is intended to enable a wide range of users (with
# widely varying datasets, static analysis tools, machine learning
# expertise, and amount of labeled data) to benefit from using
# classifiers and sophisticated prioritization to automatically triage
# static analysis meta-alerts.
#
# Generated by: https://openapi-generator.tech
# OpenAPI Generator version: 5.0.1
#
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

# Common files
require_relative 'datahub/api_client'
require_relative 'datahub/api_error'
require_relative 'datahub/version'
require_relative 'datahub/configuration'

# Models
require_relative 'datahub/models/adaptive_heuristic_close_response'
require_relative 'datahub/models/alert_mappings'
require_relative 'datahub/models/alert_wid'
require_relative 'datahub/models/alert_wid_all_of'
require_relative 'datahub/models/alert_wui_id'
require_relative 'datahub/models/alert_wui_id_all_of'
require_relative 'datahub/models/base_alert'
require_relative 'datahub/models/base_meta_alert'
require_relative 'datahub/models/base_tool'
require_relative 'datahub/models/cascading_performance'
require_relative 'datahub/models/checker'
require_relative 'datahub/models/checker_condition'
require_relative 'datahub/models/checker_condition_map'
require_relative 'datahub/models/checker_condition_map_all_of'
require_relative 'datahub/models/checker_condition_wid'
require_relative 'datahub/models/checker_mappings'
require_relative 'datahub/models/checker_mappings_metadata'
require_relative 'datahub/models/classifier_package'
require_relative 'datahub/models/classifier_project'
require_relative 'datahub/models/classifier_projects_requested'
require_relative 'datahub/models/classifier_tool'
require_relative 'datahub/models/condition'
require_relative 'datahub/models/condition_heading'
require_relative 'datahub/models/condition_languages'
require_relative 'datahub/models/condition_response'
require_relative 'datahub/models/condition_response_all_of'
require_relative 'datahub/models/condition_response_wid'
require_relative 'datahub/models/condition_response_wid_all_of'
require_relative 'datahub/models/condition_response_w_tax_id'
require_relative 'datahub/models/condition_response_w_tax_id_all_of'
require_relative 'datahub/models/created_language'
require_relative 'datahub/models/created_package'
require_relative 'datahub/models/created_project'
require_relative 'datahub/models/created_taxonomy'
require_relative 'datahub/models/determination'
require_relative 'datahub/models/determination_dangerous_construct_list'
require_relative 'datahub/models/determination_dead_list'
require_relative 'datahub/models/determination_flag_list'
require_relative 'datahub/models/determination_ignored_list'
require_relative 'datahub/models/determination_inapplicable_environment_list'
require_relative 'datahub/models/determination_notes_list'
require_relative 'datahub/models/determination_verdict_list'
require_relative 'datahub/models/edit_package_metadata'
require_relative 'datahub/models/edit_project_metadata'
require_relative 'datahub/models/edit_taxonomy'
require_relative 'datahub/models/edit_tool_metadata'
require_relative 'datahub/models/edit_tool_metadata_outer'
require_relative 'datahub/models/edited_package'
require_relative 'datahub/models/edited_project'
require_relative 'datahub/models/experiment_config'
require_relative 'datahub/models/get_alerts_response'
require_relative 'datahub/models/get_tool_response'
require_relative 'datahub/models/language_metadata'
require_relative 'datahub/models/message'
require_relative 'datahub/models/meta_alert_determination'
require_relative 'datahub/models/meta_alert_mappings'
require_relative 'datahub/models/meta_alert_no_id'
require_relative 'datahub/models/meta_alert_no_id_all_of'
require_relative 'datahub/models/meta_alert_wid'
require_relative 'datahub/models/meta_alert_wid_all_of'
require_relative 'datahub/models/package'
require_relative 'datahub/models/package_heading'
require_relative 'datahub/models/package_metadata'
require_relative 'datahub/models/project'
require_relative 'datahub/models/project_heading'
require_relative 'datahub/models/project_heuristic_message'
require_relative 'datahub/models/project_metadata'
require_relative 'datahub/models/project_status'
require_relative 'datahub/models/projects_requested'
require_relative 'datahub/models/source_file'
require_relative 'datahub/models/source_function'
require_relative 'datahub/models/source_mappings'
require_relative 'datahub/models/source_mappings_classifier'
require_relative 'datahub/models/task_status'
require_relative 'datahub/models/taxonomy'
require_relative 'datahub/models/taxonomy_heading'
require_relative 'datahub/models/taxonomy_metadata'
require_relative 'datahub/models/test_suite_heading'
require_relative 'datahub/models/test_suite_metadata'
require_relative 'datahub/models/tool_heading'
require_relative 'datahub/models/tool_metadata'
require_relative 'datahub/models/tool_metadata_all_of'
require_relative 'datahub/models/tool_response'
require_relative 'datahub/models/tool_response_mapping'
require_relative 'datahub/models/tool_taxonomies_present'

# APIs
require_relative 'datahub/api/data_hub_server_api'
require_relative 'datahub/api/stats_to_data_hub_api'
require_relative 'datahub/api/task_status_api'
require_relative 'datahub/api/uito_data_hub_api'

module Scaife
module Api
module Datahub

  class << self
    # Customize default settings for the SDK using block.
    #   Scaife::Api::Datahub.configure do |config|
    #     config.username = "xxx"
    #     config.password = "xxx"
    #   end
    # If no block given, return the default Configuration object.
    def configure
      if block_given?
        yield(Configuration.default)
      else
        Configuration.default
      end
    end
  end

end
end
end
