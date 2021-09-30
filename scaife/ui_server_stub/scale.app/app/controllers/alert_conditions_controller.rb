# -*- coding: utf-8 -*-

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


# This controller is for viewing and updating alertConditions
# Index - Controller to view alerts
# massUpdate - using multiple select boxes to update the verdict
require 'scaife/api/datahub'
require 'scaife/api/registration'
require 'scaife/format_conversion'
require 'ostruct'
require 'utility/timing'

$alertConditionHash = Hash.new
$fusedAlertConditionHash = Hash.new
$displayedAlertConditions = []


class AlertConditionsController < ApplicationController

  respond_to :html, :json
  require 'open3'
  require 'csv'
  require 'will_paginate/array'
  include LogDet
  include Scaife::FormatConversion
  include Utility::Timing

  # Produce hash of filtering & other forms in Web UI
  def ui_vars
    # Most UI fields can be assigned the same way
    most_fields = {
      :project_id => [:project_id, :project_id, Project.first.id],
      :sort_keys_selected => [:sort_keys_selected, :sort_keys_selected,
                              Rails.configuration.x.default_ordering],
      :selected_id_type => [:id_type, :id_type, "ALL IDs"],
      :ID => [:ID, :id_field, ""],
      :meta_alert_id => [:meta_alert_id, :meta_alert_ids, ""],
      :display_ids => [:display_id, :display_ids, ""],

      :verdict => [:verdict,:verdict, "-1"],
      :previous => [:previous, :previous, "-1"],
      :path => [:filter_path, :filter_path, ""],
      :line => [:line, :line, ""],
      :checker => [:checker, :checker, ""],
      :condition => [:condition, :condition, ""],
      :tool => [:tool, :tool, ""],
      :selected_taxonomy => [:taxonomy, :taxonomy, "View All"],
      :category => [:category, :category, "All"],
      :seed => [:seed, :seed, ""],

      :alertConditionsPerPage => [:alertConditionsPerPage, :alert_conditions_per_page, "10"],
    }
    ui = {}
    most_fields.each do |k, v|
      ui[k] = helpers.getFilterSelection(v[0], v[1], v[2])
    end
    [:project_id, :alertConditionsPerPage].each do |k|
      ui[k] = ui[k].to_i
    end
    ui[:path] = ui[:path].strip()
    ui[:filter_path] = ui[:path] # TODO eventually take out :path, used to represent path in URL (RC-1855)

    session[:view] = (session[:view] == "" || session[:view] == nil) ? "fused" : session[:view]
    ui[:view] = session[:view]

    session[:scaife_mode] = (session[:scaife_mode] == "" || session[:scaife_mode] == nil) ? "Demo" : session[:scaife_mode]
    ui[:scaife_mode] = session[:scaife_mode]

    ui[:scaife_mode_msg] = session[:scaife_mode_msg]

    @project = Project.find_by_id(ui[:project_id])
    save_project = false

    if ![nil, "", "0"].include?(@project.default_shuffle_seed)
      ui[:seed] = @project.default_shuffle_seed.to_i
      session[:seed] = ui[:seed]
      @project.default_shuffle_seed = ""
      save_project = true
    end
    if ![nil, "", "0", "0.0"].include?(@project.default_efp_ct)
      @project.efp_confidence_threshold = @project.default_efp_ct.to_f
      @project.default_efp_ct = ""
      save_project = true
    end
    if ![nil, "", "0", "0.0"].include?(@project.default_etp_ct)
      @project.confidence_threshold = @project.default_etp_ct.to_f
      @project.default_etp_ct = ""
      save_project = true
    end
    if ![nil, ""].include?(@project.default_ordering)
      ui[:sort_keys_selected] = @project.default_ordering
      session[:sort_keys_selected] = ui[:sort_keys_selected]
      @project.default_ordering = ""
      save_project = true
    end
    if ![nil, ""].include?(@project.default_filtering)
      # For now if this is nonempty, we assume the filter is Category='I'
      # TODO (RC-1875) update filter values from default_filtering
      # which should go to :verdict, :path, :line, etc.
      ui[:category] = "I"
      session[:category] = ui[:category]
      @project.default_filtering = ""
      save_project = true
    end

    if save_project
      @project.save
    end

    # If a classifier was run on this project previously use that value as default
    ui[:classifier_chosen] = ""
    ui[:predicted_verdicts] = 0
    if @project.last_used_confidence_scheme.present?
      selected_classifier = ClassifierScheme.find_by_id(@project.last_used_confidence_scheme)

      if selected_classifier.present?
        ui[:classifier_chosen] = selected_classifier.classifier_instance_name
        ui[:scaife_classifier_instance_id] = selected_classifier.scaife_classifier_instance_id
        ui[:confidence_threshold] = Project.where(id: @project_id).pluck(:confidence_threshold)
        ui[:predicted_verdicts] = Display.where(project_id: @project_id)
                                    .where('displays.confidence >= ?', ui[:confidence_threshold])
                                    .uniq.pluck(:meta_alert_id).size
      end
    end

    return ui
  end


  def index
    if @errors.blank?
      @errors = Set[]
    end

    # Get UI elements, make hash into class instance vars
    ui = ui_vars
    ui.each do |k, v|
      self.instance_variable_set("@" + k.to_s, v)
    end

    if ENV["SCALE_EXPERIMENT"] == "1"
      check_experiment_finished(@project_id)
    end

    @scaife_active = self.scaife_active()

    if @scaife_active
      flash[:scaife_updates_available] = has_scaife_updates(@project_id)
    end

    ## can add notes and cwe_likelihood later for filtering
    # @cwe_likelihood = (params[:cwe_likelihood] == nil || params[:cwe_likelihood] == "") ? -1 : params[:cwe_likelihood]

    # @notes = (params[:notes] == nil || params[:notes] == "") ? -1 : params[:notes]

    # this whole sequence needs to be fast and hopefully unnecessary; if
    # it happens all the time it will cause selenium test failures due
    # to delays loading the alerts page
    external_db_valid = false
    # make sure the ConditionCheckerLink model is loaded
    Condition.class
    backup_db = backup_external_db_from_id(@project_id)
    if File.exists? backup_db
      if Project.max_external_linked_checker_id.blank?
        # cache this value for the upcoming conditional
        backup_db = backup_external_db_from_id(@project_id)
        if File.exists? backup_db
          FileUtils.cp(backup_db, external_db())
          external_db_valid = true
          with_external_db() do |con|
            row = con.execute("SELECT MAX(checker_id) FROM ConditionCheckerLinks")
            Project.max_external_linked_checker_id = row[0][0]
          end
        end
      end
      last_sync_proj_id = session[:last_sync_project_id].to_i
      if last_sync_proj_id != @project_id and ConditionCheckerLink.maximum(:checker_id) != Project.max_external_linked_checker_id
        # we have switched projects, need to make sure unknown checkers
        # don't cross projects
        if not external_db_valid
          FileUtils.copy(backup_external_db_from_id(@project_id), external_db())
        end
        self.switch_project_context(@project_id)
      end
    end

    #Variable for classifier and prioritization scheme header dropdowns to show only on alertConditions page
    @inAlertConditions = []

    # Get the project object
    @project = Project.find_by_id(@project_id)

    # Determines of the project has been uploaded to SCAIFE, defaults to it has not been uploaded (used in Demo mode also)
    @project_not_uploaded_to_scaife = true

    # Retrieve available classifiers from SCAIFE
    @classifierList = []
    @priorityList = []
    scaife_priority_ids = []

    if "Connected" == @scaife_mode
      c = ScaifeStatisticsController.new
      list_classifiers_result = c.listClassifiers(session[:login_token])

      if list_classifiers_result.is_a?(String)
        puts "#{__method__}() error listClassifiers(): #{c.scaife_status_code}: #{list_classifiers_result}"
        @classifierScaifeError = list_classifiers_result
      else
        if list_classifiers_result.blank?
          @classifierScaifeError = "Classifiers Unavailable in the SCAIFE Stats Module"
        else
          # make sure there are some SCAIFE projects to select
          c = ScaifeDatahubController.new
          list_projects_result = c.listProjects(session[:login_token])
          if list_projects_result.is_a?(String) #Failed to connect to Registration/DataHub server
            puts "#{__method__}() error listProjects(): #{c.scaife_status_code}: #{list_projects_result}"
            @classifierScaifeError = "Failed to retrieve SCAIFE projects from DataHub"
          elsif list_projects_result.blank?
            @classifierScaifeError = "Must upload a project to SCAIFE first"
          else
            list_classifiers_result.each do |object|
              @classifierList.push(object.classifier_type)
            end
          end
        end
      end

      # Get the available classifier instances that can be run in SCAIFE
      scale_existing_classifiers = ClassifierScheme.pluck("classifier_instance_name", "scaife_classifier_instance_id")

      @available_classifiers_to_run = []

      if scale_existing_classifiers.present?
        scale_existing_classifiers.each do |class_name, class_id|
          if class_id.present?
            @available_classifiers_to_run.push(class_name) # Classifier Instance has been created in SCAIFE and can be used
          end
        end
      end

      if @project.scaife_project_id.present?
        @project_not_uploaded_to_scaife = false
      end

      c = ScaifePrioritizationController.new

      scaife_project_id = c.get_scaife_project_id(@project_id)
      result = c.listPriorities(session[:login_token], scaife_project_id)

      if result.is_a?(String)
        puts "#{__method__}() error listPriorities(): #{c.scaife_status_code}: #{result}"
      else
        result.each do |priority_scheme|
          @priorityList.push([priority_scheme.priority_scheme_id, priority_scheme.priority_scheme_name])
          scaife_priority_ids.push(priority_scheme.priority_scheme_id)
        end
      end

      scale_priority_list = []
      scale_priority_list.push(*PriorityScheme.pluck("id", "name", "scaife_p_scheme_id", "p_scheme_type"))

      if not scaife_priority_ids.empty?
        scale_priority_list.each do |p|
          if not scaife_priority_ids.include? p[2]
            if p[3] == "global" or p[3] == "local"
              @priorityList.push([p[0], p[1]])
            end
          end
        end
      else
        @priorityList.push(*PriorityScheme.pluck("id", "name")) #["priority1", "priority2", "priority3"]
      end

      @priorityList.push(["0", "Create New Scheme"]) #add a create new scheme to the list of available values
    else
      @classifierList = ["Demo-Xgboost", "Demo-Random Forest", "Demo-Logistic Regression"]

      # In Demo mode all classifiers can be run since the data is artificial
      @available_classifiers_to_run = ClassifierScheme.pluck("classifier_instance_name")

      @priorityList = PriorityScheme.pluck("id", "name") #["priority1", "priority2", "priority3"]
      @priorityList.push(["0", "Create New Scheme"]) #add a create new scheme to the list of available values
    end # end if SCAIFE connected

    @existingClassifiers = ClassifierScheme.pluck("classifier_instance_name, classifier_type")

    # Using triple-click to select and copy a path from the web app
    # will include a leading and trailing space, so remove them.

    # Load the alertConditions view page

    @options_for_ids = ["All IDs", "Display (d) ID", "Meta-Alert (m) ID"]
    @ids = Hash.new
    @ids["All IDs"] = ""
    @ids["Display (d) ID"] = @display_ids
    @ids["Meta-Alert (m) ID"] = @meta_alert_ids
    #<%= select_tag(:id_type, options_for_select(@options_for_ids, selected: @ids[@selected_id_type])) %>
    #<%= number_field_tag(:ID, @ID) %>

    @options_for_categories = ["View All", "CWEs", "CERT Rules"]

    # # Construct the SQL query
    tc = taxonomy_conditions(@project, ui[:selected_taxonomy])
    filter = Display.constructSQLFilter(@project_id, ui, tc,
                                        @project[:efp_confidence_threshold],
                                        @project[:confidence_threshold])

    # If no page selected, default to the first
    page = params[:page].to_i || 1
    page = page > 1 ? page : 1

    respond_to do |format|
      format.html {

        if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
          print "invalid project id: #{@project.id.to_s}"
        else
          @checkers = @project.displays.pluck(:checker).uniq.map {|a| [a,a]}.sort.unshift(["All Checkers", ""])
          @tools = @project.displays.pluck(:tool).uniq.map {|a| [a,a]}.sort.unshift(["All Tools", ""])
          @conditions = @project.displays.pluck(:condition).uniq.map {|a| [a,a]}.sort.unshift(["All", ""])

          @projects = Project.all.map {|p| [p.name, p.id]}.sort
        end
      }
      format.js {
        # Respond to AJAX requests to load the alerts tables
        # $alertConditionHash contains non-fused alertConditions
        # $fusedAlertConditionHash may contain some fused alertConditions
        # The frontend will decide which of the two to display

        $alertConditionHash = Hash.new
        $fusedAlertConditionHash = Hash.new

        @displays = display_list( filter, ui[:sort_keys_selected], ui[:seed])

        $displayedAlertConditions = @displays

        @alertConditionStart = @alertConditionsPerPage * (page-1) + 1

        case @view
        when "fused"
          @fusedAlertConditions = @displays.group_by(&:meta_alert_id)
          @temp = @fusedAlertConditions.keys.paginate(page: page, per_page: @alertConditionsPerPage)

          @temp.each do |m_id|
            $fusedAlertConditionHash[m_id] = @fusedAlertConditions[m_id]
          end

          @alertConditionTotal = @fusedAlertConditions.length

        when "unfused"
          @temp = @displays.paginate(page: page, per_page: @alertConditionsPerPage)

          @temp.each do |d|
            row_id = d[:id].to_i
            $alertConditionHash[row_id] = d
          end

          @alertConditionTotal = @displays.length
        end

        @alertConditionEnd = @alertConditionsPerPage * (page-1) + (@temp.length)
      }
    end

    update_confidence_fields(@project_id)
  rescue => e
    puts("CAUGHT ERROR " + e.to_s + "\n")
    puts(e.backtrace.join("\n"))
  end


  # Return list of display elements to
  def display_list(filter, ordering, seed)
    ordering = ordering.split(', ').map { |key|
      Rails.configuration.x.all_sort_keys[key]
    }.join(', ')

    list = Display.where(filter).order(ordering)

    if seed != ""
      if seed.to_i == 0
        rng = Random.new
      else
        rng = Random.new(seed.to_i)
      end
      list = list.shuffle(random: rng)
    end
    return list
  end

  # Return conditions supported by current taxonomy (or "" for all)
  def taxonomy_conditions(project, selected_taxonomy)
    cert_rules = []
    cwes = []

    project.displays.pluck(:condition).uniq.each do |r|
      cond_prefix = r[0..2]
      if cond_prefix == "CWE"
        cwes.append(r)
      else
        cert_rules.append(r)
      end
    end

    tax_conditions = Hash.new
    tax_conditions["View All"] = ""
    tax_conditions["CWEs"] = cwes
    tax_conditions["CERT Rules"] = cert_rules

    conditions = [""]
    if(selected_taxonomy == "View All")
      conditions = tax_conditions["View All"]
    elsif(selected_taxonomy == "CWEs")
      if !tax_conditions["CWEs"].empty?
        conditions = tax_conditions["CWEs"]
      end
    else
      if !tax_conditions["CERT Rules"].empty?
        conditions = tax_conditions["CERT Rules"]
      end
    end
    return conditions
  end


  def sortByKeysModal
    # These two vars are lists...but elsewhere they are strings
    @sort_keys_selected = session[:sort_keys_selected].split(', ')
    @sort_keys_unselected = Rails.configuration.x.all_sort_keys.keys - @sort_keys_selected

    respond_to do |format|
      format.html
      format.js
    end
  end

  def sortByKeysSubmit
    @sort_keys_selected = params[:sort_keys_selected]
    session[:sort_keys_selected] = @sort_keys_selected

    # currently copied from submitLogin
    respond_to do |format|
      format.js
    end
  end

  # See if experiment has completed
  def check_experiment_finished(project_id)
    project = Project.find_by_id(project_id)
    experiment = Experiment.configs[project[:experiment]]
    if experiment.nil?
      return
    end
    max_adjudications = experiment.max_adjudications
    if max_adjudications.nil?
      max_adjudications == 0
    else
      max_adjudications = max_adjudications.to_i
    end
    knowns = Display.where("verdict != 0", project: project_id) # not Unknown
    puts("Experiment: #{knowns.size.to_s} known out of #{max_adjudications.to_s}!\n")
    if max_adjudications > 0 && max_adjudications <= knowns.size
      finish_experiment(project, project_id)
    end
  end

  def manual_finish_experiment()
    project_id = params[:project_id]
    project = Project.find_by_id(project_id)
    finish_experiment(project, project_id)
  end

  # Mark experiment as finished & stop
  def finish_experiment(project, project_id)
    puts("Ending experiment #{project[:name]}")
    @errors.add("ENDING EXPERIMENT #{project[:name]}. DO NOT ADJUDICATE MORE META-ALERTS. Check the export directory for exported experiment data files. For large codebases, this will take awhile to export. DO NOT STOP OR RESTART ANY OF THE CONTAINERS UNTIL ALL 3 FILES HAVE BEEN EXPORTED AFTER THE EXPERIMENT ENDS. Also, please be careful to save those end-of-experiment files someplace safe that will remain, so you can share information about classification performance with the SEI research team.")
    project[:experiment] = nil
    project.save

    experiment = Experiment.find_by(primary_project_id: project_id)
    experiment_data = experiment.as_json

    performance_metrics = []
    classifier_metrics = []

    PerformanceMetric.all.each do |pm|
      performance_metrics.append(pm.as_json)
    end

    ClassifierMetric.all.each do |cm|
      classifier_metrics.append(cm.as_json)
    end

    manual_verdicts = Determination.where(project_id: project_id, verdict: 2)
                        .or(Determination.where(project_id: project_id, verdict: 4)).size
    predicted_verdicts = Display.where(project_id: project_id)
                           .where('displays.confidence >= ?',
                                  Project.where(id: @project_id).pluck(:confidence_threshold))
                           .uniq.pluck(:meta_alert_id).size

    exports_path = "/home/exports"
    export_file_name = "#{exports_path}/scale_#{project[:name].gsub(" ", "_")}.json"
    export_data = {
      :experiment_data => experiment_data,
      :performance_metrics => performance_metrics,
      :classifier_metrics => classifier_metrics,
      :manual_verdicts => manual_verdicts,
      :predicted_verdicts => predicted_verdicts,
    }

    puts("experiment_data is " + experiment_data.to_s() + "\n")
    puts("manual_verdicts is " + manual_verdicts.to_s() + "\n")
    puts("predicted_verdicts is " + predicted_verdicts.to_s() + "\n")

    File.open(export_file_name, "w") { |f| f.write export_data.to_json }

    puts("Local experiment finished & exported!\nInitiating export of Datahub server and Stats server experiment data.")

    scaife_project_id = project[:scaife_project_id]
    c = ScaifeDatahubController.new
    result_c = c.initiateExperimentExport(session[:login_token], scaife_project_id)
    puts("Datahub export result: #{result_c}")

    s = ScaifeStatisticsController.new
    result_s = s.initiateExperimentExport(session[:login_token], scaife_project_id)
    puts("Stats export result: #{result_s}")

  end

  # Check for updates to confidence field
  def update_confidence_fields(scale_project_id)
    scale_project = Project.find_by_id(scale_project_id)
    if scale_project[:confidence_lock] == 2
      scale_project.update_attribute(:confidence_lock, 3)
      alertConditions = Display.where(project_id: scale_project_id)
      alertConditions.each do |d|
        if d[:project_id] == scale_project_id and
          d[:next_confidence] != nil and
          d[:next_confidence] != d[:confidence]
          d.update_attribute(:confidence, d[:next_confidence])
          d.update_attribute(:class_label, d[:class_label])
          d.update_category_project(scale_project_id)
        end
      end
      scale_project.update_attribute(:confidence_lock, 0)
    end
  end

  #clear filters in the GUI
  def clearFilters
    session[:id_field] = nil
    session[:meta_alert_ids] = nil
    session[:display_ids] = nil
    session[:verdict] = nil
    session[:previous] = nil
    session[:category] = nil
    session[:filter_path] = nil
    session[:line] = nil
    session[:tool] = nil
    session[:seed] = nil
    session[:checker] = nil
    session[:condition] = nil
    session[:id_type] = nil
    session[:taxonomy] = nil
    session[:project_id] = nil
    redirect_to action: "index"
  end

  #fused view
  def fused
    session[:view] = "fused"
    redirect_to action: "index"
  end

  #unfused view
  def unfused
    session[:view] = "unfused"
    index
  end

  def updateAlertConditions
    row_id = params[:row_id].to_i
    meta_alert_id = params[:meta_alert_id].to_i
    elem = params[:elem].to_s
    new_value = params[:value]
    view_type = session[:view]
    @scaife_mode = session[:scaife_mode]
    @scale_project_id = nil

    # Update other AlertConditions with the same meta-alert-id
    ActiveRecord::Base.transaction do
      if view_type == 'fused'
        $fusedAlertConditionHash[meta_alert_id].each do |sub|
          d = Display.find_by_id(sub[:id].to_i)
          @scale_project_id = d[:project_id]
          d.update_attribute(:time, DateTime.now)
          case elem
            when "flag"
              d.update_attribute(:flag, new_value)
            when "verdict"
              d.update_attribute(:verdict, new_value.to_i)
            when "notes"
              d.update_attribute(:notes, new_value)
            when "supplemental"
              d.update_attribute(:ignored, new_value[0])
              d.update_attribute(:dead, new_value[1])
              d.update_attribute(:inapplicable_environment, new_value[2])
              d.update_attribute(:dangerous_construct, new_value[3])
          end
          new_det_id = LogDetermination(d, meta_alert_id, d[:project_id])
          LogIntermediateData(d[:project_id], new_det_id)
        end
      else
        alertConditions = Display.where(meta_alert_id: meta_alert_id)

        alertConditions.each do |d|
          @scale_project_id = d[:project_id]
          d.update_attribute(:time, DateTime.now)
          case elem
            when "flag"
              d.update_attribute(:flag, new_value)
            when "verdict"
              d.update_attribute(:verdict, new_value.to_i)
            when "notes"
              d.update_attribute(:notes, new_value)
            when "supplemental"
              d.update_attribute(:ignored, new_value[0])
              d.update_attribute(:dead, new_value[1])
              d.update_attribute(:inapplicable_environment, new_value[2])
              d.update_attribute(:dangerous_construct, new_value[3])
          end
          $alertConditionHash[d[:id]] = d
          new_det_id = LogDetermination(d, meta_alert_id, d[:project_id])
          LogIntermediateData(d[:project_id], new_det_id)
        end
      end
    end

    if "Connected" == @scaife_mode
      scale_project = Project.find_by_id(@scale_project_id.to_i)
      scaife_project_id = scale_project[:scaife_project_id]
      if scaife_project_id and scale_project[:publish_data_updates]

        scaife_project_data = JSON.parse(project_scale_to_scaife(@scale_project_id.to_i, nil, meta_alert_id.to_i, true))

        scaife_meta_alerts_dets = []
        m_alert = scaife_project_data["meta_alerts"][0]
        scale_meta_alert_id = m_alert["meta_alert_id"]

        record = Display.where(meta_alert_id: scale_meta_alert_id, project_id: @scale_project_id)[0]
        scaife_meta_alert_id = record[:scaife_meta_alert_id]

        det = m_alert["determination"]
        determination = {"flag_list": det["flag_list"], "inapplicable_environment_list": det["inapplicable_environment_list"], "ignored_list": det["ignored_list"], "verdict_list": det["verdict_list"], "dead_list": det["dead_list"], "dangerous_construct_list": det["dangerous_construct_list"], "notes_list": det["notes_list"]}

        scaife_m_alert_det = {"meta_alert_id": scaife_meta_alert_id, "determination": determination}
        scaife_meta_alerts_dets.append(scaife_m_alert_det)

        c = ScaifeDatahubController.new
        result = c.sendMetaAlertsForProject(session[:login_token], scaife_project_id, scaife_meta_alerts_dets)
      end
    end

    respond_to do |format|
      format.json { render json: { message: "Displays Updated" }, status: "200" }
    end
  rescue => e
    puts("CAUGHT ERROR " + e.to_s + "\n")
    puts(e.backtrace.join("\n"))
  end


  def LogDetermination(display, meta_alert_id, project_id)
    new_det_id = log_det(display, session[:login_user_id])
    prev_dets = Determination.where(meta_alert_id: meta_alert_id,
                                    project_id: project_id).size
    if prev_dets != display[:previous]
      display.update_attribute(:previous, prev_dets)
    end
    return new_det_id
  end

  def LogIntermediateData(project_id, det_id)
    if not ENV["SCALE_EXPERIMENT"] == "1"
      return
    end
    if not det_id.is_a? Integer
      return
    end

    con = ActiveRecord::Base.connection
    ui = ui_vars

    project = Project.find_by_id(project_id)
    tc = taxonomy_conditions(project, ui[:selected_taxonomy])

    # Figure out top_meta_alert
    filter = Display.constructSQLFilter(project_id, ui, tc,
                                        project[:efp_confidence_threshold],
                                        project[:confidence_threshold])
    top_two = display_list( filter, ui[:sort_keys_selected], ui[:seed]).first(2)
    adjudicated_meta_alert_id = -1
    row = con.execute("SELECT meta_alert_id FROM Determinations WHERE Determinations.id ='#{det_id}';")
    adjudicated_meta_alert_id = row[0][0]
    if top_two[0][:meta_alert_id] != adjudicated_meta_alert_id
      top_meta_alert = top_two[0][:meta_alert_id]
    else
      top_meta_alert = top_two[1][:meta_alert_id]
    end

    cmd = "INSERT INTO audit_status_log ("\
          "'determination_id', 'project_id', 'sort_keys', 'filter_selected_id_type', "\
          "'filter_id', 'filter_meta_alert_id', 'filter_display_ids', "\
          "'filter_verdict', 'filter_previous', 'filter_path', 'filter_line', "\
          "'filter_checker', 'filter_condition', 'filter_tool', 'filter_taxonomy', "\
          "'filter_category', 'seed', 'alertConditionsPerPage', 'fused', "\
          "'scaife_mode', 'classifier_chosen', 'predicted_verdicts', "\
          "'etp_confidence_threshold', 'efp_confidence_threshold','top_meta_alert') VALUES ("\
          "'#{det_id}', '#{project_id}', '#{ui[:sort_keys_selected]}', '#{ui[:selected_id_type]}', "\
          "'#{ui[:ID]}', '#{ui[:meta_alert_id]}', '#{ui[:display_ids]}', "\
          "'#{ui[:verdict]}', '#{ui[:previous]}', '#{ui[:path]}', '#{ui[:line]}', "\
          "'#{ui[:checker]}', '#{ui[:condition]}', '#{ui[:tool]}', '#{ui[:selected_taxonomy]}', "\
          "'#{ui[:category]}', '#{ui[:seed]}', '#{ui[:alertConditionsPerPage]}', '#{ui[:view]}', "\
          "'#{ui[:scaife_mode]}', '#{ui[:classifier_chosen]}', '#{ui[:predicted_verdicts]}', "\
          "'#{project[:confidence_threshold]}', '#{project[:efp_confidence_threshold]}', '#{top_meta_alert}')"

    result = con.execute(cmd)
  end


  def massUpdate
    # This controller action will set all checked off alerts to the
    # desired flag and verdict via an AJAX request.

    # Fetch the desired verdict, flag, and notes sent via the form
    project_id = params[:project_id]
    verdict = params[:mass_update_verdict].to_i
    flag = params[:flag]
    ignored = params[:ignored]
    dead = params[:dead]
    ienv = params[:inapplicable_environment]
    dc = params[:mass_update_dc]
    # notes = params[:notes]

    if params[:select_all_checkbox]
      $displayedAlertConditions.each do |ac|
        helpers.update_attrs(ac, verdict, flag, ignored, dead, ienv, dc)
      end
    else
      # For each selected alert, update its verdict, flag, and notes (if set)
      selectedIds = params[:selectedAlertConditions] || []
      ActiveRecord::Base.transaction do
        case session[:view]
        when "unfused"
          selectedIds.each do |display_id|
            d = Display.find_by_id(display_id)
            new_det_id = helpers.update_attrs(d, verdict, flag, ignored, dead, ienv, dc)
            LogIntermediateData(d[:project_id], new_det_id)
          end
        when "fused"
          selectedIds.each do |id|
            ds = Display.where(project_id: project_id).where(meta_alert_id: id)
            ds.each do |d|
              new_det_id = helpers.update_attrs(d, verdict, flag, ignored, dead, ienv, dc)
              LogIntermediateData(d[:project_id], new_det_id)
            end
          end
        end
      end
    end
  rescue => e
    puts("CAUGHT ERROR " + e.to_s + "\n")
    puts(e.backtrace.join("\n"))
  end

  def export
    # This controller action will dump a ZIP file consisting of CSV files.
    # The 'display' CSV will contain data from the web app display.
    # The other CSVs represent the metrics tables; one CSV per table.

    columns = [:meta_alert_id, :flag, :verdict, :dead, :ignored,
               :inapplicable_environment, :dangerous_construct, :notes,
               :previous, :path, :line, :link, :message, :checker,
               :tool, :condition, :title, :severity, :likelihood,
               :remediation, :priority, :level,
               :cwe_likelihood ]
    #columns = [:id, :flag, :verdict]
    @project = Project.find_by_id(params[:project_id])
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else
      # Project Table
      project_columns = [:id, :name, :description, :created_at, :updated_at, :version]
      project_csv = CSV.generate do |csv|
        csv << project_columns
        row = project_columns.map do |col|
          @project[col]
        end
        csv << row
      end

      # Display Table
      @displays = @project.displays
      display_csv = CSV.generate do |csv|
        csv << columns
        @displays.each do |d|
          row = columns.map do |col|
            case col
            when :flag
              if d[col]
              then "X"
              else ""
              end
            when :verdict
              numToVerdict(d[col])
            else
              d[col]
            end
          end
          csv << row
        end
      end

      timestamp = Time.now.strftime('%Y-%m-%d_%H:%M:%S')

      zipname = "#{@project.name}-#{timestamp}.zip"
      zipfilename = Rails.root.join("db/backup/#{zipname}")
      Dir.chdir("tmp") do
        Zip::ZipFile.open(zipfilename, Zip::ZipFile::CREATE) do |zipfile|
          zipfile.get_output_stream("display.csv") do |output_entry_stream| #Filename
            output_entry_stream.write(display_csv)            #generated content
          end

          zipfile.get_output_stream("display.csv") do |output_entry_stream| #Filename
            output_entry_stream.write(display_csv)            #generated content
          end


          with_external_db() do |con|
            ["Lizard", "Ccsm", "Understand"].each do |metric|  # TODO read table names from scripts/tools.org
              table = con.quote_string("#{metric}Metrics")
              query = "SELECT name FROM sqlite_master WHERE "+
                      "type='table' AND name='#{table}'";
              if con.execute(ActionController::Base.helpers.sanitize(query)).count > 0
                query = "SELECT * FROM '#{table}'"
                res = con.execute(ActionController::Base.helpers.sanitize(query))
                if res.length > 0
                  columns = res[0].keys
                  columns = columns[0..columns.index(0) - 1]  # to remove numeric keys
                  metric_csv = CSV.generate do |csv|
                    csv << columns
                    res.each do |r|
                      row = columns.map do |c|
                        r[c]
                      end
                      csv << row
                    end # res.each
                  end # CSV.generate
                  zipfile.get_output_stream("#{table}.csv") do |output_entry_stream|
                    output_entry_stream.write(metric_csv)
                  end
                end # if
              end # if
            end # each
          end
          # connection now back to development db
        end # open
      end # Dir.chdir

      send_data( zipfilename.read, type: 'application/zip', filename: zipname)
      if File.exists?(zipfilename)
        File.delete(zipfilename)
      end
    end
  end

  def self.archiveDB(project_id, initialize: false, force: false)
    # NOTE: This method should not be run inside another transaction
    # with an open DB connection

    @project = Project.find_by_id(project_id)

    backup_db = backup_external_db_from_id(@project.id)
    if initialize
      # This flag will initialize the external project DB completely
      # from the internal DB. Normally digest_alerts.py takes care of
      # this, but when migrating existing projects from earlier versions
      # of SCALe, after a schema change, and for when projects have to
      # be initialized from data only obtained from SCAIFE,
      # digest_alerts.py does not get called, so use this instead.
      if File.exists? backup_db
        if force
          File.delete(backup_db)
          if File.exists? archive_backup_db_from_id(@project.id)
            File.delete(archive_backup_db_from_id(@project.id))
          end
        end
      end
      puts "initialize schema for #{backup_db}"
      if not Dir.exists? backup_dir_from_id(@project.id)
        FileUtils.mkdir_p backup_dir_from_id(@project.id)
      end
      if  not Dir.exists? archive_backup_dir_from_id(@project.id)
        FileUtils.mkdir_p archive_backup_dir_from_id(@project.id)
      end
      if not File.exists? backup_db
        # starting from scratch
        script = scripts_dir().join("init_project_db.py")
        cmd = "#{script} #{backup_db}"
        stdout, stderr, status = Open3.capture3(cmd)
        if not status.success?
          puts "problem running: #{cmd}"
          if stderr.present?
            puts "---- stderr ----"
            puts "stderr:\n#{stderr}"
          end
          if stdout.present?
            puts "---- stdout ----"
            puts "stdout:\n#{stdout}"
          end
          if stderr.present? or stdout.present?
            puts "----"
          end
        end
      end
      src_db = backup_db
    else
      # This is the most common case, standard behavior, external db
      # exists already
      if not File.exists? backup_db
        archive_db = archive_backup_db_from_id(@project.id)
        if File.exists? archive_db
          # project has been "created", but only database() has been
          # called and not fromDatabase()
          src_db = archive_db
        else
          # this shouldn't happen under normal operations
          raise "neither #{backup_db} or #{archive_db} exist"
        end
      else
        src_db = backup_db
      end
    end

    # shuffle source db to external for updates
    FileUtils.cp(src_db, external_db())

    @displays = @project.displays.reload
    determinations = @project.determinations.reload
    priority_schemes = @project.priority_schemes.reload
    performance_metrics = @project.performance_metrics.reload
    classifier_metrics = @project.classifier_metrics.reload
    user_uploads = UserUpload.all.to_a
    users = User.all.to_a
    classifier_schemes = ClassifierScheme.all.to_a
    project_languages = @project.languages.reload
    project_tools = @project.tools.reload
    project_taxonomies = @project.taxonomies.reload
    msgs_by_alert_id =
      initialize ? @project.messages.group_by(&:alert_id) : nil
    audit_status_log = ActiveRecord::Base.connection.execute("SELECT * FROM audit_status_log WHERE project_id='#{project_id}';").to_a

    # this is an instance method defined in ApplicationController
    with_external_db() do |con|
      ActiveRecord::Base.transaction do
        @displays.each do |d|
          if d.checker == "manual"
            # TODO (RC-1302): Correcting "manual" checkers should be handled much earlier (not when exporting the database).  The code also appears outdated/incorrect, due to changes in the DB schema.
            query = "INSERT INTO Messages (project_id, alert_id, path, line, message)"+
              " VALUES (0, #{con.quote(d.id)}, '#{con.quote_string(d.path)}',"+
              " #{con.quote(d.line)}, '#{con.quote_string(d.message)}')"
            con.execute(ActionController::Base.helpers.sanitize(query))
            query = "SELECT id FROM Messages WHERE alert_id=#{con.quote(d.id)}"
            res = con.execute(ActionController::Base.helpers.sanitize(query))
            alert_id = res[0]["id"]
            query = "INSERT INTO Alerts (id, checker_id, primary_msg, confidence, meta_alert_priority) "+
              " VALUES (#{con.quote(d.meta_alert_id)}, "+
              " '#{con.quote_string(d.checker)}', #{con.quote(alert_id)}, "+
              " #{con.quote(d.confidence)}, #{con.quote(d.meta_alert_priority)})"
            con.execute(ActionController::Base.helpers.sanitize(query))
            query = "INSERT INTO MetaAlerts (id) VALUES (#{con.quote(d.id)})"
            con.execute(ActionController::Base.helpers.sanitize(query))
          end
        end
      end

      # Update project table with display's project table (ext db uses a 0 id)
      fields = con.columns("Projects").collect{|t| t.name}
      con.execute("DELETE FROM Projects")
      values = fields.collect{|f| ActiveRecord::Base.connection.quote(@project[f])}
      values[fields.find_index("id")] = 0
      con.execute("INSERT INTO Projects (" + fields.join(", ") +
                  ") VALUES (" + values.join(", ") + ")")

      # Replace these tables, zeroing out project id
      tables = {"Determinations" => determinations,
                "PrioritySchemes" => priority_schemes,
                "PerformanceMetrics" => performance_metrics,
                "ClassifierMetrics" => classifier_metrics,
                "UserUploads" => user_uploads,
                "ClassifierSchemes" => classifier_schemes,
                "AuditStatusLog" => audit_status_log}
      tables.each do |k,v|
        con.execute("DELETE FROM #{k}")
        fields = con.columns(k).collect{|t| t.name}
        fields.delete("id")
        v.each do |r|
          values = fields.collect{|f| ActiveRecord::Base.connection.quote(r[f])}
          proj_index = fields.find_index("project_id")
          unless proj_index.nil?
            values[proj_index] = 0
          end
          if k == "Determinations"
            # note: user_id in other tables is a string
            user_index = fields.find_index("user_id")
            unless user_index.nil?
              values[user_index] = 0
            end
          end
          con.execute(
            "INSERT INTO #{k} (" + fields.join(", ") +
            ") VALUES (" + values.join(", ") + ")")
        end
      end
      # make sure Users table is blank
      con.execute("DELETE FROM Users")


      def self._obj_exists(con, table, id)
        res = con.execute(
          "SELECT * FROM #{table} WHERE id=#{con.quote(id)}")
        return res.present? ? res : false
      end

      ActiveRecord::Base.transaction do
        if initialize
          # see scripts.satsv2sql.insert_alerts() for where this tool
          # spectrum increment comes from; alert_ids are also spaced out
          # the same way
          incr = 1000

          con.execute("DELETE FROM Messages")
          con.execute("DELETE FROM Alerts")
          con.execute("DELETE FROM MetaAlerts")
          con.execute("DELETE FROM MetaAlertLinks")
          tool_msg_ids = {}
          @displays.each do |d|
            if not tool_msg_ids.include? d.tool_id
              tool_msg_ids[d.tool_id] = d.tool_id
            end
            primary_msg_id = false
            messages = msgs_by_alert_id[d.alert_id]
            messages.each do |msg|
              msg_id = tool_msg_ids[d.tool_id]
              primary_msg_id ||= msg_id
              # note: do not export msg.link
              con.execute(%Q[
                INSERT INTO Messages(id, project_id, alert_id, path,
                  line, message)
                VALUES(
                  #{msg_id},
                  0,
                  #{msg.alert_id},
                  #{con.quote(msg.path)},
                  #{con.quote(msg.line)},
                  #{con.quote(msg.message)})
              ])
              tool_msg_ids[d.tool_id] += incr
            end
            if not primary_msg_id
              raise "no primary message id found"
            end
            checker = con.exec_query(%Q[
              SELECT * FROM Checkers
              WHERE tool_id=#{d.tool_id}
                AND name=#{con.quote(d.checker)}
            ])[0]
            if not _obj_exists(con, "Alerts", d.alert_id)
              con.execute(%Q[
                INSERT INTO Alerts(id, checker_id,
                  primary_msg, scaife_alert_id)
                VALUES(
                  #{d.alert_id},
                  #{checker["id"]},
                  #{primary_msg_id},
                  #{con.quote(d.scaife_alert_id)})
              ])
            end
            cond = con.exec_query(%Q[
              SELECT * FROM Conditions
              WHERE taxonomy_id=#{con.quote(d.taxonomy_id)}
                AND name=#{con.quote(d.condition)}
            ])[0]
            if not _obj_exists(con, "MetaAlerts", d.meta_alert_id)
              con.execute(%Q[
                INSERT INTO MetaAlerts(id, condition_id, class_label,
                  confidence_score, priority_score, scaife_meta_alert_id,
                  code_language)
                VALUES(
                  #{d.meta_alert_id},
                  #{cond["id"]},
                  #{con.quote(d.class_label)},
                  #{con.quote(d.confidence)},
                  #{con.quote(d.meta_alert_priority)},
                  #{con.quote(d.scaife_meta_alert_id)},
                  #{con.quote(d.code_language)})
              ])
            end
            con.execute(%Q[
              INSERT INTO MetaAlertLinks(alert_id, meta_alert_id)
              VALUES(#{d.alert_id}, #{d.meta_alert_id})
            ])
          end
        else
          # updating existing external DB
          @displays.each do |d|
            meta_alert_id = d.meta_alert_id
            scaife_meta_alert_id = d.scaife_meta_alert_id
            class_label = d.class_label
            confidence = d.confidence
            meta_alert_priority = d.meta_alert_priority

            if not class_label
              class_label = ""
            end

            if not confidence
              confidence = "-1"
            end

            if not meta_alert_priority
              meta_alert_priority = "0"
            end

            if not scaife_meta_alert_id
              scaife_meta_alert_id = ""
            end

            con.execute(
              "UPDATE MetaAlerts" \
              " SET confidence_score=" + confidence.to_s + \
              ", class_label='" + class_label.to_s + \
              "', priority_score=" + meta_alert_priority.to_s + \
              ", scaife_meta_alert_id='" + scaife_meta_alert_id.to_s + \
              "' WHERE id=" + meta_alert_id.to_s
            )

            alert_id = d.alert_id
            scaife_alert_id = d.scaife_alert_id

            if not scaife_alert_id
              scaife_alert_id = ""
            end

            con.execute(
              "UPDATE Alerts" \
              " SET scaife_alert_id='" + scaife_alert_id + \
              "' WHERE id=" + alert_id.to_s
            )
          end
        end
      rescue ActiveRecord::ActiveRecordError => e
        puts
        puts "CAUGHT ActiveRecordError EXCEPTION"
        puts self.filter_stacktrace(e)
        puts
        raise ScaifeError.new("aborting archive init due to DB error")
      end

      con.execute("ATTACH '#{internal_db().to_s}' AS DEV")
      # in case any scaife_ids were assigned
      ActiveRecord::Base.transaction do
        con.execute("DELETE FROM Languages")
        con.execute("DELETE FROM Taxonomies")
        con.execute("DELETE FROM Tools")
        con.execute("INSERT INTO Languages SELECT * FROM DEV.languages")
        con.execute("INSERT INTO Taxonomies SELECT * FROM DEV.taxonomies")
        con.execute("INSERT INTO Tools SELECT * FROM DEV.tools")

        con.execute("DELETE FROM ProjectLanguages")
        project_languages.each do |lang|
          con.execute(
            "INSERT INTO ProjectLanguages ('project_id', 'language_id')" +
              " VALUES (0, #{lang.id})"
          )
        end
        con.execute("DELETE FROM ProjectTaxonomies")
        project_taxonomies.each do |taxo|
          con.execute(
            "INSERT INTO ProjectTaxonomies ('project_id', 'taxonomy_id')" +
              " VALUES (0, #{taxo.id})"
          )
        end
        con.execute("DELETE FROM ProjectTools")
        project_tools.each do |tool|
          con.execute(
            "INSERT INTO ProjectTools ('project_id', 'tool_id')" +
              " VALUES (0, #{tool.id})"
          )
        end
        con.execute("DELETE FROM Conditions")
        con.execute("INSERT INTO Conditions SELECT * FROM DEV.conditions")
        con.execute("DELETE FROM Checkers")
        con.execute("INSERT INTO Checkers SELECT * FROM DEV.checkers")
      rescue ActiveRecord::ActiveRecordError => e
        puts
        puts "CAUGHT ActiveRecordError EXCEPTION"
        puts self.filter_stacktrace(e)
        puts
        raise ScaifeError.new("abort during internal attach")
      end
    end
    # connection now back to development db

    # shuffle changes back to backup_db or archive_db
    FileUtils.cp(external_db(), src_db)
    if initialize
      FileUtils.cp(external_db(), archive_backup_db_from_id(@project.id))
    end
    return src_db
  end
  delegate :archiveDB, to: :class



  def exportDB
    # This controller action will dump a sqlite database in the external
    # SCALe DB format. It does so by updating the verdicts of the database
    # generated by the scripts, and inserts the manually created entries.

    @project = Project.find_by_id(params[:project_id])
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else
      ext_db = self.archiveDB(@project.id)
      timestamp = Time.now.strftime('%Y-%m-%d_%H:%M:%S')
      send_file(Rails.root.join(ext_db), filename: "#{@project.name}-#{timestamp}.sqlite3")
    end
  end

  def runClassifier
    #Run classifier button is pressed inside of the alertCondition view
    start_timestamps = get_timestamps()
    @scaife_mode = session[:scaife_mode]
    @scale_project_id = params[:project_id]
    @project = Project.find(@scale_project_id)
    @classifier_instance_name = params[:classifier_scheme_name]
    @is_experiment = params[:experiment]

    scheme = ClassifierScheme.where("classifier_instance_name = ?", "#{@classifier_instance_name}").first

    if not scheme.nil?
      @classifier_instance_id = scheme.scaife_classifier_instance_id
      #TODO: Use selected SCAIFE project when running classifier
      @project_id = @project.scaife_project_id
    end

    if "Connected" == @scaife_mode
      c = ScaifeStatisticsController.new
      result = c.runClassifier(session[:login_token], @classifier_instance_id, @project_id)
      if result.is_a?(String) #Failed to connect to Registration/Stats server
        puts "#{__method__}() error runClassifier(): #{c.scaife_status_code}: #{result}"
        flash[:scaife_run_classifier_message] =  result
        respond_to do |format|
          format.any { return }
        end
      else
        # make sure exported DB is up to date and reflects
        # the current project (project_scale_to_scaife() consumes
        # data from the external DB)
        self.archiveDB(@scale_project_id)

        classifier_metrics = result.classifier_analysis
        classifier_analysis = Hash.new
        classifier_analysis["train_accuracy"] = classifier_metrics["train_accuracy"]
        classifier_analysis["train_f1"] = classifier_metrics["train_f1"]
        classifier_analysis["train_precision"] = classifier_metrics["train_precision"]
        classifier_analysis["train_recall"] = classifier_metrics["train_recall"]
        classifier_analysis["test_accuracy"] = classifier_metrics["test_accuracy"]
        classifier_analysis["test_f1"] = classifier_metrics["test_f1"]
        classifier_analysis["test_precision"] = classifier_metrics["test_precision"]
        classifier_analysis["test_recall"] = classifier_metrics["test_recall"]

        classifier_analysis["num_labeled_meta_alerts_used_for_classifier_evaluation"] = classifier_metrics["num_labeled_meta_alerts_used_for_classifier_evaluation"]
        classifier_analysis["num_labeled_meta_alerts_used_for_classifier_training"] = classifier_metrics["num_labeled_meta_alerts_used_for_classifier_training"]
        classifier_analysis["num_labeled_T_test_suite_used_for_classifier_training"] = classifier_metrics["num_labeled_T_test_suite_used_for_classifier_training"]
        classifier_analysis["num_labeled_F_test_suite_used_for_classifier_training"] = classifier_metrics["num_labeled_F_test_suite_used_for_classifier_training"]
        classifier_analysis["num_labeled_T_manual_verdicts_used_for_classifier_training"] = classifier_metrics["num_labeled_T_manual_verdicts_used_for_classifier_training"]
        classifier_analysis["num_labeled_F_manual_verdicts_used_for_classifier_training"] = classifier_metrics["num_labeled_F_manual_verdicts_used_for_classifier_training"]
        classifier_analysis["num_code_metrics_tools_used_for_classifier_training"] = classifier_metrics["num_code_metrics_tools_used_for_classifier_training"]
        classifier_analysis["top_features_impacting_classifier"] = classifier_metrics["top_features_impacting_classifier"]

        ClassifierMetric.addRecord(@project_id, result.classifier_instance_id, classifier_analysis)
        meta_alerts_probabilities = result.probability_data
        puts "Received " + meta_alerts_probabilities.length.to_s + " confidence values from the Stats Module"
        #puts meta_alerts_probabilities
        ActiveRecord::Base.transaction do
          min = max = miss = 0
          for entry in meta_alerts_probabilities
            meta_alert_id = entry.meta_alert_id
            class_label = entry.label
            probability = entry.probability
            records = Display.where(scaife_meta_alert_id: meta_alert_id)
            if records.present?
              records.update_all(class_label: class_label.to_s)
              records.update_all(confidence: nil)
              records.update_all(category: "I")
            end
            # Only display confidence values associated with meta-alerts that dont have true or false verdicts
            records = Display.where(scaife_meta_alert_id: meta_alert_id).where.not(verdict: 2).where.not(verdict: 4)
            if nil != records
              confidence = probability.to_f.truncate(2)
              category = Display.compute_category(class_label, confidence,
                                                  @project[:confidence_threshold],
                                                  @project[:efp_confidence_threshold])
              records.update_all(confidence: confidence)
              records.update_all(category: category)
            else
              puts "oops no records: #{meta_alert_id}"
              miss += 1
            end
            if min == 0 or probability < min
                min = probability
            end
            if probability > max
              max = probability
            end
          end
          nc = Display.where(project_id: @project.id, confidence: -1).count
          min = min.to_f.truncate(3)
          max = max.to_f.truncate(3)
          puts "classifier results min/max/miss: #{min}/#{max}/#{miss}"
          if nc > 0
            puts "classifier -1 count: #{nc}"
          end
        end

    # Record last used classifier scheme
    @project.update(last_used_confidence_scheme: scheme.id)

        # make sure exported DB is up to date and reflects
        # the current project (project_scale_to_scaife() consumes
        # data from the external DB)
        self.archiveDB(@scale_project_id)

      end
    elsif "Demo" == @scaife_mode
      @project_id = @project.id.to_s
      #csvPath current hard coded, will upgrade to API (DO NOT USE user input)
      csvPath = "../demo/confidence.csv"
      dbPath = internal_db()
      classifier_analysis = Hash.new
      classifier_analysis["train_accuracy"] = 0.91
      classifier_analysis["train_f1"] = 0.18
      classifier_analysis["train_precision"] = 0.50
      classifier_analysis["train_recall"] = 0.11
      classifier_analysis["test_accuracy"] = 0.91
      classifier_analysis["test_f1"] = 0.18
      classifier_analysis["test_precision"] = 0.50
      classifier_analysis["test_recall"] = 0.11

      classifier_analysis["num_labeled_meta_alerts_used_for_classifier_evaluation"] = 1000
      classifier_analysis["num_labeled_meta_alerts_used_for_classifier_training"] = 1950
      classifier_analysis["num_labeled_T_test_suite_used_for_classifier_training"] = 720
      classifier_analysis["num_labeled_F_test_suite_used_for_classifier_training"] = 830
      classifier_analysis["num_labeled_T_manual_verdicts_used_for_classifier_training"] = 175
      classifier_analysis["num_labeled_F_manual_verdicts_used_for_classifier_training"] = 225
      classifier_analysis["num_code_metrics_tools_used_for_classifier_training"] = 3
      classifier_analysis["top_features_impacting_classifier"] = "num_alerts_per_source_file: 1.5;code_language__C++: 0.125"

      res = ClassifierMetric.addRecord(@project_id, "sample_scaife_classifier_instance_id", classifier_analysis)
      if not res
        msg = "failed to insert classifier metric #{@project_id}:sample_scaife_classifier_instance_id"
        flash[:demo_run_classifier_message] = msg
      end
      if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
        print "invalid project id: #{@project_id}"
      else
        # Move over to the scripts directory, since
        # confidence_csv2scale does not work outside of the scripts directory.
        Dir.chdir Rails.root.join("scripts")
        #Dynamically create the confidence file based on meta alerts in the DB
        cmd1 = "./create_confidence_csv.py #{dbPath.to_s} #{csvPath.to_s} #{@project.id.to_s}"
        # Run the command
        res = `#{cmd1}`
        if res.present?
          puts "result of: #{cmd1}"
          puts res
        end
        cs_id = ClassifierScheme.where(classifier_instance_name: @classifier_instance_name).select(:id).take[:id]
        # This is the command to run for confidence_csv2scale.
        cmd2 = "./confidence_csv2scale.py #{dbPath.to_s} #{csvPath.to_s} #{@project.id.to_s}"
        # Run the command
        res = `#{cmd2}`
        if res.present?
          puts "result of: #{cmd2}"
          puts res
        end
        #record last used classifier scheme
        @project.update(last_used_confidence_scheme: cs_id)
        Dir.chdir Rails.root.to_s
      end
    end

    end_timestamps = get_timestamps()
    PerformanceMetric.addRecord(@scaife_mode, "runClassifier", "Time to run a SCAIFE classifier", "SCALe_user", "Unknown", @project.id, start_timestamps, end_timestamps)

    # POST route has to be defined for this to work
    redirect_to(@project) unless @is_experiment

  end

  def show

    @supplemental = "supplemental"
    @supplemental_unfused = "supplemental_unfused"
    @display = Display.find(params[:id])
    @messages =  Message.where("alert_id = " + @display.alert_id.to_s +
                               " AND project_id = " + @display.project_id.to_s)
    @is_fused_view = 0
    @is_meta_alert = 1
    @meta_alerts =  Display.where("meta_alert_id = " + @display.meta_alert_id.to_s +
                               " AND project_id = " + @display.project_id.to_s)
    if @meta_alerts.length > 1
      @is_meta_alert = 0
    end
  end

=begin

  API only

=end
  def changeSCAIFEMode
    @new_mode = params[:scaife_mode]
    status = 200
    session[:scaife_mode_msg] = nil

    if @new_mode == "Connected"
      status = 400
      session[:scaife_mode_msg] = "Log in to SCAIFE first"
    else
      if session[:login_token]
        begin # attempt to logout of SCAIFE
          logout_response = logout_user(session[:login_token])
          session.delete(:login_token)
        rescue
          session.delete(:login_token)
        end
      end

      session[:scaife_mode] = @new_mode
    end

    respond_to do |format|
      format.any { render json: {}, status: status, content_type: "application/json"}
    end
  end


  def get_scaife_taxonomies(datahub_controller)
     result = datahub_controller.listTaxonomies(session[:login_token])

     if result.is_a?(String) #Failed to connect to Registration/DataHub server
          upload_project_message = "Failed to retrieve SCAIFE code languages"
          return upload_project_message, nil, nil
     else
         scaife_taxonomies_ids = Hash.new
         taxonomy_ids = []
         for entry in result
           tax_id = entry.taxonomy_id
           taxonomy_ids.append(tax_id)

           taxonomy_object = OpenStruct.new
           taxonomy_object.name = entry.taxonomy_name
           taxonomy_object.version = entry.taxonomy_version

           scaife_taxonomies_ids[taxonomy_object] = tax_id
         end
         return taxonomy_ids, scaife_taxonomies_ids
     end
  end


  def get_scaife_languages(datahub_controller)
      result = datahub_controller.listLanguages(session[:login_token])

      if result.is_a?(String) #Failed to connect to Registration/DataHub server
          @upload_project_message = "Failed to retrieve SCAIFE code languages"
          return @upload_project_message, nil
      else
          scaife_languages_ids = Hash.new
          scaife_languages = []
          for language_object in result
              code_language_object = OpenStruct.new
              #code_language_object.code_language_id = language_object["code_language_id"]
              code_language_object.name = language_object.language
              code_language_object.version = language_object.version
              scaife_languages_ids[code_language_object] = language_object.code_language_id
              scaife_languages.append(code_language_object)
          end
          return scaife_languages, scaife_languages_ids
      end
  end


  def get_scale_tools(project_id)
      scale_project_tools = ProjectTool.where(project_id: project_id)
      tools = []
      scale_tools_ids = Hash.new
      for proj_tool in scale_project_tools
          t = Tool.find_by_id(proj_tool.tool_id)
          tool_object = OpenStruct.new
          #tool_object.name = t.name.split("_")[0] #remove "_oss"
          tool_object.name = t.name
          tool_version = t.version
          tool_object.version = tool_version
          tools.append(tool_object)
          scale_tools_ids[tool_object] = t.id

      end
      return tools, scale_tools_ids
  end


  def get_scale_languages(project_id)
      scale_project_languages = ProjectLanguage.all

      scale_languages = []
      scale_languages_ids = Hash.new
      for lang in scale_project_languages
          if project_id.to_s == lang.project_id.to_s
              temp = Language.find_by_id(lang.language_id)
              scale_lang = OpenStruct.new
              scale_lang.name = temp.name
              scale_lang.version = temp.version
              scale_languages.append(scale_lang)
              scale_languages_ids[scale_lang] = lang.language_id
          end
      end
      return scale_languages, scale_languages_ids
  end


  def format_alerts_for_scaife(project_id, scaife_tool_info, checker_name_id, alerts)
      # Create alerts
      @scale_tool_names = Set.new
      @unique_tool_ids = Set.new
      @alerts = []

      secondary_message_list =  Message.where(project_id: project_id).group_by(&:alert_id)

      alerts.each do |entry_id, dl|
          d = dl[0]
          scale_alert_id = d.alert_id
          checker_id = nil
          #tool_name = d.tool.split("_")[0] #remove "_oss"
          tool_name = d.tool
          tool_version = d.tool_version

          @scale_tool_names.add(tool_name)

          tool_object = OpenStruct.new
          tool_object.name = tool_name
          tool_object.version = tool_version

          tool_id = scaife_tool_info[tool_object]
          @unique_tool_ids.add(tool_id)

          checker_name = d.checker
          checker_id = checker_name_id[checker_name]

          # TODO: Update once the displays table has a code_language_version column (or links directly to a language_id
          most_likely_language = @project.languages.where(name: d.code_language).first
          @code_language = {language: most_likely_language.name, version: most_likely_language.version}

          @secondary_messages = []

          @message = {line_start: d.line, line_end: d.line, filepath: d.path, message_text: d.message}

          alert_secondary_messages = secondary_message_list[scale_alert_id]

          if alert_secondary_messages.length > 1 # Primary message is in the list of secondary messages
            for m in alert_secondary_messages
              @secondary_messages.append({line_start: m.line, line_end: m.line, "filepath": m.path, "message_text": m.message})
            end
          end

          @alert_object = {code_language: @code_language, ui_alert_id: scale_alert_id.to_s, tool_id: tool_id, checker_id: checker_id, primary_message: @message}

          if @secondary_messages.present?
            @alert_object[:secondary_messages] = @secondary_messages
          end

          if checker_id.present?
              @alerts.append(@alert_object)
          else
              puts "No corresponding Checker in SCAIFE for Display " + d.id.to_s
          end
      end
      # tool_ids needs to specifically be class Array when passed to API
      return @alerts, @unique_tool_ids.to_a
  end


  def get_scaife_tools(datahub_controller)
     # Get SCAIFE Tools
     tool_ids = []
     scaife_tools_ids = Hash.new
     result = datahub_controller.listTools(session[:login_token])

     if result.is_a?(String) #Failed to connect to Registration/DataHub server
         return result, nil
     else
         for tool in result
             tool_object = OpenStruct.new
             t_id = tool.tool_id
             tool_ids.append(t_id.to_s)
             tool_object.name = tool.tool_name
             tool_object.version = tool.tool_version
             scaife_tools_ids[tool_object] = t_id
         end
     end
     return tool_ids, scaife_tools_ids
  end


  def create_tools_in_scaife(datahub_controller, code_language_ids)
      @scale_tools = Tool.all

      for t in @scale_tools
          scale_tool_id = t.id
          #tool_name = t.name.split("_")[0] #remove "_oss"
          tool_name = t.name
          tool_version = t.version
          author_source = nil
          #TODO: Update checker mappings file to include tool and taxonomy versions
          #TODO: Update tool category in RC-1390
          tool_category = "FFSA"

          checker_mappings = []
          mappings = t.checker_mappings()

          if not mappings.empty?
            checker_mapping = {}
            checker_mapping[:mapping_source] = "SCALe UI"
            checker_mapping[:mapper_identity] = ["secure coding team"]
            checker_mapping[:mapping_version] = t.version # Keep same version as the tool for now
            checker_mapping[:mapping_date] = DateTime.now
            checker_mapping[:mappings] = mappings

            checker_mappings = [checker_mapping]
          end

          checker_names = []

          checker_objects = Checker.where(tool_id: scale_tool_id)
          for c in checker_objects
              if nil != c
                  checker_names.append(c.name)
              end
          end

          #TODO: Update code_metrics_headers RC-1390
          code_metrics_headers = []
          result = datahub_controller.uploadTool(session[:login_token], tool_name, tool_version, tool_category, code_language_ids, checker_mappings, checker_names, code_metrics_headers, author_source)
      end
  end


  def get_alert_id_mappings(scale_alerts_alert_ids, scaife_alerts_alert_ids)
      scale_scaife_alert_ids = Hash.new
      scaife_alerts_alert_ids.each do |scaife_alert, scaife_alert_id|
          scale_alert_id = scale_alerts_alert_ids[scaife_alert]
          scale_scaife_alert_ids[scale_alert_id] = scaife_alert_id
      end
      return scale_scaife_alert_ids
  end


  def uploadProject
    # Note: in order to indicate failure conditions to automation
    # scripts, the redirects use code :see_other (303) rather than the
    # default :found (302) upon success
    puts "uploadProject() here"
    @project_id = params[:project_id]
    @project = Project.find(params[:project_id])

    # note: this is important so that models/project.rb loads (and
    # therefore ProjectLanguage loads as well)
    @project = Project.find(params[:project_id])

    datahub_controller = ScaifeDatahubController.new

    start_timestamps = get_timestamps()
    @upload_project_message = ""
    @scaife_mode = session[:scaife_mode]
    @displays = Display.where("project_id = " + @project_id.to_s)
    scale_project = Project.find_by_id(@project_id)

    if "Connected" != @scaife_mode
      @upload_project_message = "Failed to connect to SCAIFE servers"
      flash[:scaife_project_upload_message] =  @upload_project_message
      respond_to do |format|
        format.any { redirect_back fallback_location: '/',
                     status: :see_other and return }
      end
    end

    package_name = scale_project.name
    package_description = scale_project.description.strip

    # Check on language selection and upload requirements
    begin
      lang_groups_missing, lang_groups_not_in_scaife, langs_in_scaife, scaife_langs_by_id = self.project_language_requirements(@project)
      unsatisfied_lang_names =
        (lang_groups_missing.keys + lang_groups_not_in_scaife.keys).uniq
    rescue ScaifeError => e
      @upload_project_message = e.message
      flash[:scaife_project_upload_message] = @upload_project_message
      puts "uploadProject() scaife generic lang req err: #{@upload_project_message}"
      respond_to do |format|
        format.any { redirect_back fallback_location: '/',
                     status: :see_other and return }
      end
    end
    if unsatisfied_lang_names.present?
      verb = []
      if lang_groups_missing.present?
        verb << "selected"
        instruction = "SCAIFE Languages-> Select"
      end
      if lang_groups_not_in_scaife.present?
        verb << "uploaded"
        instruction = "SCAIFE Languages-> Upload"
      end
      if verb.length > 1
        instruction = "Languages Config -> Select followed by Languages Config -> Upload"
      end
      verb = verb.join('/')
      @upload_project_message = "Project upload requires languages of the following #{'type'.pluralize(unsatisfied_lang_names.length)} to be #{verb} first: #{unsatisfied_lang_names.join(', ')}. To do that, edit the project and then select  #{instruction}"
      flash[:scaife_project_upload_message] =  @upload_project_message
      puts "uploadProject() scaife lang missing err: #{@upload_project_message}"
      respond_to do |format|
        format.any { redirect_back fallback_location: '/',
                     status: :see_other and return }
      end
    end

    # Check on taxonomy selection and upload requirements
    begin
      taxo_groups_missing, taxo_groups_not_in_scaife, taxos_in_scaife, scaife_taxos_by_id = self.project_taxonomy_requirements(@project)
    rescue ScaifeError => e
      @upload_project_message = e.message
      flash[:scaife_project_upload_message] =  @upload_project_message
      puts "uploadProject() scaife generic taxo req err: #{@upload_project_message}"
      respond_to do |format|
        format.any { redirect_back fallback_location: '/',
                     status: :see_other and return }
      end
    end
    unsatisfied_taxo_names =
      (taxo_groups_missing.keys + taxo_groups_not_in_scaife.keys).uniq
    if unsatisfied_taxo_names.present?
      verb = []
      if taxo_groups_missing.present?
        verb << "selected"
        instruction = "SCAIFE Taxonomies -> Select"
      end
      if taxo_groups_not_in_scaife.present?
        verb << "uploaded"
        instruction = "SCAIFE Taxonomies -> Upload"
      end
      if verb.length > 1
        instruction = "SCAIFE Taxonomies -> Select followed by SCAIFE Taxonomies -> Upload"
      end
      verb = verb.join('/')
      @upload_project_message = "Project upload requires taxonomies of the following #{'type'.pluralize(unsatisfied_taxo_names.length)} to be #{verb} first: #{unsatisfied_taxo_names.join(', ')}. To do that, edit the project and then select #{instruction}"
      puts "uploadProject() scaife taxo missing err: #{@upload_project_message}"
      flash[:scaife_project_upload_message] =  @upload_project_message
      puts "uploadProject() scaife taxo missing err: #{@upload_project_message}"
      respond_to do |format|
        format.any { redirect_back fallback_location: '/',
                     status: :see_other and return }
      end
    end

    # Check on tool upload requirements
    begin
      tools_not_in_scaife, tools_in_scaife, scaife_tools_by_id = project_tool_requirements(@project)
    rescue ScaifeError => e
      @upload_project_message = e.message
      puts "uploadProject() scaife generic tool req err: #{@upload_project_message}"
      flash[:scaife_project_upload_message] =  @upload_project_message
      puts "uploadProject() scaife generic tool req err: #{@upload_project_message}"
      respond_to do |format|
        format.any { redirect_back fallback_location: '/',
                     status: :see_other and return }
      end
    end
    if tools_not_in_scaife.present?
      tool_label_list = []
      tools_not_in_scaife.each do |tool|
        label = "#{tool.group_key}"
        if tool.version.present?
          label += " - #{tool.version}"
        end
        tool_label_list << label
      end
      @upload_project_message = "Project upload requires the following #{'tool'.pluralize(tools_not_in_scaife.length)} to be uploaded to SCAIFE first: #{tool_label_list.join(', ')}. To do that, edit the project and then select select SCAIFE Tools -> Upload"
      puts "uploadProject() scaife tool missing err: #{@upload_project_message}"
      flash[:scaife_project_upload_message] =  @upload_project_message
      puts "uploadProject() scaife tool missing err: #{@upload_project_message}"
      respond_to do |format|
        format.any { redirect_back fallback_location: '/',
                     status: :see_other and return }
      end
    end

    # make sure exported DB is up to date and reflects
    # the current project (project_scale_to_scaife() consumes
    # data from the external DB)
    puts "Syncing Databases..."
    self.archiveDB(@project_id)

    # these restructurings are for not having to refactor the code
    # further down

    # restructure scaife language info
    @language_version = langs_in_scaife.map { |lang| { "language": lang.name, "version": lang.version } }
    @code_language_ids = langs_in_scaife.map { |lang| lang.scaife_language_id }

    # restructure scaife taxonomy info
    scaife_taxonomies_ids = {}
    taxos_in_scaife.each do |taxo|
      entry = scaife_taxos_by_id[taxo.scaife_tax_id]
      tax_id = entry.taxonomy_id
      taxonomy_object = OpenStruct.new
      taxonomy_object.name = entry.taxonomy_name
      taxonomy_object.version = entry.taxonomy_version
      scaife_taxonomies_ids[taxonomy_object] = tax_id
    end
    @taxonomy_scaife_ids = scaife_taxonomies_ids.values()

    # restructure scaife tool info
    scaife_tools_ids = {}
    tools_in_scaife.each do |tool|
      t_id = tool.scaife_tool_id
      tool_object = OpenStruct.new
      tool_object.name = tool.name
      tool_object.version = tool.version
      scaife_tools_ids[tool_object] = t_id
    end

    # Get SCAIFE taxonomy condition information
    # DH API Call -- GET /taxonomies/{taxonomy_id} (get_taxonomy)
    taxonomy_conditions_ids = Hash.new

    scaife_taxonomies_ids.each do |scaife_taxonomy, tax_id|
      conditions_ids = Hash.new
      taxonomy_name = scaife_taxonomy.name
      result = datahub_controller.getTaxonomy(session[:login_token], tax_id)

      if result.conditions.blank?
        raise "Response from get_taxonomy did not include conditions"
      end

      conditions = result.conditions
      conditions.each do |c|
        c_id = c.condition_id
        c_name = c.condition_name
        conditions_ids[c_name] = c_id
      end
      taxonomy_conditions_ids[taxonomy_name] = conditions_ids
    end

    @is_test_suite = false
    if scale_project.test_suite_name.present?
      @is_test_suite = true
    end

    @author_source = "GENERIC_SCALE_AUTHOR_SOURCE"
    @code_source_url = ""
    @source_file_url = ""
    @source_function_url = ""
    @test_suite_id = ""

    if package_description.blank?
      package_description = "None" # Note: SCAIFE requires a package description
    end

    # Get SCAIFE ToolData
    # DH API Call 7 -- GET /tools/{tool_id} (get_tool_data)
    @checker_name_id = Hash.new
    scaife_tools_ids.each do |tool_obj, tool_id|
      result = datahub_controller.getToolData(session[:login_token], tool_id)

      if result.is_a?(String) #Failed to connect to Registration/DataHub server
        puts "#{__method__}() error getToolData(): #{datahub_controller.scaife_status_code}: #{result}"
        @upload_project_message = result
      else
        tool = result
        tool_id = tool.tool_id
        #if "FFSA" == tool["category"] and not tool["source_mappings"] # Some tools like SWAMP are not uploading checkers
        #  raise "FFSA tool created without source_mappings"
        #end
        if tool.source_mappings
          for source_mappings in tool.source_mappings
            for checker in source_mappings.checker_mappings
              checker_id = checker.checker_id
              checker_name = checker.checker_name
              @checker_name_id[checker_name] = checker_id
            end
          end
        end
      end
    end

    if @is_test_suite
      @test_suite_name = scale_project.test_suite_name
      @test_suite_version = scale_project.test_suite_version
      #TODO: Update test_suite_type and other info (RC-1738)
      @test_suite_type = "juliet"
      @manifest_urls = []
      @use_license_file_url = ""
      @author_source = "author"

      # Call SCAIFE function create_test_suite
      # DH API Call 8 -- POST /test_suites (create_test_suite)
      puts "Creating Test Suite Object..."
      result = datahub_controller.createTestSuite(session[:login_token], @test_suite_name, @test_suite_version, @test_suite_type, @manifest_urls, @use_license_file_url, @author_source, @language_version)

      if result.is_a?(String) #Failed to connect to Registration/DataHub server
        @upload_project_message = "Failed to create SCAIFE test suite"
      else
        @test_suite_id = result.test_suite_id
        scale_project.update(scaife_test_suite_id: @test_suite_id)
      end
    end

    puts "Formatting Alerts for SCAIFE..."
    alerts = @displays.group_by(&:alert_id)
    @alerts, @tool_ids = format_alerts_for_scaife(@project_id, scaife_tools_ids, @checker_name_id, alerts)

    # Call SCAIFE function create_package
    #DH API Call 9 -- POST /packages (create_package)
    @package_id = ""
    @scale_scaife_alert_ids = Hash.new
    puts "Sending #{@alerts.length} SCALe alerts to SCAIFE"
    result = datahub_controller.createPackage(session[:login_token], package_name, package_description, @author_source, @code_language_ids, @code_source_url, @source_file_url, @source_function_url, @test_suite_id, @alerts, @tool_ids)
    if result.is_a?(String) #Failed to connect to Registration/DataHub server
      puts "uploadProject() error createPackage(): #{datahub_controller.scaife_status_code} #{result}"
      if @debug.present?
        @upload_project_message = "#{result}"
      else
        @upload_project_message = "Failed to create SCAIFE package"
      end
    else
      package = result
      alert_mappings = package.alert_mappings
      puts "Number of alerts uploaded: " + alert_mappings.length.to_s
      if alert_mappings
        alert_mappings.each do |alert_data|
          scaife_alert_id = alert_data.alert_id
          scale_alert_id = alert_data.ui_alert_id
          @scale_scaife_alert_ids[scale_alert_id] = scaife_alert_id
        end
      end
      @package_id = package.package_id
      scale_project.update(scaife_package_id: @package_id)
    end

    @src = archive_src_dir_from_id(@project_id).join(scale_project.source_file)
    @source_file_csv = ""
    @source_function_csv = ""

    # Call SCAIFE function upload_codebase_for_package
    # DH API Call 10 -- POST /packages/{package_id} (upload_codebase_for_package)
    puts "Uploading Codebase: #{scale_project.source_file}"
    result = datahub_controller.uploadCodebaseForPackage(session[:login_token], @package_id, @src, @source_file_csv, @source_file_csv)

    if result.is_a?(String) #Failed to connect to Registration/DataHub server
      puts "\nuploading codebase failed: #{datahub_controller.scaife_status_code}: #{result}\n"
      @upload_project_message = result
    end

    if @is_test_suite
      @test_suite_source_file = ""
      @test_suite_source_function = ""
      @use_license_file = ""

      project_file_info = scale_project.file_info_file
      project_function_info = scale_project.function_info_file
      project_license_file = scale_project.license_file

      # Manifest file is require in API
      @manifest_file = archive_supplemental_dir_from_id(@project_id).join(scale_project.manifest_file)

      if project_file_info # Optional file info csv
        @test_suite_source_file = archive_supplemental_dir_from_id(@project_id).join(project_file_info)
      end

      if project_function_info # Optional function info csv
        @test_suite_source_function = archive_supplemental_dir_from_id(@project_id).join(project_function_info)
      end

     #TODO: SCALe currently doesn't allow users to upload a license file
      #if project_license_file # Optional use license file
      #  @use_license_file = archive_supplemental_dir_from_id(@project_id).join(project_license_file)
      #end

      # Call SCAIFE function upload_test_suite
      # DH API Call 11 -- POST /test_suites/{test_suite_id}/packages/{package_id} (upload_test_suite)
      puts "Uploading Test Suite Files: #{@test_suite_id}"
      result = datahub_controller.uploadTestSuite(session[:login_token], @test_suite_id, @package_id, @manifest_file, @use_license_file, @test_suite_source_file, @test_suite_source_function)

      if result.is_a?(String) #Failed to connect to Registration/DataHub server
        if @debug.present?
          @upload_project_message = result
        else
          @upload_project_message = "Failed to upload SCAIFE test suite"
        end
      end
    end

    # TODO: Call SCAIFE function upload_tool_output
    # DH API Call 12 -- POST /tools/{tool_id}/packages/{package_id} (upload_tool_output)

    @project_name = package_name
    @project_description = package_description

    package_id = nil
    meta_alert_id = nil
    puts "Formatting Project Data for SCAIFE..."
    scaife_project_data = JSON.parse(project_scale_to_scaife(@project_id.to_i, package_id, meta_alert_id, true))

    @meta_alerts = []
    alerts_not_loaded = Set[]

    scale_meta_alerts_ids = Hash.new
    scaife_project_data["meta_alerts"].each do |m_alert|
      scale_meta_alert_id = m_alert["meta_alert_id"].to_s
      scale_alert_ids = m_alert["alert_ids"]
      scaife_alert_ids = []

      ActiveRecord::Base.transaction do
        for scale_a_id in scale_alert_ids
          scale_a_id = scale_a_id.to_s
          scaife_a_id = @scale_scaife_alert_ids[scale_a_id]
          if nil != scaife_a_id
            scaife_alert_ids.append(scaife_a_id)
          else
            alerts_not_loaded |= [scale_a_id] # Remove duplicate warnings for the same alert
          end

          Display.where(project_id: @project_id).where(alert_id: scale_a_id).update_all(scaife_alert_id: scaife_a_id)
        end
      end

      scale_scaife_condition_ids = Hash.new
      if scaife_alert_ids.any?
        filepath = m_alert["filepath"]
        line_number = m_alert["line_number"]
        scale_condition_id = m_alert["condition_id"].to_s
        condition_name = Condition.find_by_id(scale_condition_id).name
        scaife_condition_id = nil
        taxonomy_conditions_ids.each do |taxonomy_name, conditions_ids|
          #TODO: Code does not account for taxonomy versions or different taxonomies with the same condition names
          if conditions_ids.keys.include? condition_name
            scaife_condition_id = conditions_ids[condition_name]
            scale_scaife_condition_ids[scaife_condition_id] = scale_condition_id
          end
        end
        det = m_alert["determination"]

        determination = nil

        # Send determinations in the request only if the determinations are present
        if det.present?
          determination = {
            flag_list: det["flag_list"],
            inapplicable_environment_list: det["inapplicable_environment_list"],
            ignored_list: det["ignored_list"],
            verdict_list: det["verdict_list"],
            dead_list: det["dead_list"],
            notes_list: det["notes_list"],
            dangerous_construct_list: det["dangerous_construct_list"],
          }
        end

        if scaife_condition_id.present?
          m_alert = {
            "condition_id": scaife_condition_id,
            "filepath": filepath,
            "line_number": line_number,
            "alert_ids": scaife_alert_ids,
            "ui_meta_alert_id": scale_meta_alert_id,
          }
          if determination.present?
            m_alert["determination"] = determination
          end
          @meta_alerts.append(m_alert)
        end
      end
    end

    if alerts_not_loaded.present?
      puts alerts_not_loaded.length.to_s + " SCALe alerts failed to upload to SCAIFE: " + alerts_not_loaded.to_s
    end

    puts "Sending " + @meta_alerts.length.to_s + " SCALe meta-alerts to SCAIFE"
    result = datahub_controller.createProject(session[:login_token], @project_name, @project_description, @author_source, @package_id, @meta_alerts, @taxonomy_scaife_ids)

    if result.is_a?(String) #Failed to connect to Registration/DataHub server
      @upload_project_message = result
    else
      @upload_project_message = "Data uploaded to SCAIFE!"
      project = result
      @scaife_project_id = project.project_id
      meta_alert_mappings = project.meta_alert_mappings
      puts "Number of meta-alerts uploaded: " + meta_alert_mappings.length.to_s
      ActiveRecord::Base.transaction do
        meta_alert_mappings.each do |ma_mapping|
          scaife_ma_id = ma_mapping.meta_alert_id
          scale_ma_id = ma_mapping.ui_meta_alert_id
          records = Display.where(project_id: @project_id).where(meta_alert_id: scale_ma_id)
          if records.length < 1
            raise "No SCALe meta-alert matching SCAIFE meta-alert " + scaife_ma_id
          end
          records.update_all(scaife_meta_alert_id: scaife_ma_id)
        end
      end
      scale_project.update(scaife_project_id: @scaife_project_id)
      scale_project.update(scaife_uploaded_on: Time.now)

      # DECISION: Should data forwarding and publishing updates be
      # automatically turned on when a project is uploaded to SCAIFE??
      # For now, it is.
      result, status_code = datahub_controller.enableDataForwarding(session[:login_token], @scaife_project_id)
      if 200 != status_code
        @upload_project_message = "Failed to enable data forwarding."
        flash[:scaife_project_upload_message] =  @upload_project_message
        puts "uploadProject() error createProject(): (#{datahub_controller.scaife_status_code}): #{result}"
        respond_to do |format|
          format.any { redirect_back fallback_location: '/',
                       status: :see_other and return }
        end
      end

      scale_project.update(subscribe_to_data_updates: true)
      scale_project.update(publish_data_updates: true)
    end

    end_timestamps = get_timestamps()
    PerformanceMetric.addRecord(@scaife_mode, "uploadProject", "Time to upload a SCALe project to SCAIFE", "SCALe_user", "Unknown", @scaife_project_id, start_timestamps, end_timestamps)

    # make sure exported DB is up to date and reflects
    # the current project (project_scale_to_scaife() consumes
    # data from the external DB)
    puts "Syncing Databases..."
    self.archiveDB(@project_id)

    end_timestamps = get_timestamps()
    PerformanceMetric.addRecord(@scaife_mode, "uploadProject", "Time to upload a SCALe project to SCAIFE", "SCALe_user", "Unknown", @scaife_project_id, start_timestamps, end_timestamps)

    flash[:scaife_project_upload_message] = @upload_project_message
    respond_to do |format|
      # use 302 redirect on success
      format.any { redirect_to "/"}
    end

  end

end
