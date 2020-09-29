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

require 'utility/timing'

class ClassifierSchemesController < ApplicationController
    include Utility::Timing

def getModals
  @scaife_mode = session[:scaife_mode]
  case @scaife_mode
  when "Connected", "Demo"
    @classifier_id = nil
    @classifier_type = params[:chosen]
    @projects = Project.pluck("name") #get all SCALe projects available
    @scaife_projects = []
    @project_id = params[:project_id]
    @className = params[:className]

    # check current project_id
    if not @project_id.to_s.match('\d+')  # from web request, so must sanitize
      print "invalid project id: #{@project_id.to_s}"
      raise ActionController::RoutingError.new('Not Found') #Throw an http request error
    else
        # @classifier_instance_name = "" #leave empty
        @selectedProjects = []
        @ahpoList = []
        @adaptiveHeuristics = Hash.new

        if "Connected" == @scaife_mode
            scaife_datahub_controller = ScaifeDatahubController.new
            list_projects_response = scaife_datahub_controller.listProjects(session[:login_token])
            if nil == list_projects_response || list_projects_response.is_a?(String) #Failed to connect to Registration/DataHub server
                puts "Failed to retrieve SCAIFE projects from DataHub"
                raise ActionController::RoutingError.new('Projects must be uploaded to SCAIFE first')
            else
               for project_object in list_projects_response
                   project_name = project_object["project_name"]
                   @scaife_projects.append(project_name)
               end
            end

            scaife_statistics_controller = ScaifeStatisticsController.new
            list_classifiers_response = scaife_statistics_controller.listClassifiers(session[:login_token])
            if list_classifiers_response.is_a?(String) #Failed to connect to Registration/Stats server
                @ahpoList = []
                @adaptiveHeuristics = []
                @modal_type = ""
            else
                @modal_type = (params[:chosen] == nil || params[:chosen].empty?) ? "" : params[:chosen]
                list_classifiers_response.each do |object|
                    if @classifier_type == object["classifier_type"]
                        @classifier_id = object["classifier_id"]
                        ahpos = object["ahpos"]
                        ahpos.each do |a|
                            @ahpoList.push(a["name"])
                        end
                        adaptive_heuristics = object["adaptive_heuristics"]
                        adaptive_heuristics.each do |ah|
                            ah_name = ah["name"]
                            @adaptiveHeuristics[ah_name] = ah["parameters"]
                        end
                    end
                end
            end
        else # In non-connected Demo mode
            @modal_type = (params[:chosen] == nil || params[:chosen].empty?) ? "" : params[:chosen]
            @ahpoList = ['caret', 'sei-ahpo']

            @adaptiveHeuristics['No Parameters'] = {}
            @adaptiveHeuristics['Z-ranking'] = {'severity': 'moderate', 'count': '5', 'present': 'true'}
            @adaptiveHeuristics['Heckmans ARM'] = {'covering': ['curve', 'lowest']}
        end

        render partial: 'classifier.html.erb'
    end
  else
    # SCALe-only mode
    head 405
  end
end

