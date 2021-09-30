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

require 'scaife/api/prioritization'
require 'scaife/api/registration'

class ScaifePrioritizationController < ScaifeController

=begin
   Get the SCAIFE project ID to use in SCAIFE calls, if no SCAIFE is present
   pad the SCALe ID with zeros to match the SCAIFE format
=end
def get_scaife_project_id(project_id)

    padded_project_id = project_id.to_s + ("0" * (24 - project_id.to_s.length))

    scale_project = Project.where("id = ?", "#{project_id}")

    if not scale_project.empty?
      return (scale_project[0]["scaife_project_id"].nil? || scale_project[0]["scaife_project_id"].empty?) ?
                                  padded_project_id : scale_project[0]["scaife_project_id"]
    else
      return padded_project_id
    end
end

=begin
  Create the prioritization scheme in SCAIFE
=end
  def createPriority(login_token, priority_name, project_ids, formula, weighted_columns, is_global, is_remote)
    server = "prioritization"
    @errors = []
    begin
      with_scaife_prioritization_access(login_token) do |access_token|
        begin
          data = self.symbolize_data({
            priority_scheme_name: priority_name,
            project_ids: project_ids,
            formula: formula,
            weighted_columns: weighted_columns,
            is_global: is_global,
            is_remote: is_remote
          })
          data = Scaife::Api::Prioritization::CreatePrioritizationData.build_from_hash(data)
          api = Scaife::Api::Prioritization::UIToPrioritizationApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.create_prioritization_with_http_info(access_token, data)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Prioritization::ApiError => e
          if [400, 401, 403, 405].include? e.code
            # Invalid Request, missing tokens, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unknown error
            puts "\nException #{__method__} calling UIToPrioritizationApi->create_prioritization: #{e}\n"

            @scaife_response = "#{e}"
            @errors << @scaife_response
          end
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.uploadTool() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @scaife_response = dh_response.body
      @errors << @scaife_response
    end
  end

=begin
  User selects Prioritization dropdown from header
=end
  def listPriorities(login_token, project_id = nil)
    server = "prioritization"
    @errors = []
    begin
      with_scaife_prioritization_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Prioritization::UIToPrioritizationApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.list_prioritizations_with_http_info(
              access_token, project_id: project_id)
          if @scaife_status_code == 200
            @scaife_response = @scaife_response.priority_list
          else
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Prioritization::ApiError => e
          if [400, 401, 403, 404].include? e.code
            # Invalid Request, not found, etc
            if e.code == 404
                @scaife_response = []
            else
                @scaife_response = maybe_json_response(e.response_body)
            end
          else
            # Unknown error
            puts "\nException #{__method__} calling UIToPrioritizationApi->list_prioritizations: #{e}\n"

            @scaife_response = "#{e}"
            @errors << @scaife_response
          end
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.uploadTool() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @scaife_response = dh_response.body
      @errors << @scaife_response
    end
    return @scaife_response
  end

=begin
  Get the Prioritization Scheme from SCAIFE
=end
  def getPriority(login_token, project_id, priority_id)
    server = "prioritization"
    @errors = []
    begin
      with_scaife_prioritization_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Prioritization::UIToPrioritizationApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.get_prioritization_with_http_info(
              priority_id, project_id, access_token)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Prioritization::ApiError => e
          if [400, 401, 403, 404].include? e.code
            # Invalid Request, not found, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unknown error
            puts "\nException #{__method__} calling UIToPrioritizationApi->get_prioritization: #{e}\n"

            @scaife_response = "#{e}"
            @errors << @scaife_response
          end
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.uploadTool() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @scaife_response = dh_response.body
      @errors << @scaife_response
    end
    return @scaife_response
  end

=begin
  Update the Prioritization Scheme in SCAIFE
=end
  def updatePriority(login_token, priority_id, priority_name, formula, w_cols, p_ids)
    server = "prioritization"
    @errors = []
    begin
      with_scaife_prioritization_access(login_token) do |access_token|
        begin
          data = self.symbolize_data({
            project_ids: p_ids,
            priority_scheme_name: priority_name,
            formula: formula,
            weighted_columns: w_cols
          })
          data = Scaife::Api::Prioritization::UpdatePriorityData.build_from_hash(data)
          api = Scaife::Api::Prioritization::UIToPrioritizationApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.update_prioritization_with_http_info(
              priority_id, access_token, data)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Prioritization::ApiError => e
          if [400, 401, 403, 404, 405].include? e.code
            # Invalid Request, not found, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unknown error
            puts "\nException #{__method__} calling UIToPrioritizationApi->update_prioritization: #{e}\n"

            @scaife_response = "#{e}"
            @errors << @scaife_response
          end
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.uploadTool() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @scaife_response = dh_response.body
      @errors << @scaife_response
    end
    return @scaife_response
  end

=begin
  Delete the Prioritization Scheme in SCAIFE
=end
  def deletePriority(login_token, project_id, priority_id)
    server = "prioritization"
    @errors = []
    begin
      with_scaife_prioritization_access(login_token) do |access_token|
        begin
          api = Scaife::Api::Prioritization::UIToPrioritizationApi.new
          @scaife_response, @scaife_status_code, response_headers = \
            api.delete_prioritization_with_http_info(
              priority_id, project_id, access_token)
          if @scaife_status_code != 200
            puts "Unknown result in #{__method__}: #{@scaife_status_code}: #{@scaife_response}"
            @scaife_response = "Unknown Result"
            @errors << @scaife_response
          end
        rescue Scaife::Api::Prioritization::ApiError => e
          if [400, 401, 403, 405].include? e.code
            # Invalid Request, not found, etc
            @scaife_response = maybe_json_response(e.response_body)
          else
            # Unknown error
            puts "\nException #{__method__} calling UIToPrioritizationApi->delete_prioritization: #{e}\n"

            @scaife_response = "#{e}"
            @errors << @scaife_response
          end
        end
      end
    rescue ScaifeError => e
      # registration server issue
      puts "c.uploadTool() ScaifeError caught: #{e.message}"
      @scaife_response = e.message
      @errors << @scaife_response
    rescue JSON::ParserError
      # HTML formatted error (hostname lookup failure perhaps)
      @scaife_response = dh_response.body
      @errors << @scaife_response
    end
    return @scaife_response
  end

end # end class
