# -*- coding: utf-8 -*-
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.


# All other controllers inherit from this controller. Several sitewide 
# configurations are done here
class ApplicationController < ActionController::Base
  # Force SSL and protect against CSRF
  config.force_ssl = false
  protect_from_forgery

  # Basic authentication
  http_basic_authenticate_with :name => "scale", :password => "Change_me!"

  # Disable caching as Firefox's aggresive caching does not work well
  # with the loading gifs. 
  before_filter :set_cache_headers

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  # Below are some URL / path helpers

  # This returns the path to the database page for a project
  def database_project_path(project)
  	"/projects/#{project.id}/database"
  end

  # This returns the system path to the backed up project archive
  # Most things are backedup except for raw source code
  def archive_backup_from_id(project_id)
  	Rails.root.join("archive/backup/#{project_id}").to_s
  end

  # This returns the system path to the not-backed up project archive
  # This is typically just the raw source code
  def archive_nobackup_from_id(project_id)
  	Rails.root.join("archive/nobackup/#{project_id}").to_s
  end
end