def createClassifier
  #Create classifier button is pressed in the classifier modal
  start_timestamps = get_timestamps()

  case session[:scaife_mode]

  when "Connected", "Demo"
    @scaife_mode = session[:scaife_mode]
    @classifier_instance_name = params[:classifier_instance_name]
    @classifier_id = params[:scaife_classifier_id]
    @classifier_type = params[:classifier_type]
    @project_id = params[:project_id]
    @source_domain = params[:source_domain]
    #OBE: All projects will be stored in the DB prior to calling the API for create classifier. Projects id, names are sent to the GUI and put in 'transfer boxes'
    @adaptive_heuristic_name = params[:adaptive_heuristic_name]
    @adaptive_heuristic_parameters = params[:adaptive_heuristic_parameters]
    @ahpo_name =  params[:ahpo_name]
    @ahpo_parameters =  params[:ahpo_parameters]

    status = 200
    msg = ""

    if "Connected" == @scaife_mode
      @project_ids = []
      @selectedProjects = @source_domain.split(",")
      scaife_datahub_controller = ScaifeDatahubController.new
      list_projects_response = scaife_datahub_controller.listProjects(session[:login_token])
      #puts list_projects_response
      if nil == list_projects_response || list_projects_response.is_a?(String) #Failed to connect to Registration/Stats server
          puts "Failed to retrieve project list from DataHub"
      else
        for project_object in list_projects_response
          proj_id = project_object["project_id"]
          proj_name = project_object["project_name"]
          if @selectedProjects.include? proj_name
            @project_ids.append(proj_id)
          end
        end
      end

      scaife_statistics_controller = ScaifeStatisticsController.new
      create_classifier_response = scaife_statistics_controller.createClassifier(session[:login_token], @classifier_id, @classifier_type, @classifier_instance_name, @project_ids, @ahpo_name, {}, @adaptive_heuristic_name, {})
      #puts "SCAIFE create classifier response: "
      #puts create_classifier_response

      if create_classifier_response.is_a?(String) #Failed to connect to Registration/Stats server
        @classifier_type = ""
        msg = { status: "400", message: create_classifier_response }
        respond_to do |format|
          format.json { render json: msg, status: 400 }
        end
      else
        @classifier_instance_id = create_classifier_response["classifier_instance_id"]
        #puts @classifier_instance_id
        begin
          ClassifierScheme.insertClassifier(@classifier_instance_name, @classifier_type, @source_domain, @adaptive_heuristic_name, @adaptive_heuristic_parameters, @ahpo_name, @ahpo_parameters, @classifier_id, @classifier_instance_id)
          @project = Project.find_by_id(@project_id)
          @project.update_attribute("current_classifier_scheme", @classifier_instance_name)
          msg = "Success"
          status = 200
          end_timestamps = get_timestamps()
          PerformanceMetrics.addRecord(@scaife_mode, "createClassifier", "Time to create a SCAIFE classifier", "SCALe_user", "Unknown", @project_id.to_i, start_timestamps, end_timestamps)
        rescue ActiveRecord::RecordInvalid => e
          puts "DB validation error: #{e.message}"
          msg = "Bad Request: #{e.message}"
          status = 400
        rescue ActiveRecord::ActiveRecordError => e
          puts "DB error: #{e.message}"
          msg = "Internal Server Error"
          status = 500
        ensure
          msg = { status: status, message: msg }
          respond_to do |format|
            format.json { render json: msg, status: status }
          end
        end
      end
    elsif "Demo" == @scaife_mode
      begin
        ClassifierScheme.insertClassifier(@classifier_instance_name, @classifier_type, @source_domain, @adaptive_heuristic_name, @adaptive_heuristic_parameters, @ahpo_name, @ahpo_parameters, nil, nil)
        @project = Project.find_by_id(@project_id)
        #  @project.update_attribute("current_classifier_scheme", @classifier_instance_name)
        msg = "Success"
        status = 200
        end_timestamps = get_timestamps()
        PerformanceMetrics.addRecord(@scaife_mode, "createClassifier", "Time to create a SCAIFE classifier", "SCALe_user", "Unknown", @project_id.to_i, start_timestamps, end_timestamps)
      rescue ActiveRecord::RecordInvalid => e
        puts "DB validation error: #{e.message}"
        msg = "Bad Request: #{e.message}"
        status = 400
      rescue ActiveRecord::ActiveRecordError => e
        puts "DB error: #{e.message}"
        msg = "Internal Server Error"
        status = 500
      ensure
        msg = { status: status, message: msg }
        respond_to do |format|
          format.json { render json: msg, status: status }
        end
      end
    end
  else
    # SCALe-only mode
    msg = { status: 405, message: "Method Not Allowed Error" }
    respond_to do |format|
      format.json { render json: msg, status: 405 }
    end
  end
end


