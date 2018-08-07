# -*- coding: utf-8 -*-
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.

class CreateDisplays < ActiveRecord::Migration
  def change
    create_table :displays do |t|
      t.boolean     :flag
      t.integer     :verdict
      t.integer     :previous
      t.string      :path
      t.integer     :line
      t.string      :link
      t.string      :message
      t.string      :checker
      t.string      :tool
      t.string      :rule
      t.string      :title
      t.integer     :severity
      t.integer     :liklihood
      t.integer     :remediation
      t.integer     :priority
      t.integer     :level
      t.string      :cwe_likelihood
      t.string      :notes
      t.boolean     :ignored
      t.boolean     :dead
      t.boolean     :inapplicable_environment
      t.integer     :dangerous_construct
      t.decimal     :confidence
      t.integer     :alert_priority
    end
  end
end
