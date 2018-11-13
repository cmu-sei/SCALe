# -*- coding: utf-8 -*-
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.


# This controller is for viewing and updating diagnostics
# Index - Controller to view diagnostics
# massUpdate - using multiple select boxes to update the verdict


$diagsHash = Hash.new


class DiagnosticsController < ApplicationController
  respond_to :html, :json
  require 'csv'

  def index
    # Fetch all the form components
    @ID = (params[:diagID] == "" || params[:ID] == nil) ? "" : params[:ID]
    @meta_alert_ids = (params[:meta_alert_id] == "" || params[:meta_alert_id] == nil) ? "" : params[:meta_alert_id] 
    @diagnostic_ids = (params[:diagnostic_id] == "" || params[:diagnostic_id] == nil) ? "" : params[:diagnostic_id] 
    @verdict = params[:verdict] == nil ? -1 : params[:verdict]
    @previous = params[:previous] == nil ? -1 : params[:previous]
    @diagsPerPage = params[:diagsPerPage] ? params[:diagsPerPage].to_i : DEFAULT_DIAGS_PER_PAGE
    @sort_direction = params[:sort_direction] ? params[:sort_direction] : "asc"
    @path = (params[:path] == "" || params[:path] == nil) ? "" : params[:path] 
    @line = (params[:line] == "" || params[:line] == nil) ? "" : params[:line] 
    @tool = (params[:tool] == "" || params[:tool] == nil) ? "" : params[:tool] 
    #@sort_column = params[:sort_column] ? params[:sort_column] : "id"
    @sort_column = params[:sort_column] ? params[:sort_column] : "priority"
    @checker = (params[:checker] == "" || params[:checker] == nil) ? "" : params[:checker]
    @rule = (params[:rule] == "" || params[:rule] == nil) ? "" : params[:rule]
    @selected_id_type = (params[:id_type] == "" || params[:id_type] == nil) ? "" : params[:id_type]
    @selected_taxonomy = (params[:taxonomy] == "" || params[:taxonomy] == nil) ? "" : params[:taxonomy]
    @project_id = (params[:project_id] == "" || params[:project_id] == nil) ? Project.first.id : params[:project_id]
    ## can add notes and cwe_likelihood later for filtering
	# @cwe_likelihood = (params[:cwe_likelihood] == nil || params[:cwe_likelihood] == "") ? -1 : params[:cwe_likelihood]
	# @notes = (params[:notes] == nil || params[:notes] == "") ? -1 : params[:notes] 
	
	  # Using triple-click to select and copy a path from the web app
	  # will include a leading and trailing space, so remove them.


        # Load the diagnostics view page
        @project = Project.find_by_id(@project_id)

          #Taxonomies

          @cert_rules = []
          @cwes = []

          @project.displays.pluck(:rule).uniq.each do |r|
             rule_prefix = r[0..2]
             if rule_prefix == "CWE"
               @cwes.append(r)
             else
               @cert_rules.append(r)
             end
          end


          @options_for_ids = ["All IDs", "Diagnostic ID", "Meta-Alert ID"]
          @ids = Hash.new
          @ids["All IDs"] = ""
          @ids["Diagnostic ID"] = @diagnostic_ids
          @ids["Meta-Alert ID"] = @meta_alert_ids
          #<%= select_tag(:id_type, options_for_select(@options_for_ids, selected: @ids[@selected_id_type])) %>  
          #<%= number_field_tag(:ID, @ID) %>


          @options_for_categories = ["View All", "CWEs", "CERT Rules"]
          @taxonomies = Hash.new
          @taxonomies["View All"] = ""
          @taxonomies["CWEs"] = @cwes
          @taxonomies["CERT Rules"] = @cert_rules
          


    @path = @path.strip 
    

    #if(@selected_id_type == "All IDs")
    #  @diagID = @ids["All IDs"]
    #elsif(@selected_id_type == "Diagnostic ID")
    #  @diagID = @ids["View All"]
    #else #@selected_id_type == "Meta-Alert ID"
    # @diagID = @ids["Meta-Alert ID"]
    #end




    if(@selected_taxonomy == "View All")
      @taxonomy = @taxonomies["View All"]
    elsif(@selected_taxonomy == "CWEs")
      @taxonomy = @taxonomies["CWEs"]
    else #@selected_taxonomy == "Cert Rules"
      @taxonomy = @taxonomies["CERT Rules"]
    end

    
    
    # Construct the SQL query
      filter = Display.constructSQLFilter(@project_id, @selected_id_type, @ID, @verdict, @previous, @path, @line, @tool, @checker, @rule, @taxonomy) #, @cwe_likelihood, @notes)


    # If no page selected, default to the first
    page = params[:page].to_i || 1
    page = page > 1 ? page : 1

    respond_to do |format|
      format.html {

        if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
          print "invalid project id: #{@project.id.to_s}"
        else
          @checkers = @project.displays.pluck(:checker).uniq.map {|a| [a,a]}.sort.unshift(["All Checkers", ""])
          @tools = @project.displays.pluck(:tool).uniq.map {|a| [a,a]}.sort.unshift(["All Tools", ""])
          @rules = @project.displays.pluck(:rule).uniq.map {|a| [a,a]}.sort.unshift(["All", ""])
          


          @projects = Project.all.map {|p| [p.name, p.id]}.sort
        end
      }
      format.js {
        # Respond to AJAX requests to load the diagnostics tables
        # @temp contains non-fused alerts
        # @fusedDiags may contain some fused alerts
        # The frontend will decide which of the two to display
	ordering = @sort_column + " " + @sort_direction + ", path asc, line asc"
        @displays = Display
                    .where(filter)
                    .order(ordering)

        @temp = Display
                .where(filter)
                .paginate(per_page: @diagsPerPage, page: params[:page])
                .order(ordering)

	@fastDiagIds = []
	@fusedDiagIds = []

        @fusedDiagsFull = []
        @fusedDiagIdsFull = []

        @metaAlerts = Set.new
        @subAlerts = Set.new

        @temp.each do |d|
          row_id = d[:id].to_i
          @fastDiagIds.append(row_id)
          $diagsHash[row_id] = d
        end

        #@fastDiagIds.each do |id|
        #  puts @diagsHash[id][:meta_alert_id].to_s
        #end
        #puts "\n"

        @fusedDiagnostics = @displays.group_by { |d| d[:meta_alert_id] }
        @fusedDiagsFull = @fusedDiagnostics.values.flatten()
        @fusedDiagIdsFull = @fusedDiagsFull.collect { |d| d[:id] }
        @fusedDiagnostics.each do |k, v|
          if v.length > 1
            @metaAlerts.add(v.first[:id])
            v.drop(1).each do |d|
              @subAlerts.add(d[:id])
            end
          end
        end
        
        #@fusedDiagIdsFull.each do |id|
        #  puts @diagsHash[id][:id].to_s
        #end
        #puts "\n"
        #puts @metaAlerts.length
        #@metaAlerts.each do |d|
        #  puts d
        #end
        #puts "\n"

	@diagsStart = @diagsPerPage * (page-1) + 1
        @diagsEnd = @diagsPerPage * (page-1) + (@temp.length)
        @diagsTotal = @displays.length

        #Now do pagination, but in a fused alert, only the first one counts towards the limit.
        i = @diagsStart - 1
        @fusedDiags = []
        maxDiagsOnThisPage = @diagsPerPage - 1
        #Stop adding diags when we run out of diags or hit the max allowed on this page
        while i < @diagsTotal && i < (@diagsStart + maxDiagsOnThisPage)
          #if we find a fused alert, we can have one more diag on this page
          if ((i+1 < @diagsTotal) && 
               @fusedDiagsFull[i][:meta_alert_id] == @fusedDiagsFull[i+1][:meta_alert_id] &&
               @fusedDiagsFull[i][:id]   != @fusedDiagsFull[i+1][:id]   )
            maxDiagsOnThisPage+=1
          end #end if
          fused_row_id = @fusedDiagsFull[i][:id]
          $diagsHash[fused_row_id] = @fusedDiagsFull[i]
          @fusedDiags.push(@fusedDiagsFull[i])
          @fusedDiagIds.push(@fusedDiagIdsFull[i])
          i+=1
        end #end while
        #puts DiagnosticsController.diagsHash.length
        #puts @fastDiagIds.length
        #puts @fusedDiagIds.length
        #puts @metaAlerts.length
        #puts @subAlerts.length
        #@subAlerts.each do |d|
        #  puts d
        #end
        #puts @fusedDiags.length
        #puts @temp.length
      }
    end
  end



