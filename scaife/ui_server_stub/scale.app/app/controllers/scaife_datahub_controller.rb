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

require 'scaife/api/datahub'
require 'scaife/api/registration'

class ScaifeDatahubController < ScaifeController

=begin
  Displayed on the project-creation-using-SCAIFE-data page (http://127.0.0.1:8083/projects/<PROJECT_ID>/scaife), and within the classifier-creation modal window
=end
  def listProjects(login_token)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Datahub::DataHubServerApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.list_projects_with_http_info(access_token)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if @scaife_status_code == 404
            # no projects uploaded yet
            @scaife_response = []
          elsif [400, 401, 403].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling DataHubServerApi->list_projects: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.listProjects() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

=begin
  Displayed on the project-creation-using-SCAIFE-data page (http://127.0.0.1:8083/projects/<PROJECT_ID>/scaife)
=end
  def listPackages(login_token)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Datahub::DataHubServerApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.list_packages_with_http_info(access_token)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if @scaife_status_code == 404
            # no packages uploaded yet
            @scaife_response = []
          elsif [400, 401, 403].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling DataHubServerApi->list_packages: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.listPackages() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def listLanguages(login_token)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Datahub::DataHubServerApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.list_languages_with_http_info(access_token)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if @scaife_status_code == 404
            # no packages uploaded yet
            @scaife_response = []
          elsif [400, 401, 403].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling DataHubServerApi->list_languages: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.listLanguages() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def createLanguage(login_token, lang_name, lang_version)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          data = Scaife::Api::Datahub::LanguageVersion.build_from_hash({
            language: lang_name,
            version: lang_version
          })
          api = Scaife::Api::Datahub::UIToDataHubApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.create_language_with_http_info(access_token, data)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if [400, 401, 403].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToDataHubApi->create_language: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.createLanguage() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def listTaxonomies(login_token)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Datahub::DataHubServerApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.list_taxonomies_with_http_info(access_token)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if @scaife_status_code == 404
            # no taxonomies uploaded yet
            @scaife_response = []
          elsif [400, 401, 403].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling DataHubServerApi->list_taxonomies: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.listTaxonomies() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def getTaxonomy(login_token, taxonomy_id)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Datahub::DataHubServerApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.get_taxonomy_with_http_info(access_token, taxonomy_id)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if @scaife_status_code == 404
            # no taxonomies uploaded yet
            @scaife_response = []
          elsif [400, 401, 403, 404].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling DataHubServerApi->get_taxonomy: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.getTaxonomy() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def createTaxonomy(login_token, taxonomy_name, taxonomy_version, description, conditions, author_src)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          data = self.symbolize_data({
            taxonomy_name: taxonomy_name,
            taxonomy_version: taxonomy_version,
            description: description,
            author_source: author_src,
            conditions: conditions
          })
          data = Scaife::Api::Datahub::TaxonomyMetadata.build_from_hash(data)
          api = Scaife::Api::Datahub::UIToDataHubApi.new
          @scaife_response, @scaife_status_code, response_headers =
            api.create_taxonomy_with_http_info(access_token, data)
          puts "datahub response: created new taxonomy"
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if @scaife_status_code == 422
            puts "Datahub: taxonomy already exists"
            body = maybe_json_response(e.response_body)
            body = self.symbolize_data(body)
            @scaife_response =
              Scaife::Api::Datahub::CreatedTaxonomy.build_from_hash(body)
          elsif [400, 401, 403].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
            @errors << @scaife_response
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToDataHubApi->create_taxonomy: #{e}\n"
            @scaife_response = e.message
            @errors << @scaife_response
          end
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.createTaxonomy() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

=begin
    Edit Taxonomy method used when a 422 response is sent to SCALe
=end
  def editTaxonomy(login_token, taxonomy_id, conditions)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          data = self.symbolize_data({ conditions: conditions })
          data = Scaife::Api::Datahub::EditTaxonomy.build_from_hash(data)
          api = Scaife::Api::Datahub::UIToDataHubApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.edit_taxonomy_with_http_info(access_token, taxonomy_id, data)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if [400, 401, 403, 404].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToDataHubApi->edit_taxonomy: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.editTaxonomy() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end
  
  def listTools(login_token)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Datahub::DataHubServerApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.list_tools_with_http_info(access_token)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if @scaife_status_code == 404
            puts "Datahub: no tools uploaded yet"
            # no tools uploaded yet
            @scaife_response = []
          elsif [400, 401, 403].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling DataHubServerApi->list_tools: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.listTools() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def getToolData(login_token, tool_id)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Datahub::DataHubServerApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.get_tool_data_with_http_info(access_token, tool_id)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if [400, 401, 403, 404].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling DataHubServerApi->get_tool_data: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.getToolData() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end


=begin
  User selects to "Upload" project data from the landing page
=end

  def uploadTool(login_token, tool_name, tool_version, category, platforms, code_language_ids, checker_mappings, checkers, code_metrics_headers, author_src)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          data = self.symbolize_data({
            tool_name: tool_name,
            tool_version: tool_version,
            category: category,
            language_platforms: platforms,
            code_language_ids: code_language_ids,
            checker_mappings: checker_mappings,
            checkers: checkers,
            author_source: author_src,
            code_metrics_headers: code_metrics_headers
          })
          data = Scaife::Api::Datahub::ToolMetadata.build_from_hash(data)
          api = Scaife::Api::Datahub::UIToDataHubApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.upload_tool_with_http_info(access_token, data)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if @scaife_status_code == 422
            puts "Datahub: tool already exists"
            body = maybe_json_response(e.response_body)
            body = self.symbolize_data(body)
            @scaife_response =
              Scaife::Api::Datahub::ToolResponse.build_from_hash(body)
          elsif [400, 401, 403].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            puts "Upload tool non-200 ApiError: #{@scaife_status_code}"
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToDataHubApi->upload_tool: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.uploadTool() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def editTool(login_token, tool_id, cm_file)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          if File.file? cm_file
            cm_file = File.new(cm_file)
          end
          # TODO - complete in RC-1652
          #data = Scaife::Api::Datahub::BaseTool.new()
          api = Scaife::Api::Datahub::UIToDataHubApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.edit_tool_with_http_info(access_token, tool_id, cm_file)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if [400, 401, 403, 404].include? @scaife_status_code
            puts "Datahub: unable to edit tool: #{@scaife_status_code}"
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToDataHubApi->edit_tool: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.editTool() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def createProject(login_token, p_name, p_descript, author_src, package_id, m_alerts, taxonomy_ids)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          data = self.symbolize_data({
            project_name: p_name,
            project_description: p_descript,
            author_source: author_src,
            package_id: package_id,
            meta_alerts: m_alerts, # need to turn this into an object
            taxonomy_ids: taxonomy_ids
          })
          data = Scaife::Api::Datahub::ProjectMetadata.build_from_hash(data)
          api = Scaife::Api::Datahub::UIToDataHubApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.create_project_with_http_info(access_token, data)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if @scaife_status_code == 422
            puts "Datahub: project already exists"
            body = maybe_json_response(e.response_body)
            body = self.symbolize_data(body)
            @scaife_response =
              Scaife::Api::Datahub::CreatedProject.build_from_hash(body)
            @scaife_response = maybe_json_response(e.response_body)
          elsif [400, 401, 403].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
            @errors << @scaife_response
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToDataHubApi->create_project: #{e}\n"
            @scaife_response = e.message
            @errors << @scaife_response
          end
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.createProject() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def enableDataForwarding(login_token, p_id)
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Datahub::UIToDataHubApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.enable_data_forwarding_with_http_info(access_token, p_id)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          puts "Datahub: failed to enable data forwarding"
          @scaife_status_code = e.code
          @scaife_response = maybe_json_response(e.response_body)
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.enableDataForwarding() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response, @scaife_status_code
  end

  def editProject(login_token, p_id, p_name, p_descript, m_alerts, taxonomy_ids)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          data = self.symbolize_data({
            project_name: p_name,
            project_description: p_descript,
            meta_alerts: m_alerts,  # need to turn into model
            taxonomy_ds: taxonomy_ids
          })
          data = Scaife::Api::Datahub::EditProjectMetadata.build_from_hash(data)
          api = Scaife::Api::Datahub::UIToDataHubApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.edit_project_with_http_info(access_token, p_id, data)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if [400, 401, 403, 404].include? @scaife_status_code
            puts "Datahub: unable to edit project: #{@scaife_status_code}"
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToDataHubApi->edit_project: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.editProject() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def sendMetaAlertsForProject(login_token, p_id, meta_alert_determinations)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          # TODO
          # array of MetaAlertDetermination
          data = meta_alert_determinations.map { |ma|
            ma = self.symbolize_data(ma)
            Scaife::Api::Datahub::MetaAlertDetermination.build_from_hash(ma)
          }
          api = Scaife::Api::Datahub::UIToDataHubApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.send_meta_alerts_for_project_with_http_info(
              access_token, p_id, data)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if [400, 401, 403, 404].include? @scaife_status_code
            puts "Datahub: send meta-alerts for project: #{@scaife_status_code}"
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToDataHubApi->send_meta_alerts_for_project: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.sendMetaAlertsForProject() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def createPackage(login_token, p_name, p_descript, author_src, lang_ids, code_src_url, src_file_url, src_func_url, ts_id, alerts, t_ids)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          data = self.symbolize_data({
            package_name: p_name,
            package_description: p_descript,
            author_source: author_src,
            code_language_ids: lang_ids,
            code_source_url: code_src_url,
            source_file_url: src_file_url,
            source_function_url: src_func_url,
            test_suite_id: ts_id,
            alerts: alerts,    # array of schema
            tool_ids: t_ids
          })
          data = Scaife::Api::Datahub::PackageMetadata.build_from_hash(data)
          api = Scaife::Api::Datahub::UIToDataHubApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.create_package_with_http_info(access_token, data)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if @scaife_status_code == 422
            puts "Datahub: package already exists"
            body = maybe_json_response(e.response_body)
            body = self.symbolize_data(body)
            @scaife_response =
              Scaife::Api::Datahub::CreatedPackage.build_from_hash(body)
          elsif [400, 401, 403].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToDataHubApi->create_package: #{e}\n"
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.createPackage() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def uploadCodebaseForPackage(login_token, p_id, src, file_info, function_info)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          if File.file? src
            src = File.new(src, 'r')
          end
          if File.file? file_info
            file_info = File.new(file_info, 'r')
          end
          if File.file? function_info
            function_info = File.new(function_info, 'r')
          end
          api = Scaife::Api::Datahub::UIToDataHubApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.upload_codebase_for_package_with_http_info(
              access_token, p_id, src, source_file_csv: file_info,
              source_function_csv: function_info)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if [400, 401, 403, 404].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToDataHubApi->upload_codebase_for_package: #{e}\n"
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.uploadCodebaseForPackage() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def createTestSuite(login_token, test_suite_name, test_suite_version, test_suite_type, manifest_urls, use_license_file_url, author_src, code_languages)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          data = self.symbolize_data({
            test_suite_name: test_suite_name,
            test_suite_version: test_suite_version,
            test_suite_type: test_suite_type,
            manifest_urls: manifest_urls,
            use_license_file_url: use_license_file_url,
            author_source: author_src,
            code_languages: code_languages   # array of schema
          })
          data = Scaife::Api::Datahub::TestSuiteMetadata.build_from_hash(data)
          api = Scaife::Api::Datahub::UIToDataHubApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.create_test_suite_with_http_info(access_token, data)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if @scaife_status_code == 422
            puts "Datahub: test suite already exists"
            body = maybe_json_response(e.response_body)
            body = self.symbolize_data(body)
            @scaife_response =
              Scaife::Api::Datahub::TestSuiteHeading.build_from_hash(body)
          elsif [400, 401, 403].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
            @errors << @scaife_response
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToDataHubApi->create_test_suite: #{e}\n"
            @scaife_response = e.message
            @errors << @scaife_response
          end
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.createTestSuite() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def uploadTestSuite(login_token, ts_id, package_id, manifest_file, use_license_file, source_file_csv, source_function_csv)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          if File.file? manifest_file
            manifest_file = File.new(manifest_file)
          end
          if File.file? use_license_file
            use_license_file = File.new(use_license_file)
          end
          if File.file? source_file_csv
            source_file_csv = File.new(source_file_csv)
          end
          if File.file? source_function_csv
            source_function_csv = File.new(source_function_csv)
          end
          api = Scaife::Api::Datahub::UIToDataHubApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.upload_test_suite_with_http_info(
              access_token, ts_id, package_id, manifest_file,
              source_file_csv: source_file_csv,
              source_function_csv: source_function_csv,
              use_license_file: use_license_file)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if [400, 401, 403].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
            @errors << @scaife_response
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToDataHubApi->upload_test_suite: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.uploadTestSuite() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

end
