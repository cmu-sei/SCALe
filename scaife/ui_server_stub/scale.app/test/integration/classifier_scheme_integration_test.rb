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

require 'test_helper'

class ClassifierSchemeIntegrationTest < ActionDispatch::IntegrationTest
  test "createClassifier returns 405 in SCALe-only scaife_mode" do
    classifier_instance_name = "newClassifierSchemeName"
    classifier_type = "classifier_type"
    project_id = 1
    source_domain = "source_domain"
    adaptive_heuristic_name = "adaptive_heuristic_name"
    adaptive_heuristic_parameters = "adaptive_heuristic_parameters"
    ahpo_name = "ahpo_name"
    ahpo_parameters = "ahpo_parameters"
    status = 405
    mode = "SCALe-only"

    request_create_classifier(mode, classifier_instance_name, classifier_type, project_id, source_domain,
      adaptive_heuristic_name, adaptive_heuristic_parameters, ahpo_name, ahpo_parameters, status)
  end

  test "createClassifier returns 200 on success in Demo scaife_mode" do
    classifier_instance_name = "newClassifierSchemeName"
    classifier_type = "classifier_type"
    project_id = 1
    source_domain = "source_domain"
    adaptive_heuristic_name = "adaptive_heuristic_name"
    adaptive_heuristic_parameters = "adaptive_heuristic_parameters"
    ahpo_name = "ahpo_name"
    ahpo_parameters = "ahpo_parameters"
    status = 200
    mode = "Demo"

    request_create_classifier(mode, classifier_instance_name, classifier_type, project_id, source_domain,
      adaptive_heuristic_name, adaptive_heuristic_parameters, ahpo_name, ahpo_parameters, status)
  end

  test "createClassifier returns 400 on bad request in Demo scaife_mode" do
    classifier_instance_name = ""
    classifier_type = "classifier_type"
    project_id = 1
    source_domain = "source_domain"
    adaptive_heuristic_name = "adaptive_heuristic_name"
    adaptive_heuristic_parameters = "adaptive_heuristic_parameters"
    ahpo_name = "ahpo_name"
    ahpo_parameters = "ahpo_parameters"
    status = 400
    mode = "Demo"

    request_create_classifier(mode, classifier_instance_name, classifier_type, project_id, source_domain,
     adaptive_heuristic_name , adaptive_heuristic_parameters, ahpo_name, ahpo_parameters, status)
  end

  test "viewClassifier returns 405 in SCALe-only scaife_mode" do
    chosen = "b"
    mode = "SCALe-only"
    status = 405
    request_view_classifier(mode, chosen)

    assert_equal status, response.status
  end

  test "viewClassifier renders correct template if cs exists in Demo" \
  "scaife_mode" do
    chosen = "b"
    mode = "Demo"
    request_view_classifier(mode, chosen)

    assert_template partial: "classifier_schemes/_classifier.html.erb"
  end

  test "viewClassifier doesn't render a template if cs doesn't exist" do
    chosen = "doesn't_exist"
    mode = "Demo"
    request_view_classifier(mode, chosen)

    assert_template partial: "classifier_schemes/_classifier.html.erb", count: 0
  end

  test "editClassifier returns 405 in SCALe-only scaife_mode" do
    classifier_instance_name = classifier_schemes(:two).classifier_instance_name
    classifier_type = "classtype"
    project_id = 1
    source_domain = "source_domain"
    adaptive_heuristic_name = "adaptive_heuristic_name"
    adaptive_heuristic_parameters = "adaptive_heuristic_parameters"
    ahpo_name = "ahpo_name"
    ahpo_parameters = "ahpo_parameters"
    status = 405
    mode = "SCALe-only"

    request_edit_classifier(mode, classifier_instance_name, classifier_type, project_id, source_domain, adaptive_heuristic_name,
      adaptive_heuristic_parameters, ahpo_name, ahpo_parameters, status)
  end

  test "editClassifier returns 200 on success in Demo scaie_mode" do
    classifier_instance_name = classifier_schemes(:two).classifier_instance_name
    classifier_type = "classtype"
    project_id = 1
    source_domain = "source_domain"
    adaptive_heuristic_name = "adaptive_heuristic_name"
    adaptive_heuristic_parameters = "adaptive_heuristic_parameters"
    ahpo_name = "ahpo_name"
    ahpo_parameters = "ahpo_parameters"
    status = 200
    mode = "Demo"

    request_edit_classifier(mode, classifier_instance_name, classifier_type, project_id, source_domain, adaptive_heuristic_name,
      adaptive_heuristic_parameters, ahpo_name, ahpo_parameters, status)
  end

  test "editClassifier returns 400 on bad request" do
    classifier_instance_name = classifier_schemes(:two).classifier_instance_name
    classifier_type = "invalid1235135098"
    project_id = 1
    source_domain = "source_domain"
    adaptive_heuristic_name = "adaptive_heuristic_name"
    adaptive_heuristic_parameters = "adaptive_heuristic_parameters"
    ahpo_name = "ahpo_name"
    ahpo_parameters = "ahpo_parameters"
    status = 400
    mode = "Demo"

    request_edit_classifier(mode, classifier_instance_name, classifier_type, project_id, source_domain, adaptive_heuristic_name,
      adaptive_heuristic_parameters, ahpo_name, ahpo_parameters, status)
  end

  test "deleteClassifier returns 405 in SCALe-only scaife_mode" do
    project_id = 1
    classifier_instance_name = "delete"
    status = 405
    mode = "SCALe-only"

    request_delete_classifier(mode, project_id, classifier_instance_name, status)
  end

  test "delete classifier scheme removes references in Projects and Displays" \
  "tables in Demo scaife_mode" do
    project_id = projects(:project_1).id
    classifier_instance_name = "delete"
    mode = "Demo"
    status = 200

    request_delete_classifier(mode, project_id, classifier_instance_name, status)
  end

  test "deleteClassifier returns 400 on bad request in Demo scaife_mode" do
    project_id = 1
    classifier_instance_name = "doesn't exist"
    status = 400
    mode = "Demo"

    request_delete_classifier(mode, project_id, classifier_instance_name, status)
  end

  test "uploadUserFields returns 405 in SCALe-only scaife_mode" do
    upload = {
      "1": {
        safeguard_countermeasure: "9",
        vulnerability: "3"
      },
      "2": {
        safeguard_countermeasure: "2",
        vulnerability: "5"
      }
    }.to_json

    status = 405
    mode = "SCALe-only"

    request_upload_user_fields(mode, upload, status)
  end

  test "uploadUserFields returns 200 on success in Demo scaife_mode" do
    upload = {
      "1": {
        safeguard_countermeasure: "9",
        vulnerability: "3"
      },
      "2": {
        safeguard_countermeasure: "2",
        vulnerability: "5"
      }
    }.to_json

    status = 200
    mode = "Demo"

    request_upload_user_fields(mode, upload, status)
  end

  test "uploadUserFields returns 400 on success Demo scaife_mode" do
    upload = {
      "1": {
        safeguard_countermeasure: "",
        vulnerability: "3"
      },
      "2": {
        safeguard_countermeasure: "2",
        vulnerability: "5"
      }
    }.to_json

    status = 400
    mode = "Demo"

    request_upload_user_fields(mode, upload, status)
  end

  test "run classifier redirects to current project regardless of SCAIFE mode" do

    classifier_instance_name = "b"
    cs_id = ClassifierScheme.where(classifier_instance_name: classifier_instance_name).select(:id).take[:id]

    # SCAIFE-connected is simulated to fail to connect right now, so cs doesn't
    # run
    project = projects(:project_6)
    mode = "Connected"
    last_used = Project.find(project.id).last_used_confidence_scheme
    request_run_classifier(project.id, classifier_instance_name, mode)
    assert_equal last_used, Project.find(project.id).last_used_confidence_scheme

    project = projects(:project_7)
    mode = "Demo"
    request_run_classifier(project.id, classifier_instance_name, mode)
    assert_equal cs_id, Project.find(project.id).last_used_confidence_scheme

    project = projects(:project_8)
    mode = "SCALe-only"
    last_used = Project.find(project.id).last_used_confidence_scheme
    request_run_classifier(project.id, classifier_instance_name, mode)
    assert_equal last_used, Project.find(project.id).last_used_confidence_scheme
  end
end
