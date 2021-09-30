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

class ClassifierMetric < ApplicationRecord
  include ActiveModel::Validations

=begin
  creates a row in the table

  rescue Exception => e

=end
  def self.addRecord(project_id, scaife_classifier_instance_id, classifier_analysis)
    num_labeled_meta_alerts = classifier_analysis["num_labeled_meta_alerts_used_for_classifier_evaluation"]
    train_acc = classifier_analysis["train_accuracy"]
    train_precision = classifier_analysis["train_precision"]
    train_recall = classifier_analysis["train_recall"]
    train_f1 = classifier_analysis["train_f1"]
    test_acc = classifier_analysis["test_accuracy"]
    test_precision = classifier_analysis["test_precision"]
    test_recall = classifier_analysis["test_recall"]
    test_f1 = classifier_analysis["test_f1"]
    num_labeled_meta_alerts_used_for_classifier_training = classifier_analysis["num_labeled_meta_alerts_used_for_classifier_training"]
    num_labeled_T_test_suite_used_for_classifier_training = classifier_analysis["num_labeled_T_test_suite_used_for_classifier_training"]
    num_labeled_F_test_suite_used_for_classifier_training = classifier_analysis["num_labeled_F_test_suite_used_for_classifier_training"]
    num_labeled_T_manual_verdicts_used_for_classifier_training = classifier_analysis["num_labeled_T_manual_verdicts_used_for_classifier_training"]
    num_labeled_F_manual_verdicts_used_for_classifier_training = classifier_analysis["num_labeled_F_manual_verdicts_used_for_classifier_training"]
    num_code_metrics_tools_used_for_classifier_training = classifier_analysis["num_code_metrics_tools_used_for_classifier_training"]
    top_features_impacting_classifier = classifier_analysis["top_features_impacting_classifier"]

    cm = ClassifierMetric.create(
        project_id: project_id,
        scaife_classifier_instance_id: scaife_classifier_instance_id,
        transaction_timestamp: Time.now,
        num_labeled_meta_alerts_used_for_classifier_evaluation: num_labeled_meta_alerts,
        test_accuracy: test_acc,
        test_precision: test_precision,
        test_recall: test_recall,
        test_f1: test_f1,
        num_labeled_meta_alerts_used_for_classifier_training: num_labeled_meta_alerts_used_for_classifier_training,
        num_labeled_T_test_suite_used_for_classifier_training: num_labeled_T_test_suite_used_for_classifier_training,
        num_labeled_F_test_suite_used_for_classifier_training: num_labeled_F_test_suite_used_for_classifier_training,
        num_labeled_T_manual_verdicts_used_for_classifier_training: num_labeled_T_manual_verdicts_used_for_classifier_training,
        num_labeled_F_manual_verdicts_used_for_classifier_training: num_labeled_F_manual_verdicts_used_for_classifier_training,
        num_code_metrics_tools_used_for_classifier_training: num_code_metrics_tools_used_for_classifier_training,
        top_features_impacting_classifier: top_features_impacting_classifier,
        train_accuracy: train_acc,
        train_precision: train_precision,
        train_recall: train_recall,
        train_f1: train_f1
    )

    if cm.valid?
      return true
    else
      return false
    end
  end
end
