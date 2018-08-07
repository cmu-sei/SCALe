# -*- coding: utf-8 -*-
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.


class Project < ActiveRecord::Base
  # A project has 2 attributes: a name and description. 
  attr_accessible :description, :name

  # It must have a name
  validates :name, :presence => true

  # A project is associated with many displays and many messages, and
  # upon destruction of the project, these displays and messages
  # should also be destroyed. 
  has_many :displays, :dependent => :delete_all
  has_many :messages, :dependent => :delete_all

  def new
  end

  # This function was used a long time ago for manually creating projects
  # from the command line. It has thus been deprecated.
  def self.manualCreate
    project = Project.new(name: "manual import", description: "manually created from the rails console")
    project.save!
    if Display.importScaleMI(project.id) == "invalid"
      project.destroy
    else
      path = Rails.root.join("db/backup/#{project.id}")
      if Dir.exists?(path)
        FileUtils.rm_rf(path)
      end
      Dir.mkdir path

      FileUtils.cp(Rails.root.join('db/external.sqlite3'),path)
    end
  end
end
