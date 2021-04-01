# -*- coding: utf-8 -*-

# <legal>
# SCALe version r.6.5.5.1.A
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
    @display.update_attributes(params[:display].permit(
      :display, :id, :flag, :verdict, :ignored, :dead,
      :inapplicable_environment, :dangerous_construct,
      :previous, :path, :line, :link, :message, :checker, :tool,
      :condition, :title, :severity, :likelihood, :remediation,
      :priority, :level, :cwe_likelihood, :notes, :project_id,
      :meta_alert_id, :alert_id, :code_language))

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

    @tmp = Project.find_by_id(@project_id).displays
    @display_id = @tmp.pluck(:display_id).length + 1
    @project_languages = Language.by_project_id(@project_id)

    # Manually created entries have a meta alert ID that ends with 99,
    # so find the first such ID that is not being used.
    @meta_alert_id = 99
    if not '#{@tmp.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@tmp.id.to_s}"
    else
      while(@tmp.exists?(meta_alert_id: @meta_alert_id))
        @meta_alert_id += 100
      end
    end
  end

  # This action creates the new alert table entry display with the form
  # input from displays/new.html.erb
  def create
    @display = Display.new(params[:display].permit(
      :display, :id, :flag, :verdict, :ignored, :dead,
      :inapplicable_environment, :dangerous_construct,
      :previous, :path, :line, :link, :message, :checker, :tool,
      :condition, :title, :class_label, :confidence, :meta_alert_priority,
      :severity, :likelihood, :remediation, :priority, :level,
      :cwe_likelihood, :notes, :project_id, :meta_alert_id,
      :alert_id, :code_language))

    # After creating a new object, we parse the line and attempt
    # to match it to the GNU global pages.
    f = File.open(File.join(Rails.root, "public/GNU/#{params[:display][:project_id].to_s}/HTML", "FILEMAP"))
    dict = {}

    f.each_line do |line|
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
      @code_language = params[:display][:code_language]

      render 'new'
    end
  end

  # Action to show a particular display object. This is rendered
  # as a modal on the view page when you select the "more" link
  # to see all the messages.
  def show

    @display = Display.find(params[:project_id])

    @messages =  Message.where("alert_id = " + @display.alert_id.to_s +
                               " AND project_id = " + @display.project_id.to_s)

    @determinations = Determination.where(
      "meta_alert_id = " + @display.meta_alert_id.to_s +
      " AND project_id = " + @display.project_id.to_s)

    respond_to do |format|
      format.html  {render :template => "displays/messages"}
      format.json {head :no_content}
    end

  end

end
