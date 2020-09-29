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

class PrioritySchemesController < ApplicationController

  def show
    case session[:scaife_mode]
    when "Connected", "Demo"
        # IF Connected get the priority scheme from SCAIFE if it fails get the scheme from the local DB else
        # Return an error message on the modal
        @get_priority_error = ""
        @priorityColumns = Hash.new
        @project_id = params[:project_id].to_i
        @scaife_mode = session[:scaife_mode]
        @taxonomies = Hash.new
        @is_local = true
        @is_global = false
        @is_remote = false
        @is_project_only = false
        @taxnm = ["VIEW_ALL", "CWES", "CERT_RULES"] # Available Taxonomy Values must be all-uppercase with underscores
        @edit_scheme = true # Flag for scheme_type (local, global, remote) radio buttons

        @scheme_id = (params[:priority_id] == nil || params[:priority_id].empty?) ? "" : params[:priority_id]
        @columns = (PriorityScheme.column_names - ['name','formula', 'weighted_columns', 'created_at', 'updated_at']).sort #, 'project_id']

        userUpload = UserUpload.first

        if userUpload
            @userColumns = JSON.parse(userUpload.user_columns)
            @userColumns.each { |k, v| @userColumns[k] = "0" }
        end

        if session[:scaife_mode] == "Connected" and @scheme_id.match(/^[a-f\d]{24}$/)  # Get the Priority Scheme from SCAIFE first

            scaife_prioritization_controller = ScaifePrioritizationController.new
            scaife_project_id = scaife_prioritization_controller.get_scaife_project_id(@project_id)

            get_priority_response = scaife_prioritization_controller.getPriority(session[:login_token], scaife_project_id, @scheme_id)

            if not get_priority_response.nil? and not get_priority_response.include? "Failed to connect"
              # Populate the GUI with the SCAIFE priority scheme
              @scheme_name = get_priority_response["priority_scheme_name"]


              @is_local = false
              @is_global = get_priority_response["is_global"]
              is_remote = get_priority_response["is_remote"]

              if not @is_global #global is false
                @is_remote = true

                if not is_remote
                  @is_project_only = true
                end
              end

              formula = get_priority_response["formula"]

              @taxnm.each do |taxonomy|
                 taxonomy_regex = 'IF_'+ taxonomy+ '\(([-a-z_\*\+\/\d\s\(\)]+)\)\+?'
                 if formula =~ /#{taxonomy_regex}/
                   @taxonomies[taxonomy] = $1
                 else
                    @taxonomies[taxonomy] = ""
                 end
              end

              fields_and_weights = get_priority_response["weighted_columns"]
              @userColumns = Hash.new

              fields_and_weights.sort.map do |field, weight|
                if @columns.include?(field)
                  if weight.nil?
                    @priorityColumns[field] = 0
                  else
                    @priorityColumns[field] = weight.to_i
                  end
                else
                  @userColumns[field] = weight.to_i
                end
              end

              return
            elsif not get_priority_response.nil? and get_priority_response.include? "please ensure user is logged in"
              #User login token may be invalid or expired.
              @get_priority_error = "Login Token May Have Expired"
            end #end get_priority_response.include?
        end #end scaife connected

        #Get the prioritization scheme from SCALe
        scheme = PriorityScheme.where("id = ?", "#{@scheme_id}")

        if not scheme.empty?
            priority = scheme[0].as_json

            @scheme_name = priority["name"]

            priority.sort.map do |field, value|
              if @columns.include?(field)
                if value.nil?
                  @priorityColumns[field] = 0
                else
                  @priorityColumns[field] = value
                end
              end

              if field == "weighted_columns"
                unless value == "{}"
                  @userColumns = JSON.parse(value)
                end
              end

              if field == "formula"
                @taxnm.each do |taxonomy|
                   taxonomy_regex = 'IF_'+ taxonomy + '\(([-a-z_\*\+\/\d\s\(\)]+)\)\+?'
                   if value =~ /#{taxonomy_regex}/
                     @taxonomies[taxonomy] = $1
                   else
                      @taxonomies[taxonomy] = ""
                   end
                end
              end
            end #end priority.each
        else #create new scheme or priority scheme is not present in either DB
            if @scheme_id.match(/^[a-f\d]{24}$/)
              @get_priority_error = "Failed to Connect to SCAIFE Servers"
            end
            @scheme_name = "Create New Scheme"
            @edit_scheme = false # Flag for scheme_type (local, global, remote) radio buttons
            @columns.each do |field|
                @priorityColumns[field] = 0
            end

            @taxnm.each do |taxonomy|
                @taxonomies[taxonomy] = ""
            end
        end #create new scheme
    else
        # SCALe-only mode
        head 405
    end
  end #getPrioritySchemeModal


  def runPriority
  #Run Priority is pressed in the prioritizationScheme modal, NOTE: SCAIFE currently does not run prioritization schemes
  case session[:scaife_mode]
  when "Connected", "Demo"
    @project_id = params[:project_id]
    @priority = params[:name]
    @formula = params[:formula]
    @columns = params[:columns]

    if not @project_id.to_s.match('\d+')  # from web request, so must sanitize
      print "invalid project id: #{@project_id.to_s}"
    else
      #TODO: validate the formula once rc-417 is implemented
      dbPath = "../db/development.sqlite3"

      columns = @columns.split("|")
      @formula.gsub!("'", "'\''")
      formula = @formula

      Dir.chdir Rails.root.join("scripts")

      ps = PriorityScheme.find_by(name: @priority)
      ps_id = -1

      if ps
        ps_id = ps.id
      end

      # This is the command to run for meta_alert_priority_csv2scale.
      cmd = "./meta_alert_priority_csv2scale.py #{@project_id.to_s} #{dbPath.to_s} '#{formula.to_s}' #{columns.to_json}"

      # Run the command
      system(cmd)

      # Update projects table with last used priority scheme
      project = Project.find(@project_id)

      if project
        project.update(last_used_priority_scheme: ps_id)
      end

      Dir.chdir Rails.root.to_s
    end

    respond_to do |format|
      format.html  {redirect_to("/projects/" + @project_id)}
      format.json {head :no_content}
    end
  else
    # SCALe-only mode
      head 405
    end
  end

  def createPriority #(@project_id, @priority,  @formula, @columns)
    # Save Prioritization Scheme from the 'Create a New Scheme' page
    @scaife_mode = session[:scaife_mode]

    case @scaife_mode
    when "Connected", "Demo"
      @priority_name = params[:priority_name]
      @project_id = params[:project_id]
      @formula = params[:formula]
      @save_type = params[:save_type]
      @scaife_id = nil

      @columns = params[:columns]
      weighted_columns = params[:columns].dup

      @conf, @cert_sev, @cert_like, @cert_rem, @cert_pri, @cert_lvl, @cwe_like,
        @w_cols = helpers.getColumns(@columns)

      if session[:scaife_mode] == "Connected" and @save_type != "local" #Save the Priority Scheme in the SCAIFE server
        case @save_type
        when "global"
          is_global = true
          is_remote = false
        when "remote"
          is_global = false
          is_remote = true
        when "project-only"
          is_global = false
          is_remote = false
        end

        scaife_prioritization_controller = ScaifePrioritizationController.new
        scaife_project_id = scaife_prioritization_controller.get_scaife_project_id(@project_id)

        create_priority_response = scaife_prioritization_controller.createPriority(
                session[:login_token], @priority_name, [scaife_project_id], @formula, weighted_columns, is_global, is_remote)

        if not create_priority_response.nil?
          @scaife_id = create_priority_response["priority_scheme_id"]
        end
      end #end scaife connected

      begin
        if @save_type != "local"
          if @scaife_id
            success = PriorityScheme.createScheme(@priority_name, @project_id,
              @formula, @save_type, @w_cols, @conf, @cert_sev, @cert_like, @cert_rem, @cert_pri,
              @cert_lvl, @cwe_like, @scaife_id)
          end
        else
          success = PriorityScheme.createScheme(@priority_name, @project_id,
            @formula, @save_type, @w_cols, @conf, @cert_sev, @cert_like, @cert_rem, @cert_pri,
            @cert_lvl, @cwe_like)
        end

        if success
          msg = { status: "200", message: "Success" }
        else
          msg = { status: "400", message: "Bad Request" }
          status = 400
        end
      rescue ActiveRecord::RecordNotFound
        msg = { status: "500", message: "Internal Server Error" }
        status = 500
      rescue ActiveRecord::ActiveRecordError
        msg = { status: "500", message: "Internal Server Error" }
        status = 500
      rescue Exception
        raise
      ensure
        respond_to do |format|
          format.json { render json: msg, status: status }
        end
      end
    else
      # SCALe-only mode
      head 405
    end
  end

  def editPriority
    case session[:scaife_mode]
    when "Connected", "Demo"
      @priority_name = params[:priority_name]
      @project_id = params[:project_id]
      @scheme_id = params[:priority_id]
      scheme_id_str = @scheme_id.to_s
      @formula = params[:formula]
      @save_type = params[:save_type]
      @columns = params[:columns]
      weighted_columns = params[:columns].dup
      save_local = false
      @scale_id = nil
      @scaife_id = nil

      @conf, @cert_sev, @cert_like, @cert_rem, @cert_pri, @cert_lvl, @cwe_like,
        @w_cols = helpers.getColumns(@columns)


      # Using SCAIFE
      if session[:scaife_mode] == "Connected" # and @save_type != "local"

        if scheme_id_str.match(/^[a-f\d]{24}$/) # SCAIFE Prioritization Scheme

          scheme = PriorityScheme.where("scaife_p_scheme_id = ?", "#{@scheme_id}")

          if not scheme.empty?
            @scale_id = scheme[0]["id"]

            @scaife_id = @scheme_id
          else
            @scaife_id = @scheme_id # Priority Scheme not saved in SCALe
          end

        else # Local Prioritization Scheme only
            @scale_id = @scheme_id
        end
      else # Not SCAIFE connected
        @scale_id = @scheme_id
      end

      scaife_upload_status = true # Indicator for SCAIFE Edit failure (true if successful)

      if not @scaife_id.nil?

        scaife_prioritization_controller = ScaifePrioritizationController.new
        scaife_project_id = scaife_prioritization_controller.get_scaife_project_id(@project_id)

        update_priority_response = scaife_prioritization_controller.updatePriority(
                      session[:login_token], @scaife_id, @priority_name, @formula, weighted_columns, [scaife_project_id])

        if update_priority_response.nil? or update_priority_response.include? "Failed to connect"
          scaife_upload_status = false
        end
      end

      status = 200
      begin
        if scaife_upload_status and @scale_id
          success = PriorityScheme.editScheme(@scale_id, @priority_name, @project_id,
              @formula, @w_cols, @conf, @cert_sev, @cert_like, @cert_rem, @cert_pri,
              @cert_lvl, @cwe_like, @scaife_id)
        end

        if success
          msg = { status: "200", message: "Success" }
        else
          if scaife_upload_status and not @scale_id # SCAIFE scheme edited successfully, but not saved in SCALe
            msg = { status: "200", message: "SCAIFE Success" }
          else
            msg = { status: "400", message: "Bad Request" }
            status = 400
          end
        end
      rescue ActiveRecord::RecordNotFound
        msg = { status: "500", message: "Internal Server Error" }
        status = 500
      rescue ActiveRecord::ActiveRecordError
        msg = { status: "500", message: "Internal Server Error" }
        status = 500
      rescue Exception
        raise
      ensure
        respond_to do |format|
          format.json { render json: msg, status: status }
        end
      end
    else
      # SCALe-only mode
      head 405
    end
  end

  def deletePriority
    case session[:scaife_mode]

    when "Connected", "Demo"
      @project_id = params[:project_id] #SCALe Project ID
      @schemeValue = (params[:priority_name] == nil || params[:priority_name].empty?) ? "" : params[:priority_name]
      @scheme_id = params[:priority_id]
      scheme_id_str = @scheme_id.to_s
      @scaife_id = nil
      @scale_id = nil
      scaife_successful_delete = false # determine if SCAIFE successfully deleted schemes

      if session[:scaife_mode] == "Connected"
        if scheme_id_str.match(/^[a-f\d]{24}$/) # SCAIFE Prioritization Scheme

          scheme = PriorityScheme.where("scaife_p_scheme_id = ?", "#{@scheme_id}")

          if not scheme.empty?
            @scale_id = scheme[0]["id"]

            @scaife_id = @scheme_id
          else # SCAIFE scheme only (not saved locally)
            @scaife_id = @scheme_id
          end

        else # Local Prioritization Scheme only
            @scale_id = @scheme_id
            scaife_successful_delete = true #skips SCAIFE deletion call
        end
      else # end scaife connected
        @scale_id = @scheme_id
        scaife_successful_delete = true #skips SCAIFE deletion call
      end

      if not @scaife_id.nil?

        scaife_prioritization_controller = ScaifePrioritizationController.new
        scaife_project_id = scaife_prioritization_controller.get_scaife_project_id(@project_id)

        delete_priority_response = scaife_prioritization_controller.deletePriority(
                      session[:login_token], scaife_project_id, @scaife_id.to_s)

        if delete_priority_response.nil? or delete_priority_response.include? "Failed to connect"
          scaife_successful_delete = false
        else
          scaife_successful_delete = true
        end
      end # end if not scaife.nil?

      begin
         if scaife_successful_delete and @scale_id
           priority = PriorityScheme.where("id = ?", "#{@scale_id}")

           if not priority.empty?
             success = priority.destroy_all
           else # SCALe Priority Scheme does not exist
             success = scaife_successful_delete
           end
         end

         if success
           msg = { status: "200", message: "Success" }
         else
           msg = { status: "400", message: "Bad Request" }
           status = 400
         end
         rescue ActiveRecord::RecordNotFound
           msg = { status: "500", message: "Internal Server Error" }
           status = 500
         rescue ActiveRecord::ActiveRecordError
           msg = { status: "500", message: "Internal Server Error" }
           status = 500
         rescue Exception
           raise
         ensure
           respond_to do |format|
             format.json { render json: msg, status: status }
           end
         end
    else
      # SCALe-only mode
      head 405
    end
  end

end #end class
