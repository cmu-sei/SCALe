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

class ClassifierMetrics < ApplicationRecord
  include ActiveModel::Validations

=begin
  creates a row in the table

  rescue Exception => e

=end
  def self.addRecord(project_id, scaife_classifier_instance_id, classifier_analysis)
    num_labeled_meta_alerts = classifier_analysis["num_labeled_meta_alerts_used_for_classifier_evaluation"]
    acc = classifier_analysis["accuracy"]
    precision = classifier_analysis["precision"]
    recall = classifier_analysis["recall"]
    f1 = classifier_analysis["f1"]

    cm = ClassifierMetrics.create(
        project_id: project_id,
        scaife_classifier_instance_id: scaife_classifier_instance_id,
        transaction_timestamp: Time.now,
        num_labeled_meta_alerts_used_for_classifier_evaluation: num_labeled_meta_alerts,
        accuracy: acc,
        precision: precision,
        recall: recall,
        f1: f1
    )

    if cm.valid?
      return true
    else
      return false
    end
  end
end
