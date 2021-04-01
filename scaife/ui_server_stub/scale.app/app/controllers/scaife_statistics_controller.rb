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

require 'scaife/api/statistics'
require 'scaife/api/registration'

class ScaifeStatisticsController < ScaifeController

=begin
  User selects "Classifiers" -> "Create New Classifier" from header
=end
  def listClassifiers(login_token)
    @scaife_response = @scaife_status_code = nil
    @errors = []
    begin
      with_scaife_stats_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Statistics::UIToStatsApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.list_classifiers_with_http_info(access_token)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Statistics::ApiError => e
          @scaife_status_code = e.code
          if [400, 401, 403].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToStatsApi->list_classifiers: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def deleteClassifier(login_token, ci_id)
    @scaife_response = @scaife_status_code = nil
    @errors = []
    begin
      with_scaife_stats_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Statistics::UIToStatsApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.delete_classifier_with_http_info(access_token, ci_id)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Statistics::ApiError => e
          @scaife_status_code = e.code
          if [400, 401, 403, 404].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToStatsApi->delete_classifiers: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def createClassifier(login_token, c_id, c_type, ci_name, p_ids, ahpo_name, ahpo_params, ah_name, ah_params, use_pca, feature_category, semantic_features, num_meta_alert_threshold)
    @scaife_response = @scaife_status_code = nil
    @errors = []
    begin
      with_scaife_stats_access(login_token) do |access_token|
        begin
          data = self.symbolize_data({
            classifier_id: c_id,
            classifier_type: c_type,
            classifier_instance_name: ci_name,
            project_ids: p_ids,
            ahpo_name: ahpo_name,
            ahpo_parameters: ahpo_params,
            adaptive_heuristic_name: ah_name,
            adaptive_heuristic_parameters: ah_params,
            use_pca: use_pca,
            feature_selection_category: feature_category,
            use_semantic_features: semantic_features,
            num_meta_alert_threshold: num_meta_alert_threshold.to_i
          })
          data = Scaife::Api::Statistics::ClassifierInstance.build_from_hash(data)
          api = Scaife::Api::Statistics::UIToStatsApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.create_classifier_instance_with_http_info(access_token, data)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Statistics::ApiError => e
          @scaife_status_code = e.code
          if [400, 401, 403, 404, 422, 501].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToStatsApi->create_classifier_instance: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end


  def editClassifier(login_token, ci_id, c_id, c_type, ci_name, p_ids, ahpo_name, ahpo_params, ah_name, ah_params, use_pca, feature_category, semantic_features, num_meta_alert_threshold)
    @scaife_response = @scaife_status_code = nil
    @errors = []
    begin
      with_scaife_stats_access(login_token) do |access_token|
        begin
          data = self.symbolize_data({
            classifer_instance_id: ci_id,
            classifier_id: c_id,
            classifier_type: c_type,
            classifier_instance_name: ci_name,
            project_ids: p_ids,
            ahpo_name: ahpo_name,
            ahpo_parameters: ahpo_params,
            adaptive_heuristic_name: ah_name,
            adaptive_heuristic_parameters: ah_params,
            use_pca: use_pca,
            feature_selection_category: feature_category,
            use_semantic_features: semantic_features,
            num_meta_alert_threshold: num_meta_alert_threshold.to_i
          })
          data = Scaife::Api::Statistics::ClassifierInstance.build_from_hash(data)
          api = Scaife::Api::Statistics::UIToStatsApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.create_classifier_instance_with_http_info(access_token, data)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Statistics::ApiError => e
          @scaife_status_code = e.code
          if [400, 401, 403, 404, 422, 501].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToStatsApi->edit_classifier_instance: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def runClassifier(login_token, ci_id, p_id)
    @scaife_response = @scaife_status_code = nil
    @errors = []
    begin
      with_scaife_stats_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Statistics::UIToStatsApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.run_classifier_instance_with_http_info(access_token, ci_id, p_id)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Statistics::ApiError => e
          @scaife_status_code = e.code
          if [400, 401, 403, 404, 501].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToStatsApi->run_classifier_instance: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

end