def viewClassifier
  @scaife_mode = session[:scaife_mode]
  case @scaife_mode
  when "Connected", "Demo"
    @classifier_instance_name = params[:chosen]
    @classifer_instance_type_id = Hash.new
    @className = 'existing-classifier'
    scheme = ClassifierScheme.where("classifier_instance_name = ?", "#{@classifier_instance_name}").first

    if not scheme.nil?
      @selectedProjects = scheme.source_domain.split(",")
      @projects = Project.pluck("name") - @selectedProjects #get all projects available
      @scaife_projects = []
      @selectedAHPO = scheme.ahpo_name
      @selectedAH = scheme.adaptive_heuristic_name
      @selectedParameters = scheme.adaptive_heuristic_parameters
      @classifier_type = scheme.classifier_type

      @ahpoList = []
      @originalAH = Hash.new

      if "Connected" == @scaife_mode
        scaife_statistics_controller = ScaifeStatisticsController.new
        list_classifiers_response = scaife_statistics_controller.listClassifiers(session[:login_token])
        #puts list_classifiers_response

        if nil == list_classifiers_response || list_classifiers_response.is_a?(String) #Failed to connect to Registration/Stats server
          @classifier_type = ""
        else
          list_classifiers_response.each do |object|
            if @classifier_type == object["classifier_type"]
              @classifer_instance_type_id[@classifier_type] = object["classifier_id"]
              ahpos = object["ahpos"]
              ahpos.each do |a|
                @ahpoList.push(a["name"])
              end

              adaptive_heuristics = object["adaptive_heuristics"]
              adaptive_heuristics.each do |ah|
                ah_name = ah["name"]
                @originalAH[ah_name] = ah["parameters"]
              end
            end
          end
        end
      else # In non-connected Demo mode
        @ahpoList = ['caret', 'sei-ahpo']
        @originalAH['No Parameters'] = {}
        @originalAH['Z-ranking'] = {'severity': 'moderate', 'count': '5', 'present': 'true'}
        @originalAH['Heckmans ARM'] = {'covering': ['curve', 'lowest']}
      end

      #update the parameters to whatever was chosen before
      @adaptiveHeuristics = Hash.new

      @originalAH.each do |key, value|
        if(key == @selectedAH)
          @adaptiveHeuristics[key] = eval(@selectedParameters)
        else
          @adaptiveHeuristics[key] = value
        end
      end

      render partial: 'classifier.html.erb'
    end
  else
    # SCALe-only mode
    head 405
  end
end


