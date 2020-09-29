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

require 'scaife/api/statistics'
require 'scaife/api/registration'

class ScaifeStatisticsController < ApplicationController
  include Scaife::Api::Statistics
  include Scaife::Api::Registration

=begin
  User selects "Classifiers" -> "Create New Classifier" from header
=end
  def listClassifiers(login_token)
    @response = nil
    @errors = []
    begin
      with_scaife_statistics_access(login_token) do |access_token, request_token|
        st_response = SCAIFE_list_classifiers(access_token, request_token)
        #puts "Statistics server response:"
        #puts st_response
        body = JSON.parse(st_response.body)
        if st_response.code == 200
          @response = body
        elsif st_response.code == 404
          # note: classifiers are pre-loaded, so this is a failure
          # if it happens
          puts "Statistics: no classifiers available"
        elsif [400, 401, 403].include? st_response.code
          # 400 Invalid Request
          # 401 Invalid Token Request
          # 403 Missing Required Tokens
          puts "Stats: (defined) server response #{st_response.code}: #{body['message']}"
          @response = body
          @errors << body
        else
          # Unexpected Error
          puts "Stats: (undefined) server response #{st_response.code}: #body['message']body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = st_response.body
      @errors << @response
    end
    return @response
  end

  def deleteClassifier(login_token, ci_id)
    @response = nil
    @errors = []
    begin
      with_scaife_statistics_access(login_token) do |access_token, request_token|
        st_response = SCAIFE_delete_classifier(access_token, request_token, ci_id)
        #puts "Statistics server response:"
        #puts st_response
        body = JSON.parse(st_response.body)
        if st_response.code == 200
          @response = body
        elsif [400, 401, 403, 404].include? st_response.code
          # 400 Invalid Request
          # 401 Invalid Token Request
          # 403 Missing Required Tokens
          # 404 Unable to Delete Classifier
          puts "Stats: (defined) server response #{st_response.code}: #{body}"
          @response = body
          @errors << body
        else
          # Unexpected Error
          puts "Stats: (undefined) server response #{st_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = st_response.body
      @errors << @response
    end
    return @response
  end

  def createClassifier(login_token, c_id, c_type, ci_name, p_ids, ahpo_name, ahpo_params, ah_name, ah_params)
    @response = nil
    @errors = []
    begin
      with_scaife_statistics_access(login_token) do |access_token, request_token|
        st_response = SCAIFE_create_classifier(access_token, request_token, c_id, c_type, ci_name, p_ids, ahpo_name, ahpo_params, ah_name, ah_params)
        #puts "Statistics server response:"
        #puts st_response
        body = JSON.parse(st_response.body)
        if st_response.code == 200
          @response = body
        elsif [400, 401, 403, 404, 422, 501].include? st_response.code
          # 400 Unable to Create Classifier
          # 401 Invalid Token Request
          # 403 Missing Required Tokens
          # 404 Required Resources Not Found
          # 422 Data Lacks Verdicts Labeled 'True' and 'False'
          # 501 Error Retrieving DataHub Information
          puts "Stats: (defined) server response #{st_response.code}: #{body}"
          @response = body
          @errors << body
        else
          # Unexpected Error
          puts "Stats: (undefined) server response #{st_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = st_response.body
      @errors << @response
    end
    return @response
  end

  def editClassifier(login_token, ci_id, c_id, c_type, ci_name, p_ids, ahpo_name, ahpo_params, ah_name, ah_params)
    @response = nil
    @errors = []
    begin
      with_scaife_statistics_access(login_token) do |access_token, request_token|
        st_response = SCAIFE_edit_classifier(access_token, request_token, ci_id, c_id, c_type, ci_name, p_ids, ahpo_name, ahpo_params, ah_name, ah_params)
        #puts "Statistics server response:"
        #puts st_response
        body = JSON.parse(st_response.body)
        if st_response.code == 200
          @response = body
        elsif [400, 401, 403, 404, 422, 501].include? st_response.code
          # 400 Unable to Edit Classifier
          # 401 Invalid Token Request
          # 403 Missing Required Tokens
          # 404 Required Resources Not Found
          # 422 Data Lacks Verdicts Labeled 'True' and 'False'
          # 501 Error Retrieving DataHub Information
          puts "Stats: (defined) server response #{st_response.code}: #{body}"
          @response = body
          @errors << body
        else
          # Unexpected Error
          puts "Stats: (undefined) server response #{st_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = st_response.body
      @errors << @response
    end
    return @response
  end

  def runClassifier(login_token, ci_id, p_id)
    @response = nil
    @errors = []
    begin
      with_scaife_statistics_access(login_token) do |access_token, request_token|
        st_response = SCAIFE_run_classifier(access_token, request_token, ci_id, p_id)
        #puts "Statistics server response:"
        #puts st_response
        body = JSON.parse(st_response.body)
        if st_response.code == 200
          @response = body
        elsif [400, 401, 403, 404, 501].include? st_response.code
          # 400 Unable to Run Classifier
          # 401 Invalid Token Request
          # 403 Missing Required Tokens
          # 404 Required Resources Not Found
          # 501 Error Retrieving DataHub Information
          puts "Stats: (defined) server response #{st_response.code}: #{body}"
          @response = body
          @errors << body
        else
          # Unexpected Error
          puts "Stats: (undefined) server response #{st_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = st_response.body
      @errors << @response
    end
    return @response
  end

end