#fused view

  def unfused
    #puts "calling Controller function fusedIndex"
    index()
  end
#end fused view

  def fusedUpdate

      row_id = params[:row_id].to_i
      meta_alert_id = params[:meta_alert_id].to_i
      diagnostic_id = params[:diagnostic_id].to_i
      
      elem = params[:elem].to_s
      new_value = params[:value]

      $diagsHash.map{|k, v| 

      d = Display.find_by_id(k)
      if(d.meta_alert_id == meta_alert_id) 
        if(elem == "flag") 
          d.update_attribute(:flag, new_value)
        end
        if(elem == "verdict")    
          d.update_attribute(:verdict, new_value.to_i)
        end
        if(elem == "notes")
          d.update_attribute(:notes, new_value)
        end
        if(elem == "supplemental")
          d.update_attribute(:ignored, new_value[0])
          d.update_attribute(:dead, new_value[1])
          d.update_attribute(:inapplicable_environment, new_value[2])
          d.update_attribute(:dangerous_construct, new_value[3])
        end

      end

      } #end map
      
  end


  def massUpdate
    # This controller action will set all checked off diagnostics to the
    # desired flag and verdict via an AJAX request. 

    # Fetch the desired verdict, flag, and notes sent via the form
    verdict = params[:mass_update_verdict].to_i
    flag = params[:flag]
    notes = params[:notes]

    # For each selected diagnostic, update its verdict, flag, and notes (if set)
    selectedDiags = params[:selectedDiags] || []

    selectedDiags.map{|id|
      d = Display.find_by_id(id)
      if(verdict != -1)
        d.update_attribute(:verdict, verdict)
      end
      if(params[:flag] != "-1")
        d.update_attribute(:flag, flag)
      end
    }
  end

  def export
    # This controller action will dump a ZIP file consisting of CSV files.
    # The 'display' CSV will contain data from the web app display.
    # The other CSVs represent the metrics tables; one CSV per table.

    columns = [:meta_alert_id, :flag, :verdict, :dead, :ignored,
               :inapplicable_environment, :dangerous_construct,
               :previous, :path, :line, :link, :message, :checker,
               :tool, :rule, :title, :severity, :liklihood,
               :remediation, :priority, :level, 
               :cwe_likelihood, :notes, ]
    #columns = [:id, :flag, :verdict]
    @project = Project.find_by_id(params[:project_id])
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else
      @displays = @project.displays
      display_csv = CSV.generate do |csv| 

        csv << columns

        @displays.each do |d| 
          row = columns.map do |col|
            case col
            when :flag
              if d[col]
              then "X"
              else ""
              end
            when :verdict
              numToVerdict(d[col])
            else
              d[col]
            end
          end
          csv << row
        end
      end

      timestamp = Time.now.strftime('%Y-%m-%d_%H:%M:%S')

      zipname = "#{@project.name}-#{timestamp}.zip"
      zipfilename = Rails.root.join("db/backup/#{zipname}")
      Dir.chdir("tmp") do
        Zip::ZipFile.open(zipfilename, Zip::ZipFile::CREATE) do |zipfile|
          zipfile.get_output_stream("display.csv") do |output_entry_stream| #Filename
            output_entry_stream.write(display_csv)            #generated content
          end

        zipfile.get_output_stream("display.csv") do |output_entry_stream| #Filename
          output_entry_stream.write(display_csv)            #generated content
        end

          ActiveRecord::Base.remove_connection
          ActiveRecord::Base.establish_connection :external
          con = ActiveRecord::Base.connection()

          ["Lizard", "Ccsm", "Understand"].each do |metric|  # TODO read table names from scripts/tools.org
            table = con.quote_string("#{metric}Metrics")
            query = "SELECT name FROM sqlite_master WHERE "+
                    "type='table' AND name='#{table}'";
            if con.execute(ActionController::Base.helpers.sanitize(query)).count > 0
              query = "SELECT * FROM '#{table}'"
              res = con.execute(ActionController::Base.helpers.sanitize(query))
              if res.length > 0
                columns = res[0].keys
                columns = columns[0..columns.index(0) - 1]  # to remove numeric keys
                metric_csv = CSV.generate do |csv|
                  csv << columns
                  res.each do |r|
                    row = columns.map do |c|
                      r[c]
                    end
                    csv << row
                  end # res.each
                end # CSV.generate
                zipfile.get_output_stream("#{table}.csv") do |output_entry_stream|
                  output_entry_stream.write(metric_csv)
                end
              end # if
            end # if
          end # each

          ActiveRecord::Base.remove_connection
          ActiveRecord::Base.establish_connection :development
          con = ActiveRecord::Base.connection()
        end # open
      end # Dir.chdir

      send_data( zipfilename.read, type: 'application/zip', filename: zipname)
      if File.exists?(zipfilename)
        File.delete(zipfilename)
      end
    end
  end

  def exportDB
    # This controller action will dump a sqlite database in the external
    # SCALe DB format. It does so by updating the verdicts of the database
    # generated by the scripts, and inserts the manually created entries. 
    environment = :development
    ActiveRecord::Base.establish_connection environment
    con = ActiveRecord::Base.connection()

    @project = Project.find_by_id(params[:project_id])
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else
      @displays = @project.displays

      @displays.reload
      
      FileUtils.cp(Rails.root.join("db/backup/#{@project.id}/external.sqlite3"),Rails.root.join('db/external.sqlite3')) 

      ActiveRecord::Base.remove_connection
      ActiveRecord::Base.establish_connection :external
      con = ActiveRecord::Base.connection()

      @displays.each do |d|
        #Convert bools to ints before sending
        flag = d.flag ? 1 : 0
        ignored = d.ignored ? 1 : 0
        dead = d.dead ? 1 : 0
        inapplicable_environment = d.inapplicable_environment ? 1 : 0

        if d.checker != "manual"
          # If not a manual entry, update the user-editable fields accordingly
          query = "UPDATE MetaAlerts SET verdict=#{con.quote(d.verdict)},"+
                  "flag=#{con.quote(flag)}, notes='#{con.quote_string(d.notes)}',"+
                  "ignored=#{con.quote(ignored)}, dead=#{con.quote(dead)},"+
                  "inapplicable_environment=#{con.quote(inapplicable_environment)}, "+
                  "dangerous_construct=#{con.quote(d.dangerous_construct)}"+
                  " WHERE id=#{con.quote(d.meta_alert_id)}"
          con.execute(ActionController::Base.helpers.sanitize(query))
        else
          # Otherwise, we need to insert the message and get its ID
          query = "INSERT INTO Messages (diagnostic, path, line, message)"+
                  " VALUES (#{con.quote(d.id)}, '#{con.quote_string(d.path)}',"+
                  " #{con.quote(d.line)}, '#{con.quote_string(d.message)}')"
          con.execute(ActionController::Base.helpers.sanitize(query))
          query = "SELECT id FROM Messages WHERE diagnostic=#{con.quote(d.id)}"
          res = con.execute(ActionController::Base.helpers.sanitize(query))
          diag_id = res[0]["id"]
          query = "INSERT INTO Diagnostics (id, checker, primary_msg) "+ # diagnostics
                  " VALUES (#{con.quote(d.meta_alert_id)}, '#{con.quote_string(d.checker)}',"+
                  "#{con.quote(diag_id)})"
          con.execute(ActionController::Base.helpers.sanitize(query))
          query = "INSERT INTO MetaAlerts (id, flag, verdict, previous, "+
                  "notes, ignored, dead, inapplicable_environment,"+
                  "dangerous_construct) VALUES ("+
                  "#{con.quote(d.id)}, #{con.quote(flag)},"+
                  "#{con.quote(d.verdict)}, #{con.quote(d.previous)},"+
                  "'#{con.quote_string(d.notes)}', #{con.quote(d.ignored)},"+
                  "#{con.quote(d.dead)},"+
                  "#{con.quote(d.inapplicable_environment)}, "+
                  "#{con.quote(d.dangerous_construct)},"+
                  "#{con.quote(d.confidence)}, #{con.quote(d.alert_priority)})"
          con.execute(ActionController::Base.helpers.sanitize(query))
        end
      end

      ActiveRecord::Base.remove_connection

      ActiveRecord::Base.establish_connection environment
      con = ActiveRecord::Base.connection()

      timestamp = Time.now.strftime('%Y-%m-%d_%H:%M:%S')
      send_file(Rails.root.join('db/external.sqlite3'), filename: "#{@project.name}-#{timestamp}.sqlite3")
    end
  end
  
  def show
 
    @diagnostic = "diagnostic"
    @display = Display.find(params[:id])
    @messages =  Message.where("diagnostic_id = " + @display.diagnostic_id.to_s +
                               " AND project_id = " + @display.project_id.to_s)
    @is_meta_alert = 1
    #puts @display.meta_alert_id.to_s
    @meta_alerts =  Display.where("meta_alert_id = " + @display.meta_alert_id.to_s +
                               " AND project_id = " + @display.project_id.to_s)
    #puts @meta_alerts.length
    if @meta_alerts.length > 1
      @is_meta_alert = 0
    end
    #puts @is_meta_alert.to_s
  end

end
