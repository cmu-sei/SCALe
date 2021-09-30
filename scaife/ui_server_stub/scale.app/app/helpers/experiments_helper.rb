# -*- coding: utf-8 -*-

# This file provides a shortcut for retrieving hard-coded file locations.

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

module ExperimentsHelper

  # Creates an uploaded file object that mimics a file submitted via a form
  def createUploadedFile(filename, filepath)
    ActionDispatch::Http::UploadedFile.new({
       :filename => filename,
       :type => 'application/octet-stream',
       :tempfile => File.new(filepath)
     })
  end

  # Carves out a file basename from full file path
  def getFileName(filepath)
    filepath.split("/")[-1]
  end

  # Validates adaptive heuristic parameters
  def validateAdaptiveHeuristicParameters(heuristic_name, params)

    case heuristic_name
    when "Similarities"
      parameters = {
        :filepath_line_cutoff => params[:filepath_line_cutoff] || 0.6,
        :fp_beta => params[:fp_beta] || 2,
        :line_beta => params[:line_beta] || 0.0001
      }
    when "K-Nearest Neighbors"
      parameters = {
        :num_neighbors => params[:num_neighbors] || 2
      }
    when "Label Propagation"
      parameters = {
        :gamma => params[:gamma] || 20,
        :max_iter => params[:max_iter] || 1000,
        :tol => params[:tol] || 0.001
      }
    else
      parameters = "None"
    end
    return parameters
  end

  # Creates a new ProjectsController with the specified params
  def createProjectsController(request, response, params = {})
    controller = ProjectsController.new
    controller.request = request
    controller.response = response
    controller.params = params
    return controller
  end

  # Creates a new AlertConditionsController with the specified params
  def createAlertConditionsController(request, response, params = {})
    controller = AlertConditionsController.new
    controller.request = request
    controller.response = response
    controller.params = params
    return controller
  end

  # Creates a new ClassifierSchemesController with the specified params
  def createClassifierSchemesController(request, response, params = {})
    controller = ClassifierSchemesController.new
    controller.request = request
    controller.response = response
    controller.params = params
    return controller
  end

  # Generates default project params, and adds test_suite params if necessary
  def generateProjectParams(experiment_config, project_name, is_test_suite=false)

    src_path = experiment_config.source_code_file
    src_name = getFileName(src_path)
    src_file = createUploadedFile(src_name, src_path)
    file = {:source => src_file}


    selected_tools = []
    tool_versions = {}
    tool_names = experiment_config.tool_names.split(",")
    versions = experiment_config.tool_versions.split(",")
    tool_files = experiment_config.tool_files.split(",")

    tool_names.each_index do |tool|
      tool_name = tool_names[tool]
      selected_tools.append(tool_name)
      tool_versions[tool_name] = versions[tool] ? versions[tool] : ""
      tool_file_path = tool_files[tool]
      tool_file_name = getFileName(tool_file_path)
      file[tool_name] = createUploadedFile(tool_file_name, tool_file_path)
    end

    selected_langs = {}
    langs = experiment_config.language_ids.split(",")
    langs.each do |lang|
      lang_name = "Language #{lang}"
      selected_langs[lang_name] = lang
    end

    project_params = ActionController::Parameters.new( {
       :project => {
         :name => project_name,
         :description => "Project created for #{project_name}",
         :is_test_suite => is_test_suite,
       },
       :project_type => 'scale',
       :selectedTools => selected_tools,
       :tool_versions => tool_versions,
       :select_langs => selected_langs,
       :file => file
     } )

    if is_test_suite

      project_params[:project]["test_suite_name"] = experiment_config.test_suite_name
      project_params[:project]["test_suite_version"] = experiment_config.test_suite_version
      project_params[:project]["test_suite_sard_id"] = experiment_config.test_suite_sard_id
      project_params[:project]["test_suite_type"] = experiment_config.test_suite_type
      project_params[:project]["manifest_url"] = experiment_config.manifest_url
      project_params[:project]["author_source"] = experiment_config.author_source
      project_params[:project]["license_file"] = experiment_config.license_file

      if experiment_config.function_info_path
        func_info_file_path = experiment_config.function_info_path
        func_info_file_name = getFileName(func_info_file_path)
        func_info_file = createUploadedFile(func_info_file_name, func_info_file_path)
        project_params[:file]["function_info_file"] = func_info_file
      end
      if experiment_config.file_info_path
        file_info_path_path = experiment_config.file_info_path
        file_info_path_name = getFileName(file_info_path_path)
        file_info_file = createUploadedFile(file_info_path_name, file_info_path_path)
        project_params[:file]["file_info_file"] = file_info_file
      end
      if experiment_config.manifest_file_path
        manifest_file_path = experiment_config.manifest_file_path
        manifest_file_name = getFileName(manifest_file_path)
        manifest_file = createUploadedFile(manifest_file_name, manifest_file_path)
        project_params[:file]["manifest_file"] = manifest_file
      end
    end

    return project_params
  end

  # Generates a new, unique Classifier Name based on existing classifiers
  def generateClassifierName(basename)
    count = 1
    ClassifierScheme.where('classifier_instance_name LIKE ?', "%#{basename}%").all.each do |cs|
      classifier = cs.classifier_instance_name
      curr = classifier[-1].to_i
      if curr >= count
        count = curr + 1
      end
    end
    return "#{basename} #{count}"
  end

end