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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
          data = Scaife::Api::Datahub::LanguageMetadata.build_from_hash({
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def editPackage(login_token, p_id, p_name: nil, p_desc: nil, tool_ids: nil, alerts: nil, git_url: nil, git_user: nil, git_access_token: nil)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          data = {}
          if p_name.present?
            data[:project_name] = p_name
          end
          if p_desc.present?
            data[:project_description] = p_desc
          end
          if tool_ids.present?
            data[:tool_ids] = tool_ids
          end
          if alerts.present?
            data[:alerts] = alerts
          end
          if git_url.present?
            data[:git_url] = git_url
          end
          if git_user.present?
            data[:git_user] = git_user
          end
          if git_access_token.present?
            data[:git_access_token] = git_access_token
          end
          data = self.symbolize_data(data)
          data = Scaife::Api::Datahub::EditPackageMetadata.build_from_hash(data)
          api = Scaife::Api::Datahub::UIToDataHubApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.edit_package_with_http_info(access_token, p_id, data)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if [400, 401, 403, 404].include? @scaife_status_code
            puts "Datahub: unable to edit package: #{@scaife_status_code}"
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unexpected Error
            puts "\nException #{__method__} calling UIToDataHubApi->edit_package: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def createCIPackage(login_token, pkg_name, pkg_desc, author_src, lang_ids, tool_ids, git_url, git_user: nil, git_access_token: nil)
    return createPackage(login_token, pkg_name, pkg_desc, author_src, lang_ids,
              "", "", "", "", [], tool_ids, git_url: git_url,
              git_user: git_user, git_access_token: git_access_token)
  end

  def createPackage(login_token, pkg_name, pkg_desc, author_src, lang_ids, code_src_url, src_file_url, src_func_url, ts_id, alerts, t_ids, git_url: nil, git_user: nil, git_access_token: nil)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          data = self.symbolize_data({
            package_name: pkg_name,
            package_description: pkg_desc,
            author_source: author_src,
            code_language_ids: lang_ids,
            code_source_url: code_src_url,
            source_file_url: src_file_url,
            source_function_url: src_func_url,
            test_suite_id: ts_id,
            alerts: alerts,    # array of schema
            tool_ids: t_ids
          })
          if git_url.present?
            data[:git_url] = git_url
            data[:git_user] = git_user
            data[:git_access_token] = git_access_token
          end
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
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
      puts "#{__method__} ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def listExperimentConfigs(login_token)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Datahub::DataHubServerApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.list_experiment_configs(access_token)
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
            puts "\nException #{__method__} calling DataHubServerApi->list_experiment_configs: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "#{__method__} ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def getUpdatesForProject(login_token, project_id)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Datahub::DataHubServerApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.get_alerts_for_project_with_http_info(access_token, project_id)
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
            puts "\nException #{__method__} calling DataHubServerApi->get_alerts_for_project: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "#{__method__} ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

  def updatesExist(login_token, project, waypoint: nil, override: false)
    if override
      puts "overide: #{overide}"
      return true
    end
    if project.scaife_project_id.blank?
      return false
    end
    @errors = []
    @updates_exist = false
    if waypoint.blank?
      # waypoint is required by swagger, just pass a datetime if there
      # is no commit hash yet; offset into the past
      puts "no waypoint, passing Time.now"
      waypoint = Time.now.getutc() - 3600*24*100
      waypoint = waypoint.strftime("%Y%m%dT%H%M%S%z")
    end
    ## check for scaife updates to this project
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Datahub::DataHubServerApi.new
          # waypoint = Time.now.getutc.strftime("%Y%m%dT%H%M%S%z")
          @scaife_response, @scaife_status_code, response_headers = \
            api.get_if_updates_exist_for_project_with_http_info(
              access_token, project.scaife_project_id, waypoint)
          if @scaife_status_code == 200
            @updates_exist = true
          elsif @scaife_status_code == 204
            @updates_exist = false
          else
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Datahub::ApiError => e
          @scaife_status_code = e.code
          if @scaife_status_code == 404
            @errors << "project not found: #{project_id}"
          elsif [400, 401, 403].include? @scaife_status_code
            # Invalid Request, missing tokens, etc
            puts "scaife updates response #{@scaife_status_code} #{e.message}"
            @errors << e.message
          else
            # Unexpected Error
            puts "\nException #{__method__} calling DataHubServerApi->list_projects: #{e}\n"
            @errors << e.message
          end
          @updates_exist = false
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "#{__method__} Error caught: #{e.message}"
      @errors << e.message
      @updates_exist = false
    end
    return @updates_exist
  end

  def initiateExperimentExport(login_token, scaife_project_id)
    @scaife_response = nil
    @errors = []
    begin
      with_scaife_datahub_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Datahub::DataHubServerApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.export_experiment_metrics(access_token, scaife_project_id)
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
            puts "\nException #{__method__} calling DataHubServerApi->list_experiment_configs: #{e}\n"
            @scaife_response = e.message
          end
          @errors << @scaife_response
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "#{__method__} ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    end
    return @scaife_response
  end

end
