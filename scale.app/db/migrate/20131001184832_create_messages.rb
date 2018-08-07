# -*- coding: utf-8 -*-
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.


class CreateMessages < ActiveRecord::Migration
  def change
  	if connection.tables.include?('messages')
  		drop_table :messages
  	end
    create_table :messages do |t|
      t.integer     :project_id
      t.integer     :diagnostic_id
      t.string      :path
      t.integer     :line
      t.string      :link
      t.string      :message
    end
  end
end
