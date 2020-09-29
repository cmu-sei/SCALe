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

class ClassifierMetricsTest < ActiveSupport::TestCase

=begin

   Test ClassifierMetrics

=end
	test "ClassifierMetrics inserts a row in the table and validate the column
	values" do

		project_id = 1000
		scaife_classifier_instance_id = "5da60a91649f74df25cc9daf"
                num_labeled_meta_alerts = 5000
                acc = 1.0
                precision = 1.0
                recall = 1.0
                f1 = 1.0

                classifier_analysis = Hash.new
                classifier_analysis["num_labeled_meta_alerts_used_for_classifier_evaluation"] = num_labeled_meta_alerts
                classifier_analysis["accuracy"] = acc
                classifier_analysis["precision"] = precision
                classifier_analysis["recall"] = recall
                classifier_analysis["f1"] = f1

		count = ClassifierMetrics.count
		success = ClassifierMetrics.addRecord(
			project_id,
			scaife_classifier_instance_id,
			classifier_analysis
		)

		assert_equal(true, success)
		assert_equal(count + 1, ClassifierMetrics.count)
		assert ClassifierMetrics.exists?(
                    project_id: project_id,
                    scaife_classifier_instance_id: scaife_classifier_instance_id,
                    num_labeled_meta_alerts_used_for_classifier_evaluation: num_labeled_meta_alerts,
                    accuracy: acc,
                    precision: precision,
                    recall: recall,
                    f1: f1
		)

	end
end
