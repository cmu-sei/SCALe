# <legal>
# SCALe version r.6.5.5.1.A
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

class ClassifierScheme < ApplicationRecord
  include ActiveModel::Validations

  validates :classifier_instance_name, uniqueness: true

  validates :classifier_instance_name, :classifier_type, :source_domain, :created_at, :updated_at,
    :adaptive_heuristic_name, :ahpo_name, presence: true

  validates :classifier_type, :adaptive_heuristic_name, :ahpo_name, format: {with: /\A[a-zA-Z][\-\s_a-zA-Z]*\z/,
           message: "must begin with a letter and contain only letters, spaces, hyphens, and underscores"}

  #TODO: Discuss implementing requirements for project names. JUnit tests use numbers only for project names so this validation will break.
  #validates :source_domain, format: {with: /\A[a-zA-Z][\s_a-zA-Z0-9]*(\s?\,\s?[a-zA-Z][\s_a-zA-Z0-9]*)*\z/,
  #          message: "comma separated list of project names that must begin with a letter and contain only letters, numbers, spaces and underscores"}

=begin
  creates a row in the table

  params:
    classifier_instance_name (string) - name of the classifier scheme
    classifier_type (string - type of classifier scheme (previously the name)
    source_domain (string) - list of projects used to create the classifier
    adaptive_heuristic_name (string) - name field of the adaptive heuristic represented by the
            title of tabs in the classifier schemes modal in the
            adaptive heuristics section.
    adaptive_heuristic_parameters (json) - Parameters for the adaptive_heuristic (They vary
               depending on the type of adaptive_heuristic).
    use_pca - Specifies if the classifier should apply principal component analysis (PCA).
    feature_category - Selected feature category (i.e., "union" or "intersection")
    semantic_features - Specifies if the classifier should consider semantic features.
    ahpo_name (string) - Automated Hyper-Parameter Optimization. name field
            represented by the AHPO selected from the dropdown in
            the classifier schemes model in the AHPO section. There
            will be options, but none implemented yet.
    ahpo_parameters (json) - Parameters for the ahpo (They vary
               depending on the type of ahpo).
    num_meta_alert_threshold - Specifies the number of new meta-alerts received before retraining the classifier.


  rescue Exception => e

=end
  def self.insertClassifier(classifier_instance_name, classifier_type, source_domain, adaptive_heuristic_name, adaptive_heuristic_parameters, ahpo_name, ahpo_parameters, use_pca, feature_category, semantic_features, num_meta_alert_threshold, scaife_classifier_id=nil, scaife_classifier_instance_id=nil)

    ts = Time.now

    # ActiveRecord sanitizes and also uses prepared statement
    cs = ClassifierScheme.create!(
    classifier_instance_name: classifier_instance_name,
      classifier_type: classifier_type,
      source_domain: source_domain,
      created_at: ts,
      updated_at: ts,
      adaptive_heuristic_name: adaptive_heuristic_name.present? ? adaptive_heuristic_name : "None",
      adaptive_heuristic_parameters: adaptive_heuristic_parameters,
      ahpo_name: ahpo_name.present? ? ahpo_name : "None",
      ahpo_parameters: ahpo_parameters,
      scaife_classifier_id: scaife_classifier_id,
      scaife_classifier_instance_id: scaife_classifier_instance_id,
      semantic_features: semantic_features,
      use_pca: use_pca,
      feature_category: feature_category,
      num_meta_alert_threshold: num_meta_alert_threshold
    )

    return cs

  end

  def self.editClassifier(classifier_instance_name, classifier_type, source_domain, adaptive_heuristic_name, adaptive_heuristic_parameters, ahpo_name, ahpo_parameters, use_pca, feature_category, semantic_features, num_meta_alert_threshold, scaife_classifier_id=nil, scaife_classifier_instance_id=nil)
    ts = Time.now

    cs = ClassifierScheme.find_by(classifier_instance_name: classifier_instance_name)
    if cs.blank?
      raise ActiveRecord::RecordNotFound.new(
        "classifier instance not found: #{classifier_instance_name}")
    end

    cs.classifier_type = classifier_type
    cs.source_domain = source_domain
    cs.adaptive_heuristic_name = adaptive_heuristic_name
    cs.adaptive_heuristic_parameters = adaptive_heuristic_parameters
    cs.updated_at = ts
    cs.ahpo_name = ahpo_name
    cs.ahpo_parameters = ahpo_parameters
    cs.scaife_classifier_id = scaife_classifier_id
    cs.scaife_classifier_instance_id = scaife_classifier_instance_id
    cs.use_pca = use_pca
    cs.feature_category = feature_category
    cs.semantic_features = semantic_features
    cs.num_meta_alert_threshold = num_meta_alert_threshold
    cs.save!

    return cs

  end

   def self.deleteClassifier(classifier_instance_name)
      cs = ClassifierScheme.find_by(classifier_instance_name: classifier_instance_name)
      if cs
        projects = Project.where(last_used_confidence_scheme: cs.id)
        project_ids = projects.pluck(:id)
        projects.update_all(last_used_confidence_scheme: nil)
        Display.where(project_id: project_ids).update_all(confidence: nil)

        if cs.destroy
          return true
        end
      end

      return false
   end

end