def editClassifier
  case session[:scaife_mode]
  when "Connected", "Demo"
    @scaife_mode = session[:scaife_mode]
    @classifier_instance_id = nil
    @classifier_instance_name = params[:classifier_instance_name]
    @classifier_id = nil
    @classifier_type = params[:classifier_type]
    @project_id = params[:project_id]
    @selected_project_ids = []
    @source_domain = params[:source_domain]
    @adaptive_heuristic_name = params[:adaptive_heuristic_name]
    @adaptive_heuristic_parameters = params[:adaptive_heuristic_parameters]
    @ahpo_name = params[:ahpo_name]
    @ahpo_parameters = params[:ahpo_parameters]

    @scheme = ClassifierScheme.where("classifier_instance_name = ?", "#{@classifier_instance_name}").first

    if not @scheme.nil?
       @classifier_id = @scheme.scaife_classifier_id
       @classifier_instance_id = @scheme.scaife_classifier_instance_id
       @selectedProjects = @scheme.source_domain.split(",")
    end

    status = 200
    msg = ""

    if "Connected" == @scaife_mode
      scaife_statistics_controller = ScaifeStatisticsController.new

      scaife_datahub_controller = ScaifeDatahubController.new
      list_projects_response = scaife_datahub_controller.listProjects(session[:login_token])
      if nil == list_projects_response || list_projects_response.is_a?(String) #Failed to connect to Registration/Stats server
        puts "Failed to retrieve project list from DataHub"
      else
        for project_object in list_projects_response
          proj_id = project_object["project_id"]
          proj_name = project_object["project_name"]
          if @selectedProjects.include? proj_name
            @selected_project_ids.append(proj_id)
          end
        end
      end

      edit_classifier_response = scaife_statistics_controller.editClassifier(session[:login_token], @classifier_instance_id, @classifier_id, @classifier_type, @classifier_instance_name, @selected_project_ids, @ahpo_name, {}, @adaptive_heuristic_name, {})
      #puts "SCAIFE edit classifier response: "
      #puts edit_classifier_response

      if edit_classifier_response.is_a?(String) #Failed to connect to Registration/Stats server
        @classifier_type = ""
      else
        begin
          ClassifierScheme.editClassifier(@classifier_instance_name, @classifier_type, @source_domain, @adaptive_heuristic_name, @adaptive_heuristic_parameters, @ahpo_name, @ahpo_parameters, @classifier_id, @classifier_instance_id)
          @project = Project.find_by_id(@project_id)
          @project.update_attribute("current_classifier_scheme", @classifier_instance_name)
          msg = "Success"
          status = 200
        rescue ActiveRecord::RecordNotFound => e
          msg = "Not Found: #{e.message}"
          staus = 404
        rescue ActiveRecord::RecordInvalid => e
          puts "DB validation error: #{e.message}"
          msg = "Bad Request: #{e.message}"
          status = 400
        rescue ActiveRecord::ActiveRecordError => e
          puts "DB error: #{e.message}"
          msg = "Internal Server Error"
          status = 500
        ensure
          msg = { status: status, message: msg }
          puts "MEANWHILE (#{status}): #{msg}"
          respond_to do |format|
            format.json { render json: msg, status: status }
          end
        end
      end
    elsif "Demo" == @scaife_mode
      begin
        ClassifierScheme.editClassifier(@classifier_instance_name, @classifier_type, @source_domain, @adaptive_heuristic_name, @adaptive_heuristic_parameters, @ahpo_name, @ahpo_parameters, nil, nil)
        @project = Project.find_by_id(@project_id)
        @project.update_attribute("current_classifier_scheme", @classifier_instance_name)
        msg = "Success"
        status = 200
      rescue ActiveRecord::RecordNotFound => e
        msg = "Not Found: #{e.message}"
        staus = 404
      rescue ActiveRecord::RecordInvalid => e
        puts "DB validation error: #{e.message}"
        msg = "Bad Request: #{e.message}"
        status = 400
      rescue ActiveRecord::ActiveRecordError => e
        puts "DB error: #{e.message}"
        msg = "Internal Server Error"
        status = 500
      ensure
        msg = { status: status, message: msg }
        respond_to do |format|
          format.json { render json: msg, status: status }
        end
      end
    end
  else
    # SCALe-only mode
    head 405
  end

end


def deleteClassifier
    @scaife_mode = session[:scaife_mode]
    @project_id = params[:project_id]
    @classifier_instance_name = (params[:classifier_name] == nil || params[:classifier_name].empty?) ? "" : params[:classifier_name]

    scheme = ClassifierScheme.where("classifier_instance_name = ?", "#{@classifier_instance_name}").first

    if not scheme.nil?
        @classifier_instance_id = scheme.scaife_classifier_instance_id
    end

    if "Connected" == @scaife_mode
        scaife_statistics_controller = ScaifeStatisticsController.new
        delete_classifier_response = scaife_statistics_controller.deleteClassifier(session[:login_token], @classifier_instance_id)
        #puts "SCAIFE delete classifier response: "
        #puts delete_classifier_response

        if delete_classifier_response.is_a?(String) #Failed to connect to Registration/Stats server
            @classifier_type = ""
        else

            begin
                @project = Project.find_by_id(@project_id)

                success = ClassifierScheme.deleteClassifier(@classifier_instance_name)

                if success
                    if @project.current_classifier_scheme == @classifier_instance_name
                        @project.update_attribute("current_classifier_scheme", nil)
                    end
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
        end
    elsif "Demo" == @scaife_mode
        if not @project_id.to_s.match('\d+')  # from web request, so must sanitize
            print "invalid project id: #{@project_id.to_s}"
        else
            begin
                @project = Project.find_by_id(@project_id)

                success = ClassifierScheme.deleteClassifier(@classifier_instance_name)

                if success
                    if @project.current_classifier_scheme == @classifier_instance_name
                        @project.update_attribute("current_classifier_scheme", nil)
                    end
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
         end

    elsif "SCALe-only" == @scaife_mode
        # SCALe-only mode
        head 405
    end
end
end
