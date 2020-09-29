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

require 'scaife/api/datahub'
require 'scaife/api/registration'

class ScaifeDatahubController < ApplicationController
  include Scaife::Api::Datahub
  include Scaife::Api::Registration

  attr_accessor :response
  attr_accessor :registration_response

=begin
  Displayed on the project-creation-using-SCAIFE-data page (http://127.0.0.1:8083/projects/<PROJECT_ID>/scaife), and within the classifier-creation modal window
=end
  def listProjects(login_token)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_list_projects(access_token, request_token)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body["projects"]
        elsif [400, 401, 403].include? dh_response.code
          # 400 Invalid Request
          # 401 Invalid Token Request
          # 403 Missing Required Tokens
          @response = body
          @errors << body
        elsif dh_response.code == 404
          puts "Datahub: no projects uploaded yet"
          # no projects uploaded yet
          @response = []
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.listProjects() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

=begin
  Displayed on the project-creation-using-SCAIFE-data page (http://127.0.0.1:8083/projects/<PROJECT_ID>/scaife)
=end
  def listPackages(login_token)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_list_packages(access_token, request_token)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body["packages"]
        elsif dh_response.code == 400
          puts "Datahub: invalid request"
          # invalid request
          @response = body
          @errors << body
        elsif dh_response.code == 404
          puts "Datahub: no packages uploaded yet"
          # no packages uploaded yet
          @response = []
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.listPackages() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def listLanguages(login_token)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_list_languages(access_token, request_token)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body["languages"]
        elsif dh_response.code == 400
          puts "Datahub: invalid request"
          # invalid request
          @response = body
          @errors << body
        elsif dh_response.code == 404
          puts "Datahub: no languages uploaded yet"
          # no languages uploaded yet
          @response = []
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.listLanguages() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def createLanguage(login_token, lang_name, lang_version)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_create_language(access_token, request_token, lang_name, lang_version)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body["language"]
        elsif dh_response.code == 400
          # Unable to Create Language
          puts "Datahub: unable to create language"
          @response = body
          @errors << body
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.createLanguage() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def listTaxonomies(login_token)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_get_taxonomy_list(access_token, request_token)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body["taxonomies"]
        elsif dh_response.code == 400
          puts "Datahub: invalid request"
          # invalid request
          @response = body
          @errors << body
        elsif dh_response.code == 404
          puts "Datahub: no taxonomies uploaded yet"
          # no taxonomies uploaded yet
          @response = []
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.listTaxonomies() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def getTaxonomy(login_token, taxonomy_id)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_get_taxonomy(access_token, request_token, taxonomy_id)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body["taxonomy"]
        elsif [400, 404].include? dh_response.code
          puts "Datahub: invalid request"
          # 400 Invalid Request
          # 404 Taxonomy Unavailable
          @response = body
          @errors << body
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.getTaxonomy() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def createTaxonomy(login_token, taxonomy_name, taxonomy_version, description, conditions, author_src)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_create_taxonomy(access_token, request_token, taxonomy_name, taxonomy_version, description, conditions, author_src)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body["taxonomy"]
        elsif dh_response.code == 400
          # Unable to Create Taxonomy
          puts "Datahub: unable to createa taxonomy"
          @response = body
          @errors << body
        elsif dh_response.code == 422
          # Taxonomy Data Exists
          puts "Datahub: taxonomy already exists"
          body["taxonomy"]["already_exists"] = true # Used to indicate an edit call to upload additional conditions may be needed
          @response = body["taxonomy"]
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.createTaxonomy() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def editTaxonomy(login_token, taxonomy_id, conditions)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_edit_taxonomy(access_token, request_token, taxonomy_id, conditions)
        puts "Datahub server edit_taxonomy() response:"
        puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body["conditions"]
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.createTaxonomy() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end
  
=begin
    Edit Taxonomy method used when a 422 response is sent to SCALe
=end
    def editTaxonomy(login_token, taxonomy_id, conditions)
      @response = nil
      @errors = []
      begin
        with_scaife_datahub_access(login_token) do |access_token, request_token|
          dh_response = SCAIFE_edit_taxonomy(access_token, request_token, taxonomy_id, conditions)
          #puts "Datahub server response:"
          #puts dh_response
          body = JSON.parse(dh_response.body)
          if dh_response.code == 200
            @response = body["conditions"]
          elsif dh_response.code == 400
            # Unable to Create Taxonomy
            puts "Datahub: unable to edit a taxonomy"
            @response = body
            @errors << body
          elsif dh_response.code == 404
            # Taxonomy does not exist
            puts "Datahub: taxonomy does not exist"
            @response = body
            @errors << body
          else
            # Unexpected Error
            puts body.keys().keys()
            puts "Datahub: server response #{dh_response.code}: #{body}"
            @response = body.to_s
            @errors << body
          end
        end
      rescue ScaifeError => e
        # registration server issue
        puts "c.editTaxonomy() ScaifeError caught: #{e.message}"
        @response = e.message
        @errors << @response
      rescue JSON::ParserError
        # HTML formatted error (hostname lookup failure perhaps)
        @response = dh_response.body
        @errors << @response
      end
      return @response
    end

  def listTools(login_token)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_get_tool_list(access_token, request_token)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body["tools"]
        elsif dh_response.code == 400
          puts "Datahub: invalid request"
          # Invalid Request
          @response = body
          @errors << body
        elsif dh_response.code == 404
          puts "Datahub: no tools uploaded yet"
          # no tools uploaded yet
          @response = []
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.listTools() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def getToolData(login_token, tool_id)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_get_tool_data(access_token, request_token, tool_id)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body["tool"]
        elsif [400, 404].include? dh_response.code
          # 400 Invalid Request
          # 404 Tool Unavailable
          @response = body
          @errors << body
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.getToolData() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end


=begin
  User selects to "Upload" project data from the landing page
=end

  def uploadTool(login_token, tool_name, tool_version, category, platforms, code_language_ids, checker_mappings, checkers, code_metrics_headers, author_src)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_upload_tool(access_token, request_token, tool_name, tool_version, category, platforms, code_language_ids, checker_mappings, checkers, code_metrics_headers, author_src)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body["tool"]
        elsif dh_response.code == 400
          # Unable to Upload Tool Information
          puts "Datahub: unable to upload tool"
          @response = body
          @errors << body
        elsif dh_response.code == 422
          # Tool Exists
          puts "Datahub: tool already exists"
          @response = body["tool"]
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.uploadTool() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def editTool(login_token, tool_id, checker_mappings_file_path)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_edit_tool(access_token, request_token, tool_id, checker_mappings_file_path)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body
        elsif dh_response.code == 400
          # Unable to Upload Checker or Metrics Information
          puts "Datahub: unable to edit tool"
          @response = body
          @errors << body
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.editTool() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def createProject(login_token, p_name, p_descript, author_src, package_id, m_alerts, taxonomy_ids)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_create_project(access_token, request_token, p_name, p_descript, author_src, package_id, m_alerts, taxonomy_ids)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body["project"]
        elsif dh_response.code == 400
          # Unable to Create Project
          puts "Datahub: unable to create project"
          @response = body
          @errors << body
        elsif dh_response.code == 422
          # Project Data Exists
          puts "Datahub: project already exists"
          @response = body["project"]
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.createProject() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def enableDataForwarding(login_token, p_id)
    @response = nil
    @dh_status_code = -1
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_enable_data_forwarding(access_token, request_token, p_id)
        body = JSON.parse(dh_response.body)
        @dh_status_code = dh_response.code
        if @dh_status_code == 200
          @response = body
        else
          # Failed to enable data forwarding
          puts "Datahub: failed to enable data forwarding"
          @response = body
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.enableDataForwarding() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @errors << @response
    end
    return @response, @dh_status_code
  end

  def editProject(login_token, p_id, p_name, p_descript, m_alerts, taxonomy_ids)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_edit_project(access_token, request_token, p_id, p_name, p_descript, m_alerts, taxonomy_ids)
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body
        elsif dh_response.code == 400
          # Unable to Create Project
          puts "Datahub: unable to edit project"
          @response = body
          @errors << body
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.editProject() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def sendMetaAlertsForProject(login_token, p_id, meta_alert_determinations)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_send_meta_alerts_for_project(access_token, request_token, p_id, meta_alert_determinations)
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body
        elsif dh_response.code == 400
          # Unable to Create Project
          puts "Datahub: unable to send meta-alerts for project"
          @response = body
          @errors << body
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.sendMetaAlertsForProject() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def createPackage(login_token, p_name, p_descript, author_src, lang_ids, code_src_url, src_file_url, src_func_url, ts_id, alerts, t_ids)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_create_package(access_token, request_token, p_name, p_descript, author_src, lang_ids, code_src_url, src_file_url, src_func_url, ts_id, alerts, t_ids)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body["package"]
        elsif dh_response.code == 400
          # Unable to Create Package
          puts "Datahub: unable to upload package"
          @response = body
          @errors << body
        elsif dh_response.code == 422
          # Package Data Exists
          puts "Datahub: package already exists"
          @response = body["package"]
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.createPackage() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def uploadCodebaseForPackage(login_token, p_id, src, file_info, function_info)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_upload_codebase_for_package(access_token, request_token, p_id, src, file_info, function_info)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body
        elsif dh_response.code == 400
          # Unable to Upload Code Source Archive
          puts "Datahub: unable to upload source archive for project"
          @response = body
          @errors << body
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.uploadCodebaseForPackage() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def createTestSuite(login_token, test_suite_name, test_suite_version, test_suite_type, manifest_urls, use_license_file_url, author_source, code_languages)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_create_test_suite(access_token, request_token, test_suite_name, test_suite_version, test_suite_type, manifest_urls, use_license_file_url, author_source, code_languages)
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body["test_suite"]
        elsif dh_response.code == 400
          # Unable to Upload Test Suite
          puts "Datahub: unable to upload test suite"
          @response = body
          @errors << body
        elsif dh_response.code == 422
          # Test Suite Data Exists
          puts "Datahub: test suite already exists"
          @response = body["test_suite"]
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.createTestSuite() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

  def uploadTestSuite(login_token, ts_id, package_id, manifest_file, use_license_file, source_file_csv, source_function_csv)
    @response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token, request_token|
        dh_response = SCAIFE_upload_test_suite(access_token, request_token, ts_id, package_id, manifest_file, use_license_file, source_file_csv, source_function_csv)       
        #puts "Datahub server response:"
        #puts dh_response
        body = JSON.parse(dh_response.body)
        if dh_response.code == 200
          @response = body
        elsif dh_response.code == 400
          # Unable to Upload MetaData Files
          puts "Datahub: test suite invalid request"
          @response = body
          @errors << body
        elsif dh_response.code == 404
          # Unable to Upload MetaData Files
          puts "Datahub: unable to upload test suite metadata"
          @response = body
        else
          # Unexpected Error
          puts body.keys().keys()
          puts "Datahub: server response #{dh_response.code}: #{body}"
          @response = body.to_s
          @errors << body
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.uploadTestSuite() ScaifeError caught: #{e.message}"
      @response = e.message
      @errors << @response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @response = dh_response.body
      @errors << @response
    end
    return @response
  end

end
