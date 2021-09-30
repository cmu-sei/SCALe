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


# This file defines the actions corresponding to various CRUD
# actions for the experiment model.
class ExperimentsController < ApplicationController

  def index
    Experiment.configs_clear
    $additional_projects = {}
    c = ScaifeDatahubController.new

    result = c.listExperimentConfigs(session[:login_token])
    if result.is_a?(String) #Failed to connect to Registration/DataHub server
      puts "#{__method__}() error listExperimentConfigs(): #{c.scaife_status_code}: #{result}"
      @get_projects_status = 400
    else
      @get_projects_status = 200

      result.each do |experiment_config|
        experiment_name = experiment_config.experiment_name
        if experiment_config.is_test_suite
          $additional_projects[experiment_name] = experiment_config
        else
          Experiment.configs[experiment_name] = experiment_config
        end
      end
    end

    order_options_string = "Display (d) ID ASC,Display (d) ID DESC Meta-Alert (m) ID ASC,Meta-Alert (m) ID DESC,Flag ASC,Flag DESC,Line DESC,Severity ASC,Severity DESC,Likelihood ASC,Likelihood DESC,Remediation ASC,Remediation DESC,CERT Priority ASC,CERT Priority DESC,Level ASC,Level DESC,Checker ASC,Checker DESC,Message ASC,Message DESC,Path DESC,Label ASC,Label DESC,Confidence ASC,Confidence DESC,Category ASC,Category DESC,Time ASC,Time DESC,AlertCondition Priority ASC,AlertCondition Priority DESC,Path ASC,Line ASC"
    @order_options = order_options_string.split(",")

    respond_to do |format|
      format.html
    end
  end

  def create_experiment
    # Create an Experiment object based on data from the form
    timestamp = Time.now.strftime('%Y-%m-%d_%H:%M:%S')
    experiment = Experiment.new(
      adjudicator_name: params[:adjudicator_name],
      org_name: params[:organization],
      language_experience_level: params[:coding_experience],
      language_years_experience: params[:years_coding],
      static_analysis_experience_level: params[:adjudication_experience],
      static_analysis_years_experience: params[:years_adjudicating],
      experiment_config_name: params[:experiment_name],
      start_timestamp: timestamp,
      meta_alert_order: params[:meta_alert_order]
    )
    experiment.save!

    # Grab corresponding experiment and additional_proj configs
    experiment_config = Experiment.configs[params[:experiment_name]]
    additional_proj_config = $additional_projects[experiment_config.classifier_training_project]

    #Set initial project parameters
    start_time = Time.now.utc.iso8601

    project_name = "(Experiment #{start_time}) #{experiment_config.experiment_name}"
    project_params = helpers.generateProjectParams(experiment_config, project_name)

    # Create new SCALe project using parameters
    puts(">>Creating Experiment SCALe Project...")
    projects_controller = helpers.createProjectsController(request, response, project_params)
    projects_controller.create

    # Update parameters with new project_id
    project = Project.where(name: project_name)[0]
    # This should show shuffle_seed, but it doesn't. Why? ~DS
    project[:default_shuffle_seed] = experiment_config.shuffle_seed
    project[:default_efp_ct] = experiment_config.efp_ct
    project[:default_etp_ct] = experiment_config.etp_ct
    project[:default_ordering] = experiment_config.ordering
    project[:default_filtering] = experiment_config.filtering
    project[:experiment] = params[:experiment_name]
    project.save
    project_params[:project_id] = project.id
    projects_controller.params = project_params

    # Update project SCALe database
    puts(">>Updating Experiment Project Database...")
    projects_controller.database
    projects_controller.experimentFromDatabase

    # Upload project related langs, taxos, and tools to SCAIFE
    puts(">>Uploading project languages, taxonomies, and tools to SCAIFE...")
    upload_langs = {}
    experiment_config.language_ids.split(",").each do |lang|
      upload_langs[lang] = lang
    end
    project_params[:upload_langs] = upload_langs

    upload_taxos = {}
    experiment_config.taxonomy_ids.split(",").each do |taxo|
      upload_taxos[taxo] = taxo
    end
    project_params[:upload_taxos] = upload_taxos

    upload_tools = {}
    experiment_config.tool_ids.split(",").each do |tool|
      upload_tools[tool] = tool
    end
    project_params[:upload_tools] = upload_tools

    projects_controller.params = project_params
    projects_controller.experimentLangUploadSubmit
    projects_controller.experimentTaxoUploadSubmit
    projects_controller.experimentToolUploadSubmit

    # Upload project to SCAIFE
    puts(">>Uploading project contents to SCAIFE...")
    alert_conditions_controller = helpers.createAlertConditionsController(request, response, project_params)
    alert_conditions_controller.uploadProject


    # Create Classifier Training Project
    additional_proj_name = "(Experiment #{start_time}) #{additional_proj_config.experiment_name}"
    additional_proj_params = helpers.generateProjectParams(additional_proj_config, additional_proj_name, is_test_suite=true)

    puts(">>Creating Additional SCALe Project...")
    projects_controller = helpers.createProjectsController(request, response, additional_proj_params)
    projects_controller.create

    puts(">>Updating Additional Project Database...")
    additionalProject = Project.where(name: additional_proj_name)[0]
    additional_proj_params[:project_id] = additionalProject.id
    projects_controller.params = additional_proj_params
    projects_controller.database
    projects_controller.experimentFromDatabase

    # Upload project related langs, taxos, and tools to SCAIFE
    puts(">>Uploading addtional project languages, taxonomies, and tools to SCAIFE...")
    upload_langs = {}
    additional_proj_config.language_ids.split(",").each do |lang|
      upload_langs[lang] = lang
    end
    additional_proj_params[:upload_langs] = upload_langs

    upload_taxos = {}
    additional_proj_config.taxonomy_ids.split(",").each do |taxo|
      upload_taxos[taxo] = taxo
    end
    additional_proj_params[:upload_taxos] = upload_taxos

    upload_tools = {}
    additional_proj_config.tool_ids.split(",").each do |tool|
      upload_tools[tool] = tool
    end
    additional_proj_params[:upload_tools] = upload_tools

    projects_controller.params = additional_proj_params
    projects_controller.experimentLangUploadSubmit
    projects_controller.experimentTaxoUploadSubmit
    projects_controller.experimentToolUploadSubmit

    puts("Uploading additional project contents to SCAIFE...")
    alert_conditions_controller = helpers.createAlertConditionsController(request, response, additional_proj_params)
    alert_conditions_controller.uploadProject


    #Retrieve classifier_id from SCAIFE
    puts("Creating classifier based on submitted projects...")
    classifier_id = ""
    stats_controller = ScaifeStatisticsController.new
    result = stats_controller.listClassifiers(session[:login_token])
    result.each do |object|
      if experiment_config.classifier_type == object.classifier_type
        classifier_id = object.classifier_id
      end
    end

    heuristic_name = experiment_config.heuristic_type
    classifier_type = experiment_config.classifier_type
    classifier_name = helpers.generateClassifierName("#{classifier_type} (Experiment)")

    #This should be part of the config file in the future
    num_meta_alert_threshold = 10

    #Set SCAIFE / Modal Classifier parameters
    classifier_params = {
      :project_id => project.id,
      :classifier_type => classifier_type,
      :classifier_instance_name => classifier_name,
      :source_domain => "#{project_name},#{additional_proj_name}",
      :adaptive_heuristic_name => heuristic_name,
      :adaptive_heuristic_parameters => helpers.validateAdaptiveHeuristicParameters(heuristic_name, experiment_config.heuristic_parameters),
      :use_pca => "false",
      :feature_category => "intersection",
      :semantic_features => "false",
      :ahpo_name => experiment_config.parameterization_type,
      :ahpo_parameters => "",
      :num_meta_alert_threshold => num_meta_alert_threshold,
      :scaife_classifier_id => classifier_id,
      :experiment => true,
    }

    #Create classifier instance in SCAIFE
    classifier_schemes_controller = helpers.createClassifierSchemesController(request, response, classifier_params)
    classifier_schemes_controller.createClassifier

    puts("Running classifier on project...")
    run_classifier_params = {
      :classifier_scheme_name => classifier_name,
      :project_id => project.id,
      :experiment => true
    }
    alert_conditions_controller.params = run_classifier_params
    alert_conditions_controller.runClassifier

    redirect_to "/projects/#{project.id}"
  end
end
