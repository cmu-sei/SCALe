# -*- coding: utf-8 -*-
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.


# Display controller: A row in the database is a display object
# Manage the individual display actions. This controller deals
# with the normal CRUD operations for Display objects. 
class DisplaysController < ApplicationController
  respond_to :html, :json

  # This index action is available as a convenience method
  # for the test suite. 
  def index
    render json: Display.all
  end

  # The update action updates the attributes of a display. 
  def update
    @display = Display.find(params[:id])

    # update_attributes is used here. There is no mass assignment
    # risk since there is no sensitive / administration values 
    # that can be set in the display object. 
    @display.update_attributes(params[:display])
    respond_to do |format|
      format.html {
        respond_with @display
      }
      format.json { 
        # Respond with best_in_place helper 
        respond_with_bip(@display) 
      }
    end

  end

  # Action to display the form for creating a new display
  def new
    @display = Display.new
    @project_id = params[:project_id]

    # Manually created entries have an ID that ends with 99, 
    # so find the first such ID that is not being used. 
    @meta_alert_id = 99
    tmp = Project.find_by_id(@project_id).displays
    if not '#{@tmp.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@tmp.id.to_s}"
    else
      while(tmp.exists?(meta_alert_id: @meta_alert_id))
        @meta_alert_id += 100
      end
    end
  end

  # This action actually creates the new display with the form
  # input from the page rendered from 'new'
  def create
    @display = Display.new(params[:display])

    # After creating a new object, we parse the line and attempt 
    # to match it to the GNU global pages. 
    f = File.open(File.join(Rails.root, "public/GNU/#{params[:display][:project_id].to_s}/HTML", "FILEMAP"))
    dict = {}
    
    f.lines.each do |line|
      l = line.split(" ")
      dict[l[0].downcase] = l[1]
    end
      
      r = params[:display]
      link = ""
      path = r[:path].downcase
      if defined?(path) && defined?(dict[path]) && !dict[path].nil?
        link = "/GNU/#{r[:project_id].to_s}/HTML/" + dict[path]
      else
        link = "/GNU/#{r[:project_id].to_s}/HTML/"
      end
      if !r[:line].nil?
        link = link.to_s + "#L"+ (r[:line].to_s)
      end
      @display.link = link

    if @display.save
      # Handle a successful save.
      redirect_to "/projects/#{params[:display][:project_id]}"
    else
      @project_id = params[:display][:project_id]
      @meta_alert_id = params[:display][:meta_alert_id]
      @diagnostic_id = params[:display][:diagnostic_id]
      render 'new'
    end
  end

  # Action to show a particular display object. This is rendered
  # as a modal on the view page when you select the "more" link
  # to see all the messages. 
  def show
    @display = Display.find(params[:id])
    
    @messages =  Message.where("diagnostic_id = " + @display.diagnostic_id.to_s +
                               " AND project_id = " + @display.project_id.to_s)
  end
  
end
