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

class ClassifierMetricsTest < ActiveSupport::TestCase

=begin

   Test ClassifierMetrics

=end
	test "ClassifierMetrics inserts a row in the table and validate the column
	values" do

		project_id = 1000
		scaife_classifier_instance_id = "5da60a91649f74df25cc9daf"
                num_labeled_meta_alerts = 5000
                train_acc = 1.0
                train_precision = 1.0
                train_recall = 1.0
                train_f1 = 1.0
                test_acc = 0.8
                test_precision = 0.8
                test_recall = 0.8
                test_f1 = 0.8
                num_labeled_meta_alerts_used_for_classifier_training = 1950
                num_labeled_T_test_suite_used_for_classifier_training = 720
                num_labeled_F_test_suite_used_for_classifier_training = 830
                num_labeled_T_manual_verdicts_used_for_classifier_training = 175
                num_labeled_F_manual_verdicts_used_for_classifier_training = 225
                num_code_metrics_tools_used_for_classifier_training = 3
                top_features_impacting_classifier = "num_alerts_per_source_file: 1.5;code_language__C++: 0.125"

                classifier_analysis = Hash.new
                classifier_analysis["num_labeled_meta_alerts_used_for_classifier_evaluation"] = num_labeled_meta_alerts
                classifier_analysis["train_accuracy"] = train_acc
                classifier_analysis["train_precision"] = train_precision
                classifier_analysis["train_recall"] = train_recall
                classifier_analysis["train_f1"] = train_f1
                classifier_analysis["test_accuracy"] = test_acc
                classifier_analysis["test_precision"] = test_precision
                classifier_analysis["test_recall"] = test_recall
                classifier_analysis["test_f1"] = test_f1
                classifier_analysis["num_labeled_meta_alerts_used_for_classifier_training"] = num_labeled_meta_alerts_used_for_classifier_training
                classifier_analysis["num_labeled_T_test_suite_used_for_classifier_training"] = num_labeled_T_test_suite_used_for_classifier_training
                classifier_analysis["num_labeled_F_test_suite_used_for_classifier_training"] = num_labeled_F_test_suite_used_for_classifier_training
                classifier_analysis["num_labeled_T_manual_verdicts_used_for_classifier_training"] = num_labeled_T_manual_verdicts_used_for_classifier_training
                classifier_analysis["num_labeled_F_manual_verdicts_used_for_classifier_training"] = num_labeled_F_manual_verdicts_used_for_classifier_training
                classifier_analysis["num_code_metrics_tools_used_for_classifier_training"] = num_code_metrics_tools_used_for_classifier_training
                classifier_analysis["top_features_impacting_classifier"] = top_features_impacting_classifier

		count = ClassifierMetric.count
		success = ClassifierMetric.addRecord(
			project_id,
			scaife_classifier_instance_id,
			classifier_analysis
		)

		assert_equal(true, success)
		assert_equal(count + 1, ClassifierMetric.count)
		assert ClassifierMetric.exists?(
                    project_id: project_id,
                    scaife_classifier_instance_id: scaife_classifier_instance_id,
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

	end
end
