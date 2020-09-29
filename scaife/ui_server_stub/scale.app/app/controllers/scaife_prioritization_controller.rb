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

require 'scaife/api/prioritization'
require 'scaife/api/registration'

class ScaifePrioritizationController < ApplicationController
  include Scaife::Api::Prioritization
  include Scaife::Api::Registration


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

      begin
          registration_response = SCAIFE_get_access_token(server, login_token)

          if registration_response.code == 200
              priority_access_token = JSON.parse(registration_response.body)["x_access_token"]
              request_token = rand 100..999
              priority_response = SCAIFE_create_priority_scheme(priority_access_token, request_token,
                                    priority_name, project_ids, formula, weighted_columns, is_global, is_remote)

              if priority_response.code == 200
                  @response = JSON.parse(priority_response.body)
              end
          else
              @response = "Failed to connect to SCAIFE servers1"
          end
      rescue
          #failed to connect to registration server
          @response = "Failed to connect to SCAIFE servers"
      end
  end

=begin
  User selects Prioritization dropdown from header
=end
  def listPriorities(login_token, project_id = nil)
    server = "prioritization"

    begin
        registration_response = SCAIFE_get_access_token(server, login_token)

        if registration_response.code == 200
            priority_access_token = JSON.parse(registration_response.body)["x_access_token"]
            request_token = rand 100..999
            if project_id
              priority_response = SCAIFE_get_priorities(priority_access_token, request_token, project_id)
            else
              priority_response = SCAIFE_get_priorities(priority_access_token, request_token)
            end

            if priority_response.code == 200
                @response = JSON.parse(priority_response.body)
            else
                @response = "Failed to connect to SCAIFE servers"
            end
        else
            @response = "Failed to connect to SCAIFE servers"
        end
    rescue #failed to connect to registration server
        @response = "Failed to connect to SCAIFE servers"
    end
  end

=begin
  Get the Prioritization Scheme from SCAIFE
=end
  def getPriority(login_token, project_id, priority_id)
    server = "prioritization"

    begin
        registration_response = SCAIFE_get_access_token(server, login_token)

        if registration_response.code == 200
            priority_access_token = JSON.parse(registration_response.body)["x_access_token"]

            request_token = rand 100..999
            priority_response = SCAIFE_get_priority_scheme(priority_access_token, request_token, project_id, priority_id)

            if priority_response.code == 200
                @response = JSON.parse(priority_response.body)
            else
                @response = "Failed to connect to SCAIFE servers"
            end
        elsif registration_response.code == 405
            #login token may be expired or invalid, sign into SCAIFE again
            @response = "Failed to connect to SCAIFE servers, please ensure user is logged in"
        else
            @response = "Failed to connect to SCAIFE servers"
        end
    rescue #failed to connect to registration server
        @response = "Failed to connect to SCAIFE servers"
    end
  end

=begin
  Update the Prioritization Scheme in SCAIFE
=end
  def updatePriority(login_token, priority_id, priority_name, formula, w_cols, p_ids)
    server = "prioritization"

    begin
        registration_response = SCAIFE_get_access_token(server, login_token)

        if registration_response.code == 200
            priority_access_token = JSON.parse(registration_response.body)["x_access_token"]
            request_token = rand 100..999
            priority_response = SCAIFE_update_priority_scheme(
                    priority_access_token, request_token, priority_id, priority_name, formula, w_cols, p_ids)
            if priority_response.code == 200
                @response = JSON.parse(priority_response.body)
            else
                puts "Cannot Update Prioritization Scheme in SCAIFE"
                @response = "Failed to connect to SCAIFE servers"
            end
        else
            @response = "Failed to connect to SCAIFE servers"
        end
    rescue #failed to connect to registration server
        @response = "Failed to connect to SCAIFE servers"
    end
  end

=begin
  Delete the Prioritization Scheme in SCAIFE
=end
  def deletePriority(login_token, project_id, priority_id)
    server = "prioritization"

    begin
        registration_response = SCAIFE_get_access_token(server, login_token)

        puts priority_id
        if registration_response.code == 200
            priority_access_token = JSON.parse(registration_response.body)["x_access_token"]
            request_token = rand 100..999

            priority_response = SCAIFE_delete_priority_scheme(
                    priority_access_token, request_token, project_id, priority_id)
            if priority_response.code == 200
                @response = JSON.parse(priority_response.body)
            elsif priority_response.code == 404
                @response = "Priority Scheme No Longer in SCAIFE"
            else
                @response = "Failed to connect to SCAIFE servers"
            end
        else
            @response = "Failed to connect to SCAIFE servers"
        end
    rescue #failed to connect to registration server
        @response = "Failed to connect to SCAIFE servers"
    end
  end

end #end class
