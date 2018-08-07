# -*- coding: utf-8 -*-
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.


class AddScaleIdToDisplays < ActiveRecord::Migration
  def change
    add_column :displays, :meta_alert_id, :integer, :default => 0
	#add_column :displays, :cwe_likelihood, :integer
  end
end
