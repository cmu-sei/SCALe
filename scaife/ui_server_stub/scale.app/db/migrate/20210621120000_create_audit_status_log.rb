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

class CreateAuditStatusLog < ActiveRecord::Migration[4.2]
  def change
    create_table :audit_status_log do |t|
      t.integer     :determination_id
      t.integer     :project_id
      t.string      :sort_keys
      t.string      :filter_selected_id_type
      t.string      :filter_id
      t.string      :filter_meta_alert_id
      t.string      :filter_display_ids
      t.string      :filter_verdict
      t.string      :filter_previous
      t.string      :filter_path
      t.string      :filter_line
      t.string      :filter_checker
      t.string      :filter_condition
      t.string      :filter_tool
      t.string      :filter_taxonomy
      t.string      :filter_category
      t.string      :seed
      t.integer     :alertConditionsPerPage
      t.boolean     :fused
      t.string      :scaife_mode
      t.string      :classifier_chosen
      t.integer     :predicted_verdicts
      t.decimal     :etp_confidence_threshold
      t.decimal     :efp_confidence_threshold
      t.integer     :top_meta_alert
    end
  end
end
