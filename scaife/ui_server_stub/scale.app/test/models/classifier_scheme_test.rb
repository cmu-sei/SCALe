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

require 'test_helper'

class ClassifierSchemeTest < ActiveSupport::TestCase

=begin

   Test createClassifierScheme

=end
  test "insertClassifier inserts a row in the table and validate the column
  values" do
    classifier_instance_name = "classifier_instance_name"
    classifier_type = "classifier_type"
    source_domain = "source_domain"
    adaptive_heuristic_name = "adaptive_heuristic_name"
    adaptive_heuristic_parameters = "adaptive_heuristic_parameters"
    ahpo_name = "ahpo_name"
    ahpo_parameters = "ahpo_parameters"
    use_pca = false
    feature_category = "intersection"
    semantic_features = false
    num_meta_alert_threshold = 100
    scaife_classifier_id = "scaife_classifier_id"
    scaife_classifier_instance_id = "scaife_classifier_instance_id"

    count = ClassifierScheme.count

    rec = ClassifierScheme.insertClassifier(
      classifier_instance_name,
      classifier_type,
      source_domain,
      adaptive_heuristic_name,
      adaptive_heuristic_parameters,
      ahpo_name,
      ahpo_parameters,
      use_pca,
      feature_category,
      semantic_features,
      num_meta_alert_threshold,
      scaife_classifier_id,
      scaife_classifier_instance_id
    )

    assert_instance_of(ClassifierScheme, rec)
    assert_equal(count + 1, ClassifierScheme.count)
    assert ClassifierScheme.exists?(
      classifier_instance_name: classifier_instance_name,
      classifier_type: classifier_type,
      source_domain: source_domain,
      adaptive_heuristic_name: adaptive_heuristic_name,
      adaptive_heuristic_parameters: adaptive_heuristic_parameters,
      ahpo_name: ahpo_name,
      ahpo_parameters: ahpo_parameters,
      use_pca: use_pca,
      feature_category: feature_category,
      semantic_features: semantic_features,
      num_meta_alert_threshold: num_meta_alert_threshold,
      scaife_classifier_id: scaife_classifier_id,
      scaife_classifier_instance_id: scaife_classifier_instance_id
    )

  end

  test "should have necessary required validators" do
    cs = ClassifierScheme.new
    assert_not cs.valid?
    assert_equal [:classifier_instance_name, :classifier_type, :source_domain, :created_at, :updated_at,
      :adaptive_heuristic_name, :ahpo_name], cs.errors.keys
  end

=begin

   TODO: Test editClassifierScheme

=end

=begin

  Test deleteClassifier

=end
  test "deleteClassifier deletes classifier scheme and references" do
    classifier_instance_name = "delete"
    classifier_type = "classifier_type"
    source_domain = "source_domain"
    adaptive_heuristic_name = "adaptive_heuristic_name"
    adaptive_heuristic_parameters = "adaptive_heuristic_parameters"
    ahpo_name = "ahpo_name"
    ahpo_parameters = "ahpo_parameters"

    c_id = ClassifierScheme.where(classifier_instance_name: classifier_instance_name).pluck(:id)
    projects = Project.where(last_used_confidence_scheme: c_id)
    project_ids = projects.pluck(:id)
    displays = Display.where(project_id: project_ids)
    count = ClassifierScheme.count
    assert ClassifierScheme.exists?(
      classifier_instance_name: classifier_instance_name,
      classifier_type: classifier_type,
      source_domain: source_domain,
      adaptive_heuristic_name: adaptive_heuristic_name,
      adaptive_heuristic_parameters: adaptive_heuristic_parameters,
      ahpo_name: ahpo_name,
                        ahpo_parameters: ahpo_parameters
    )

    assert ClassifierScheme.deleteClassifier(classifier_instance_name)

    # classifier scheme object deleted
    assert_not ClassifierScheme.exists?(
      classifier_instance_name: classifier_instance_name,
      classifier_type: classifier_type,
      source_domain: source_domain,
      adaptive_heuristic_name: adaptive_heuristic_name,
      adaptive_heuristic_parameters: adaptive_heuristic_parameters,
      ahpo_name: ahpo_name,
                        ahpo_parameters: ahpo_parameters
    )

    # correct number of classifier schemes
    assert_equal(count - 1, ClassifierScheme.count)

    # Project.last_used_confidence references cleared
    projects.each do |p|
      assert_nil p.last_used_confidence_scheme
    end

    # last_used_confidence_scheme in a different project that didn't use this cs
    # is still there
    assert_not_nil projects(:project_5).last_used_confidence_scheme

    # Display.confidence references cleared
    displays.each do |d|
      assert_nil d.confidence
    end

    # confidence in displays for project that didn't use this cs still there
    assert_not_nil displays(:display_4).confidence

  end

end
