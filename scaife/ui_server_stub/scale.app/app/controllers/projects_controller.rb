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

# This file defines the actions corresponding to various CRUD
# actions for the project model.

require 'utility/timing'

class ProjectsController < ApplicationController

  include TransferFile
  include Utility::Timing

  # The show action is not ever rendered as an html page (since the
  # all the project info is shown on the main page).
  # If this were restructured, I would remove the alertConditions controller
  # and make the main project page the show action.
  # However, currently this action is defined simply to give an project API
  # for the test suite.
  def show
    @project = Project.find(params[:id])
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else
      respond_to do |format|
        format.html
        format.json  { render :json => @project }
      end
    end
  end


  # This action is for the main page; query all projects and send it to
  # the view. There is also a JSON response for the API.
  def index
    #puts "SCALe splash page"
    @errors = []
    @projects = Project.all
    @scaife_active = scaife_active()
    $stdout.flush
    @languages_available = Language.all()
    @taxonomies_available = Taxonomy.all()
    @tools_available = Tool.all()

    respond_to do |format|
      format.html
      format.json  { render :json => @projects }
    end
  end


  # This action shows the create new project page, so we initialize a
  # new project.
  def new
    @project = Project.new
  end

  # This action creates a new SCAIFE project.
  def scaife
      @get_projects_status = -1
      @get_packages_status = -1
      @scaife_projects_descriptions = Hash.new
      @scaife_packages_descriptions = Hash.new

      @project = Project.find(params[:project_id])
      @project_name = @project.name
      @project_description = @project.description


      c = ScaifeDatahubController.new
      result = c.listProjects(session[:login_token])
      if result.is_a?(String) #Failed to connect to Registration/DataHub server
        puts "#{__method__}() error listProjects(): #{c.scaife_status_code}: #{result}"
        @get_projects_status = 400
      else
        @get_projects_status = 200
        for project_object in list_projects_response
          project_name = project_object.project_name
          project_description = nil
          if project_object.project_description.present?
            project_description = project_object.project_description
          else
            project_description = "None"
          end
          @scaife_projects_descriptions[project_name] = project_description
        end
      end

      list_packages_response = c.listPackages(session[:login_token])
      #puts list_packages_response
      if list_packages_response.is_a?(String) #Failed to connect to Registration/DataHub server
        @get_packages_status = 400
      else
        @get_packages_status = 200
        for package_object in list_packages_response
          package_name = package_object.package_name
          package_description = nil
          if package_object.package_description.present?
            package_description = package_object.package_description
          else
            package_description = "None"
          end
          @scaife_packages_descriptions[package_name] = package_description
        end
      end
      return
  end

  # This action creates a new project. We redirect to the database page
  # upon creation. If the project fails to save, then render the new
  # page and pass the errors along to the view.
  # This action creates a new SCALe project. We redirect to the database page
  # upon creation. If the project fails to save, then render the
  # new page and pass the errors along to the view.
  def create
    @scaife_mode = session[:scaife_mode]
    @project = Project.new(project_params)
    @project_type = params[:project_type]
    @scaife_active = scaife_active()
    if @project.save
      if Dir.exists?(archive_backup_dir_from_id(@project.id))
        msg = "External data already exists for project #{@project.id} #{archive_backup_dir_from_id(@project.id)} ... DELETING"
        puts msg
        self.nuke_project_files(@project.id)
      end
      @scaife_active = scaife_active()
      backup_dir = backup_dir_from_id(@project.id)
      if !Dir.exists?(backup_dir)
        FileUtils.mkdir_p backup_dir
      end
      archive_backup_dir = archive_backup_dir_from_id(@project.id)
      if !Dir.exists?(archive_backup_dir)
        FileUtils.mkdir_p archive_backup_dir
      end
      archive_nobackup_dir = archive_nobackup_dir_from_id(@project.id)
      if !Dir.exists?(archive_nobackup_dir)
        FileUtils.mkdir_p archive_nobackup_dir
      end
      supplemental_dir = archive_supplemental_dir_from_id(@project.id)
      if !Dir.exists?(supplemental_dir)
        FileUtils.mkdir_p supplemental_dir
      end
      # database() pulls tool/lang info from db/external.sqlite3, so go
      # ahead and instantiate it now (it clones tool/lang info from the
      # the persistent db)
      archive_db = archive_backup_db_from_id(@project.id)
      script = scripts_dir().join("init_project_db.py")
      cmd = "#{script} #{archive_db}"
      #puts cmd
      system(cmd)
      if "scale" == @project_type
        respond_to do |format|
          format.html  { redirect_to(database_project_path(@project)) }
          format.json  { render :json => @project,
                  :status => :created, :location => edit_project_path }
        end
      elsif "scaife" == @project_type
        respond_to do |format|
          format.html  { redirect_to(scaife_project_path(@project)) }
          format.json  { render :json => @project,
                  :status => :created, :location => edit_project_path }
        end
      end
    else
      respond_to do |format|
        format.html  { render :action => "new" }
        format.json  { render :json => @project.errors,
                :status => :unprocessable_entity }
      end
    end
  end


  def project_params
    params.require(:project).permit(:name, :description)
  end


  def add_gnu_global_pages(project)

    backup_path = backup_dir_from_id(project.id)
    if Dir.exists?(backup_path)
      FileUtils.rm_rf(backup_path)
    end
    Dir.mkdir backup_path
    FileUtils.cp(external_db(), backup_path)

    # Next, generate HTML source using htags from GNU Global
    source_path = archive_src_dir_from_id(project.id)

    Dir.chdir source_path

    puts "Generating GNU global pages..."
    start_time = Time.now

    system("htags -agn")

    end_time = Time.now
    duration = (end_time - start_time).to_i
    puts "[completed in #{duration.round(1)} s]"

    # Wipe destination for HTML source
    path = Rails.root.join("public/GNU/#{project.id.to_s}")
    clean_source_html(path)

    # Move HTML source to destination
    puts "Moving global pages..."
    start_time = Time.now
    FileUtils.mv("HTML", path)

    end_time = Time.now
    duration = (end_time - start_time).to_i
    puts "[completed in #{duration.round(1)} s]"

    Dir.chdir Rails.root
  end

  # This action shows the edit project page.
  def edit
    @errors = []
    @project = Project.find(params[:id])
    @scaife_active = scaife_active()
    # from web request, so must sanitize
    if not '#{@project.id.to_s}'.match('\d*')
      msg = "invalid project id: #{@project.id.to_s}"
      print msg
      @errors << msg
    else
      # Pass some more useful parameters to the view. Specifically,
      # these parameters keep track of what checkboxes are already
      # marked and what files are already uploaded. @out will
      # contain the output of digest_alerts.
      @params = {}
      @params[:map] = params[:map]
      @uploaded = {}
      @out = {}
      @out_multiple = {}
      @project.is_test_suite = @project.test_suite_version.blank?
      @tool_groups = ToolGroup.all()
      @languages_available = @project.languages()
      @taxonomies_available = @project.taxonomies()
      @tools_available = @project.tools()
      if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
        print "invalid project id: #{@project.id.to_s}"
      else
        project_id = params[:id]

        if nil == @project.publish_data_updates
         @project.publish_data_updates = 0
        end

        if nil == @project.subscribe_to_data_updates
         @project.subscribe_to_data_updates = 0
        end

        @project.is_test_suite = @project.test_suite_version.blank? ? false : true
        ToolGroup.all_by_key().each do |tool_key, tool_group|
          unless tool_key.start_with? "swamp"
            tool_group.tools().each do |tool|
                warning_file = "GNU/#{project_id.to_s}/analysis/#{tool.id}.txt"
                if File.exists?("public/#{warning_file}")
                  @uploaded[tool_key] = true
                  warnings = `cat public/#{warning_file}`
                  if warnings.length() == 0
                    @out[tool_key] = "" # success
                  else
                    @out[tool_key] = warning_file  # link to warnings
                  end
                end
              end
          else #  SWAMP tool information
              tool = tool_group.tool_from_version("") # Get the swamp tool
              warning_file = "GNU/#{project_id.to_s}/analysis/#{tool.id}_*.txt"
              swamp_warning_files = Dir.glob("public/#{warning_file}")

              if swamp_warning_files.length == 1
                @uploaded[tool_key] = true
                warnings = `cat #{swamp_warning_files[0]}`
                if warnings.length() == 0
                  @out[tool_key] = "" # success
                else
                  @out[tool_key] = swamp_warning_files[0].sub('public/', '')  # link to warnings
                end
              elsif swamp_warning_files.length > 1
                @uploaded[tool_key] = true
                swamp_warning_files.each do |out_file|
                  puts out_file
                  tool_regex = out_file.match /#{tool.id}_(.*)\.txt$/
                  if tool_regex
                    actual_tool_key = tool_regex[1].tr("-","/")
                  end

                  warnings = `cat #{out_file}`
                  @out_multiple[tool_key] = {}

                  if warnings.length() == 0
                    @out_multiple[tool_key][actual_tool_key] = ""
                  else
                    @out_multiple[tool_key][actual_tool_key] = out_file.sub('public/', '').to_s  # link to warnings
                  end
                end
              end
          end
        end
      end

    end
  end

  # This action updates an existing project's tools, etc, but not the
  # project model itself. From the edit view.
  def update_project
    @project = Project.find(params[:project_id])
    @scaife_active = scaife_active()
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else
      # Pass some more useful parameters to the view. Specifically,
      # these parameters keep track of what checkboxes are already
      # marked and what files are already uploaded. @out will
      # contain the output of digest_alerts.
      @params = {}
      @params[:selectedTools] = params[:selectedTools]
      @params[:swampSelectedTools] = params[:swampSelectedTools]
      newly_uploaded = {}

      ext_db = external_db()
      analysis_path = archive_analysis_dir_from_id(@project.id)
      if @project.source_file.blank?
        respond_to do |format|
          format.html  {redirect_to("/projects/#{@project.id}/edit",
                                    :notice=> "Project does not have a source file")}
          format.json {head :no_content}
        end
        return
      end
      @project.is_test_suite = @project.test_suite_version.blank? ? false : true

      # If any tools were selected, then we run digest_alerts.py:
      if params[:selectedTools].present?
        # First make sure the analysis path exists
        if !Dir.exists?(analysis_path)
          FileUtils.mkdir_p analysis_path
        end

        # For each select tool, write the uploaded analysis to the server
        backup = false
        upload_name = {}
        params[:selectedTools].each do |tool_key|
          #swamp tool version is []
          tool_version = (tool_key.start_with? "swamp") ? "" : params[:tool_versions][tool_key]
          tool_group = ToolGroup.from_key(tool_key)
          tool = tool_group.tool_from_version(tool_version)
          analysis = params[:file] ? params[:file][tool_key] : nil
          if analysis.present?
            orig_name = analysis.original_filename
            if params[:swampSelectedTools] and params[:swampSelectedTools][tool_key]
              tool_uploaded = params[:swampSelectedTools][tool_key].tr("/", "-")
            end
            # SWAMP file names will have the following syntax: <swamp_tool_id>_<tool_name>-<platform>
            target_name = (tool_key.start_with? "swamp") ? "#{tool.id}_#{tool_uploaded}#{File.extname(orig_name)}" : "#{tool.id}#{File.extname(orig_name)}"
            upload_name[tool_key] = target_name
            File.open("#{analysis_path}/#{target_name}", 'wb') do |file|
              file.write(analysis.read)
              newly_uploaded[tool_key] = tool
              backup = true
            end
          end
        end
        if backup
          backup_db = AlertConditionsController.archiveDB(@project.id)
          timestamp_backup_db_path = \
            backup_external_db_timestamp_from_id(@project.id)
          FileUtils.cp(backup_db, timestamp_backup_db_path)
          FileUtils.cp(backup_db, ext_db)
        end

        # This is the command to run for digest_alerts. The second part
        # will pipe the output to ##.out where ## is the number corresponding
        # to the tool.
        if newly_uploaded.present?
          source_path = archive_src_dir_from_id(@project.id)
          script = scripts_dir().join("digest_alerts.py")
          gnu_analysis_path = "GNU/#{@project.id}/analysis"

          newly_uploaded.each do |tool_key, tool|
            target_name = upload_name[tool_key]

            if tool_key.start_with? "swamp" # Get the actual tool information
              swamp_tool = tool

              actual_tool_key = params[:swampSelectedTools][tool_key]
              tool_version = params[:tool_versions][tool_key].to_s

              tool_group = ToolGroup.from_key(actual_tool_key)
              actual_tool = tool_group.tool_from_version(tool_version)

              # SWAMP file names will have the following syntax: <swamp_tool_id>_<tool_name>-<platform>
              file_tool_key = actual_tool_key.tr("/", "-")

              out_file = "#{analysis_path}/#{swamp_tool.id}_#{file_tool_key}.out"
              cmd = "#{script} #{ext_db} #{analysis_path}/#{target_name} -i #{actual_tool.id} -k #{swamp_tool.id} -s #{source_path} > #{out_file} 2>&1"
              system(cmd)
              res = File.read(out_file)
              if res.present?
                puts "ran: #{cmd}"
                puts "result: #{res}"
              end
              FileUtils.cp(out_file, Rails.root.join("public/" + gnu_analysis_path).join("#{swamp_tool.id}_#{file_tool_key}.txt"))
            else
              out_file = "#{analysis_path}/#{tool.id}.out"
              cmd = "#{script} #{ext_db} #{analysis_path}/#{target_name} -i #{tool.id} -s #{source_path} > #{out_file} 2>&1"
              system(cmd)
              res = File.read(out_file)
              if res.present?
                puts "ran: #{cmd}"
                puts "result: #{res}"
              end
              FileUtils.cp( "#{analysis_path.to_s}/#{tool.id}.out", Rails.root.join("public/" + gnu_analysis_path).join("#{tool.id}.txt"))
            end

            if !@project.tools.exists? tool.id
              @project.tools << tool
            end
          end
          @project.save
        end
        Dir.chdir Rails.root

        if self.import_to_displays(@project.id) == "invalid"
          puts("database is not consistent! Run Project.manualCreate in the rails console to get a backtrace")
          redirect_to "/projects/#{@project.id}/database"
        else
          # If imported successfully, backup the database
          if !Dir.exists?(backup_dir())
            Dir.mkdir backup_dir()
          end

          add_gnu_global_pages(@project)

          # Create links
          Display.createLinks(@project.id)

          Dir.chdir Rails.root
        end
      end
    end

    respond_to do |format|
      format.html  {redirect_to("/projects/#{@project.id}")}
      format.json {head :no_content}
    end

  end


  # updates an existing project, from the edit view
  def update
    @project = Project.find(params[:id])
    @scaife_active = scaife_active()
    @non_fatal_error = nil
    if not '#{@project.id.to_s}'.match('\d*')
      # from web request, so must sanitize
      print "invalid project id: #{@project.id}"
    else
      source_path = archive_src_dir_from_id(@project.id)
      supplemental_path = archive_supplemental_dir_from_id(@project.id)
      @project.name = params[:project][:name]
      @project.description = params[:project][:description]
      @project.is_test_suite = @project.test_suite_name.blank? ? false : true
      @project.publish_data_updates = params[:project][:publish_data_updates]
      @project.subscribe_to_data_updates = params[:project][:subscribe_to_data_updates]

      if @project.publish_data_updates or @project.subscribe_to_data_updates
        if nil == @project.scaife_project_id
          @non_fatal_error = "Must upload the project to SCAIFE before selecting Publish/Subscribe to Data Updates in SCAIFE"
          flash[:scaife_enable_data_forwarding_message] =  @non_fatal_error
          respond_to do |format|
              format.any { redirect_to "/projects/#{@project.id}/edit" and return}
          end
        end       
      end
      
      if @project.subscribe_to_data_updates
        if @scaife_active 
          scaife_project_id = @project.scaife_project_id

          c = ScaifeDatahubController.new
          result, status_code = c.enableDataForwarding(session[:login_token], scaife_project_id)
          if 200 == status_code
            @non_fatal_error = nil
            Dir.chdir scripts_dir()
            # Start a subscription for this project
            pid = Process.fork
            if pid.nil? then
              puts "CALLING THE SCRIPT"
              exec "./datahub_subscriber.py 'ui_determination' '#{@project.scaife_project_id}' > log/subscription.datahub.log"
            else
              Process.detach(pid)
            end
            @project.data_subscription_id = pid
          else
            flash[:scaife_enable_data_forwarding_message] =  result
            respond_to do |format|
              format.any { redirect_to "/projects/#{@project.id}/edit" and return}
            end
          end
        else
          @non_fatal_error = "Failed to enable data forwarding. Please verify that you are connected to SCAIFE."
          flash[:scaife_enable_data_forwarding_message] =  @non_fatal_error
          respond_to do |format|
              format.any { redirect_to "/projects/#{@project.id}/edit" and return}
          end
        end
      else
        if @project.scaife_project_id
          Dir.chdir scripts_dir()
          # Close a subscription for this project
          # Future iterations may use other information like user info to decipher
          # which processes to kill. 
          if @project.data_subscription_id
            begin
              Process.kill('QUIT', @project.data_subscription_id.to_i)
            rescue
              puts 'No Process Running with ID: ' + @project.data_subscription_id
            end
            puts 'Closed Connection on Topic: ' + @project.scaife_project_id
            @project.data_subscription_id = nil
          end
        end
      end
      
      if @project.is_test_suite
        @project.test_suite_name = params[:project][:test_suite_name]
        @project.test_suite_version = params[:project][:test_suite_version]
        @project.test_suite_type = params[:project][:test_suite_type]
        @project.test_suite_sard_id = params[:project][:test_suite_sard_id]
        @project.author_source = params[:project][:author_source]
        @project.license_file = params[:project][:license_file]
        manifest = params[:file] ? params[:file][:manifest_file] : nil
        manifest_url = params[:project][:manifest_url].strip
        if manifest.present?
          puts "uploading manifest file..."
          if isValidManifest(manifest.original_filename)
            new_file = supplemental_path.join(manifest.original_filename)
            upload_stream_to(manifest, new_file)
            if @project.manifest_file.present?
              File.unlink(@project.manifest_file)
            end
            if @project.manifest_file.present?
              f = source_path.join(@project.manifest_file)
              if File.exists? f
                File.unlink(f)
              end
            end
            @project.manifest_file = File.basename(new_file)
            @project.manifest_url = nil
          else
            @project.errors.add(:manifest_file, "invalid manifest format (.xml, .zip, .tgz, .tar.gz)")
          end
        elsif manifest_url.present?
          puts "fetching manifest URL: " + manifest_url
          code, status, new_file = download_url_to(manifest_url, supplemental_path)
          if new_file.blank?
            @project.errors.add(:manifest_url, "#{code} #{status}")
          elsif !isValidManifest(new_file)
            @project.errors.add(:manifest_url, "invalid manifest file format (.xml, .zip, .tgz, .tar.gz)")
          else
            if @project.manifest_file.present?
              f = source_path.join(@project.manifest_file)
              if File.exists? f
                File.unlink(f)
              end
              @project.manifest_file = File.basename(new_file)
              @project.manifest_url = manifest_url
            end
          end
        end
        function_info = params[:file] ? params[:file][:function_info_file] : nil
        if function_info.present?
          puts "uploading function info file..."
          new_file = supplemental_path.join(function_info.original_filename)
          upload_stream_to(function_info, new_file);
          if @project.function_info_file.present?
            f = source_path.join(@project.function_info_file)
            if File.exists? f
              File.unlink(f)
            end
          end
          @project.function_info_file = File.basename(new_file)
        end
        file_info = params[:file] ? params[:file][:file_info_file] : nil
        if file_info.present?
          puts "uploading file info file..."
          new_file = supplemental_path.join(file_info.original_filename)
          upload_stream_to(file_info, new_file);
          if @project.function_info_file.present?
            f = source_path.join(@project.function_info_file)
            if File.exists? f
              File.unlink(f)
            end
          end
          @project.file_info_file = File.basename(new_file)
        end
      end
      respond_to do |format|
        if @project.errors.any?
          format.html  { render :action => "edit" }
          format.json  { render :json => @project.errors,
                                :status => :unprocessable_entity }
        elsif @project.save
          format.html  { redirect_to("/") }
          format.json  { head :no_content }
        else
          format.html  { render :action => "edit" }
          format.json  { render :json => @non_fatal_error,
                                :status => :unprocessable_entity }
        end
      end
    end
  end

  def nuke_project_files(project_id)
    # delete all associated files of a defunct project from the
    # filesystem

    # clean up HTML pages
    path = Rails.root.join("public/GNU/#{project_id.to_s}")
    if Dir.exists?(path)
      shred(path)
    end

    # clean up original sqlite database and other files

    path = backup_dir_from_id(project_id)
    if Dir.exists?(path)
      shred(path)
    end

    path = archive_backup_dir_from_id(project_id)
    if Dir.exists?(path)
      shred(path)
    end

    path = archive_nobackup_dir_from_id(project_id)
    if Dir.exists?(path)
      shred(path)
    end

    shred(external_db())
  end

  # This option destroys a project. Since the alerts
  # and messages are linked as 'dependent-destroy', the database
  # will also clear out all corresponding alerts and messages
  # for the destroyed project. It also cleans up files used outside
  # of the archive.
  def destroy
    @project = Project.find(params[:id])
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else

      self.purge_project(@project.id)

      respond_to do |format|
        format.html { redirect_back fallback_location: projects_url }
        format.json { head :no_content }
      end

      #redirect_back fallback_location: projects_url, status: 303

    end
  end

  def purge_project(project_id)
    project = Project.find(project_id)
    if project.blank?
      print "invalid project id: #{project_id}"
    else
      project.destroy()
      self.nuke_project_files(project.id)
    end
  end


  def has_valid_archive_ext(fname)
    valid_exts = [".zip", ".tgz", ".tar.gz"]
    return valid_exts.any? { |ext| fname.to_s.end_with?(ext) }
  end


  def is_valid_upload(src)
    return (src != "") && (src != nil) && has_valid_archive_ext(src.original_filename)
  end


  def extract_uploaded_archive(src, dest)
    if src.to_s.end_with?( ".zip")
        system("unzip -nq  #{src} -d #{dest}")
    elsif [".tgz", ".tar.gz"].any? { |ext| src.to_s.end_with?( ext) }
        system("tar -xzf #{src} -C #{dest}")
    end
  end


  # This action will upload GNU global pages and linked them to the
  # corresponding project. It is assumed that the uploaded data is a
  # zip file.
  # This action is no longer used in the normal workflow, but is
  # left for manual uploading of pages on the edit project page.
  def upload_gnu_pages
    # First, find the project.
    @project = Project.find(params[:project_id])
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else

      # Get the uploaded pages from the parameters
      uploaded_io = params[:gnu_global]

      respond_to do |format|
        # Check to make sure the uploaded file exists and is non-empty
        if is_valid_upload(uploaded_io)
          # If so, first nuke any existing pages.
          path = Rails.root.join("public/GNU/#{@project.id.to_s}")
          if Dir.exists?(path)
            FileUtils.rm_rf(path)
          end
          Dir.mkdir path

          uploadOut = path.join(uploaded_io.original_filename)
          # Then, copy the pages over
          File.open(uploadOut, 'wb') do |file|
            file.write(uploaded_io.read)
          end
          extract_uploaded_archive(uploadOut, path)
          File.delete(uploadOut)

          # update the links for the corresponding project
          Display.createLinks(@project.id)

          format.html  { redirect_to("/",
                                     :notice => 'Project was successfully updated.') }
        else
          # Otherwise handle bad input.
          if uploaded_io == "" or uploaded_io == nil
            @project.errors.add(:gnu_global, "must have be valid and nonempty")
          end
          format.html { render :action => "edit" }
          format.json  { render :json => @project.errors,
                                :status => :unprocessable_entity }
        end
      end
    end
  end


  # Uploads determinations from an older project
  def upload_determinations
    # First, find the project.
    @old_project_id = params[:old_project_id]
    @new_project_id = params[:new_project_id]
    @old_project = Project.find(@old_project_id)
    @new_project = Project.find(@new_project_id)
    if not '#{@old_project_id.to_s}'.match('\d*')
      print "invalid project id: #{@old_project_id.to_s}"
    else
      if not '#{@new_project_id.to_s}'.match('\d*')
        print "invalid project id: #{@new_project_id.to_s}"
      else
        @new_ext_db = AlertConditionsController.archiveDB(@new_project_id)
        @old_ext_db = AlertConditionsController.archiveDB(@old_project_id)
        @old_src = archive_src_dir_from_id(@old_project_id)
        @new_src = archive_src_dir_from_id(@new_project_id)
        puts "Cascading Project..."
        start_time = Time.now
        now = start_time.strftime('%Y-%m-%d_%H:%M:%S')
        note = "Cascaded from #{@old_project.name} on #{now}\n"
        script = scripts_dir().join("cascade_verdicts.py")
        cmd = "#{script} #{@old_ext_db} #{@new_ext_db} #{@old_src} #{@new_src} -n \"#{note}\""
        res = `#{cmd}`
        if res.present?
          puts "ran: #{cmd}"
          puts "result: #{res}"
        end
        end_time = Time.now
        duration = (end_time - start_time).to_i
        puts "[completed in #{duration.round(1)} s]"
        FileUtils.cp(@new_ext_db, external_db())
        if self.import_to_displays(@new_project_id) == "invalid"
          puts("database is not consistent! Run Project.manualCreate in the rails console to get a backtrace")
          redirect_to "/projects/#{project_id}/database"
        else
          puts "Creating Links..."
          start_time = Time.now
          Display.createLinks(@new_project_id)
          end_time = Time.now
          duration = (end_time - start_time).to_i
          puts "[completed in #{duration.round(1)} s]"
          respond_to do |format|
            format.html {redirect_to("/projects/#{@new_project_id.to_s}",
                                     :notice=> "Done!")}
            format.json {head :no_content}
          end
        end
      end
    end
  end


  # This action will upload a scale database previously generated
  # by David's scripts and import the data into the Rails database.
  def upload_scale_db
    uploaded_io = params[:database]
    project_id = params[:project_id]
    @project = Project.find(params[:project_id])
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else
      archive_dir = archive_backup_dir_from_id(project_id)
      archive_db = archive_backup_db_from_id(project_id)
      ext_db = external_db()

      respond_to do |format|
        # If the uploaded file is non-empty:
        if uploaded_io != "" && uploaded_io != nil
          # First create the required directory structure
          if !Dir.exists? archive_dir
            FileUtils.mkdir_p archive_dir
          end

          # Copy the uploaded data to the target directory
          File.open(archive_db, 'wb') do |file|
            file.write(uploaded_io.read)
          end

          # Also copy it to external.sqlite3 for importing into Rails
          FileUtils.cp(archive_db, ext_db)

          # Run import_to_displays() to import the data from
          # external.sqlite3 If it fails, redirect to /database
          if self.import_to_displays(project_id) == "invalid"
            @project.errors.add(:sql, "is not consistent! Run Project.manualCreate in the rails console to get a backtrace")
            @project.destroy
            redirect_to "/database"
          else
            # Create links
            Display.createLinks(project_id)

            # If imported successfully, backup the database. First
            # create the backup directory if it doesn't exist:
            if !Dir.exists?(backup_dir())
              Dir.mkdir backup_dir()
            end

            # Then clean out the required directory where the backup
            # is placed
            backup_dir = backup_dir_from_id(project_id)
            if Dir.exists?(backup_dir)
              FileUtils.rm_rf(backup_dir)
            end
            Dir.mkdir backup_dir

            # Finally move the backup here.
            FileUtils.cp(ext_db, backup_dir)
            format.html  { redirect_to(@project) }
            format.json  { render :json => @project,
                                  :status => :created, :location => @project }
          end
        else
          if uploaded_io == "" or uploaded_io == nil
            @project.errors.add(:database, "must be valid and nonempty")
          end
          format.html  { render :action => "edit" }
          format.json  { render :json => @project.errors,
                                :status => :unprocessable_entity }
        end
      end
    end
  end

  def isValidArchive(f)
    return(['.zip', '.tgz'].include?(File.extname(f)) or f.to_s.end_with?(".tar.gz"))
  end

  def isValidManifest(f)
    return(['.xml', '.zip', '.tgz'].include?(File.extname(f)) or f.to_s.end_with?(".tar.gz"))
  end

  def findValidArchive(path)
    candidates = Dir.entries(path).select {|f| !File.directory? f}
    candidates.sort!.each do |f|
      if isValidArchive(f)
        return f.relative_path_from(path)
      end
    end
    return nil
  end

  # This controller handles both the showing of database page as well as
  # the subsequent construction of the database.
  def database
    #puts "database() #{params}"
    # First, fetch the project ID and construct useful paths
    @project = Project.find(params[:project_id])
    @scaife_active = scaife_active()
    source_path = archive_src_dir_from_id(@project.id)
    analysis_path = archive_analysis_dir_from_id(@project.id)
    supplemental_path = archive_supplemental_dir_from_id(@project.id)
    gnu_analysis_path = "GNU/#{@project.id}/analysis"
    db_path = archive_backup_db_from_id(@project.id)

    # Pass some more useful parameters to the view. Specifically,
    # these parameters keep track of what checkboxes are already
    # marked and what files are already uploaded. @out will
    # contain the output of digest_alerts.
    @params = {}
    @params[:map] = params[:map]
    @params[:selectedTools] = params[:selectedTools]
    @params[:swampSelectedTools] = params[:swampSelectedTools]
    @uploaded = {}
    @out = {}
    @out_multiple = {}
    @tool_groups = ToolGroup.all()

    @languages_available = @project.languages()
    @taxonomies_available = @project.taxonomies()
    @tools_available = @project.tools()

    if (params[:project] and params[:project][:is_test_suite])
      @project.is_test_suite = ActiveModel::Type::Boolean.new.cast(params[:project][:is_test_suite])
    else
      @project.is_test_suite = false
    end

    if !Dir.exists?(source_path)
      FileUtils.mkdir_p source_path
    end
    if @project.source_file.blank?
      # Upload source if found
      source = params[:file] ? params[:file][:source] : nil
      if source.present?
        source_file = source.original_filename
        if isValidArchive(source_file)
          puts "Uploading source file: " + source_file
          destination_path = source_path.join(source_file)
          upload_stream_to(source, destination_path)
          puts "Extracting uploaded archive..."
          extract_uploaded_archive(destination_path, source_path)
          @project.source_file = source_file
          @project.source_url = nil
        else
            @project.errors.add(:source_url, "invalid source archive format (.zip, .tgz, .tar.gz)")
        end
      end
    end

    if @project.is_test_suite
      @project.test_suite_name = params[:project][:test_suite_name]
      @project.test_suite_version = params[:project][:test_suite_version]
      @project.test_suite_type = params[:project][:test_suite_type]
      if !Dir.exists?(supplemental_path)
        FileUtils.mkdir_p supplemental_path
      end
      if @project.source_file.blank?
        source_url = params[:project][:source_url]
        if source_url
          source_url = source_url.strip
        end
        if !(source and !source.blank?) and !source_url.blank?
          puts "Fetching source URL: " + source_url
          code, status, source_file = download_url_to(source_url, source_path)
          if source_file.blank?
            @project.errors.add(:source_url, "#{code} #{status}")
          elsif !isValidArchive(source_file)
            @project.errors.add(:source_url, "invalid source archive format (.zip, .tgz, .tar.gz)")
          else
            @project.source_file = File.basename(source_file)
            puts "Source file fetched from URL: " + @project.source_file
            puts "Extracting URL downloaded archive..."
            extract_uploaded_archive(source_file, source_path)
          end
          @project.source_url = source_url
        end
      end
      manifest = params[:file] ? params[:file][:manifest_file] : nil
      manifest_url = params[:project][:manifest_url]
      if manifest_url
        manifest_url = manifest_url.strip
      end
      if manifest.present?
        puts "Uploading manifest file..."
        if isValidManifest(manifest.original_filename)
          manifest_file = supplemental_path.join(manifest.original_filename)
          upload_stream_to(manifest, manifest_file)
          extract_uploaded_archive(manifest_file, supplemental_path)
          @project.manifest_file = File.basename(manifest_file)
          @project.manifest_url = nil
          @uploaded[:manifest] = true
        else
          @project.errors.add(:manifest_file, "invalid manifest format (.xml, .zip, .tgz, .tar.gz)")
        end
      elsif manifest_url.present?
        puts "Fetching manifest URL: " + manifest_url
        code, status, manifest_file = download_url_to(manifest_url, supplemental_path)
        if code != 200
          @project.errors.add(:manifest_url, "#{code} #{status}")
        elsif !isValidManifest(manifest_file)
          @project.errors.add(:manifest_url, "invalid manifest file format (.xml, .zip, .tgz, .tar.gz)")
        else
          @project.manifest_file = File.basename(manifest_file)
          @uploaded[:manifest] = true
          puts "Manifest file fetched from URL: " + @project.manifest_file
        end
        @project.manifest_url = manifest_url
      end
      function_info = params[:file] ? params[:file][:function_info_file] : nil
      if function_info.present?
        puts "Uploading function info file..."
        function_info_file = supplemental_path.join(function_info.original_filename)
        upload_stream_to(function_info, function_info_file);
        @project.function_info_file = File.basename(function_info_file)
        @uploaded[:function_info] = true
      end
      file_info = params[:file] ? params[:file][:file_info_file] : nil
      if file_info.present?
        puts "Uploading file info file..."
        file_info_file = supplemental_path.join(file_info.original_filename)
        upload_stream_to(file_info, file_info_file);
        @project.file_info_file = File.basename(file_info_file)
        @uploaded[:file_info] = true
      end
      @project.author_source = params[:project][:author_source]
      @project.test_suite_sard_id = params[:project][:test_suite_sard_id]
      @project.license_file = params[:project][:license_file]
      if !@project.errors.any?
        @project.save
      end
    else
      # user changed their mind about this being a test suite in the
      # database view
      @project.test_suite_name = nil
      @project.test_suite_version = nil
      @project.test_suite_type = nil
      if @project.manifest_file.present?
        f = source_path.join(@project.manifest_file)
        if File.exists? f
          File.unlink(f)
        end
        @project.manifest_file = nil
      end
      @project.manifest_url = nil
      if @project.function_info_file.present?
        f = source_path.join(@project.function_info_file)
        if File.exists? f
          File.unlink(f)
        end
        @project.function_info_file = nil
      end
      if @project.file_info_file.present?
        f = source_path.join(@project.file_info_file)
        if File.exists? f
          File.unlink(f)
        end
        @project.file_info_file = nil
      end
      @project.author_source = nil
      @project.test_suite_sard_id = nil
      @project.license_file = nil
    end

    if @project.source_file.present? and File.exists? @project.source_file
      @uploaded[:source] = true
    end

    if params[:select_langs].present? or params[:deselect_langs].present?
      selected_langs = []
      deselected_langs = []
      if params[:select_langs].present?
        selected_langs =
          params[:select_langs].values.reject { |lang| lang.blank? }
      end
      if params[:deselect_langs].present?
        deselected_langs =
          params[:deselect_langs].values.reject { |lang| lang.blank? }
      end
      if selected_langs.present? or deselected_langs.present?
        deselected_langs.each do |lang_id|
          @project.languages.delete(Language.find(lang_id))
        end
        selected_langs.each do |lang_id|
          if !@project.languages.exists? lang_id
            @project.languages << Language.find(lang_id)
          end
        end
      end
    end

    @project.save

    # If any tools were selected, then we run digest_alerts.py:
    if params[:selectedTools].present?
      puts "Creating database..."
      start_time = Time.now
      # First make sure the analysis path exists
      if !Dir.exists?(analysis_path)
        FileUtils.mkdir_p analysis_path
      end
      if !Dir.exists?(Rails.root.join("public/" + gnu_analysis_path))
        FileUtils.mkdir_p Rails.root.join("public/" + gnu_analysis_path)
      end

      upload_name = Hash.new
      # For each selected tool, write the uploaded analysis to the server
      tool_groups = ToolGroup.all_by_key()
      params[:selectedTools].each do |tool_key|
        tool_group = tool_groups[tool_key]
        if tool_group
          #swamp tool version is []
          tool_version = (tool_key.start_with? "swamp") ? "" : params[:tool_versions][tool_key]
          tool = tool_group.tool_from_version(tool_version)
          if tool
              analysis = params[:file] ? params[:file][tool_key] : nil
              if analysis.present?
                orig_name = analysis.original_filename
                # SWAMP file names will have the following syntax: <swamp_tool_id>_<tool_name>-<platform>
                if params[:swampSelectedTools] and params[:swampSelectedTools][tool_key]
                  tool_uploaded = params[:swampSelectedTools][tool_key].tr("/", "-")
                end
                puts "Uploading analysis #{orig_name}"
                target_name = (tool_key.start_with? "swamp") ? "#{tool.id}_#{tool_uploaded}#{File.extname(orig_name)}" : "#{tool.id}#{File.extname(orig_name)}"

                upload_name[tool_key] = target_name
                File.open("#{analysis_path}/#{target_name}", 'wb') do |file|
                  file.write(analysis.read)
                end
              end
          else
            puts "Unknown tool version: #{tool_key} #{tool_version}"
          end
        else
          puts "Unknown tool group: #{tool_key}"
        end
      end #end params selectedTools loop
      end_time = Time.now
      duration = (end_time - start_time).to_f
      puts "[Completed in #{duration.round(1)} s]"
      
      puts "Parsing Analysis into Alerts..."
      start_time = Time.now
      params[:selectedTools].each do |tool_key|
        # This is the command to run for digest_alerts. The second part
        # will pipe the output to ##.out where ## is the number corresponding
        # to the tool.
        
        #SWAMP uses the SWAMP parser but the different tool properties files
        if tool_key.start_with? "swamp"
          swamp_tool_key = tool_key
          swamp_tool_group = tool_groups[swamp_tool_key]
          actual_tool_key = params[:swampSelectedTools][tool_key]
          if actual_tool_key.present?
            actual_tool_group = tool_groups[actual_tool_key]
            target_name = upload_name[swamp_tool_key]
            if target_name != nil
              swamp_tool_version = ""
              tool_version = params[:tool_versions][swamp_tool_key].to_s

              swamp_tool = swamp_tool_group.tool_from_version(swamp_tool_version) #swamp tool version is []
              actual_tool = actual_tool_group.tool_from_version(tool_version)

              # SWAMP file names will have the following syntax: <swamp_tool_id>_<tool_name>-<platform>
              file_tool_key = actual_tool_key.tr("/", "-")

              if actual_tool
                script = scripts_dir().join("digest_alerts.py")
                out_file = "#{analysis_path}/#{swamp_tool.id}_#{file_tool_key}.out"
                cmd = "#{script} #{db_path} #{analysis_path}/#{target_name} -i #{actual_tool.id} -k #{swamp_tool.id} -s #{source_path} > #{out_file} 2>&1"
                system(cmd)
                res = File.read(out_file)
                if res.present?
                  puts "ran: #{cmd}"
                  puts "result: #{res}"
                end
                dest = Rails.root.join("public/" + gnu_analysis_path).join("#{swamp_tool.id}_#{file_tool_key}.txt")
                FileUtils.cp("#{analysis_path.to_s}/#{swamp_tool.id}_#{file_tool_key}.out", dest)
                # add tool to project
                if not @project.tools.exists? swamp_tool.id
                  @project.tools << swamp_tool
                end
              else
                puts "unknown tool version: #{actual_tool_key}  #{tool_version}"
              end
            end
          else
            puts "unknown tool group: #{actual_tool_key} or #{swamp_tool_key}"
          end
        else
          tool_group = tool_groups[tool_key]
          if tool_group
            target_name = upload_name[tool_key]
            if target_name != nil
              tool_version = params[:tool_versions][tool_key]
              tool = tool_group.tool_from_version(tool_version)
              if tool
                script = scripts_dir().join("digest_alerts.py")
                out_file = "#{analysis_path}/#{tool.id}.out"
                cmd = "#{script} #{db_path} #{analysis_path}/#{target_name} -i #{tool.id} -s #{source_path} > #{out_file} 2>&1"
                system(cmd)
                res = File.read(out_file)
                if res.present?
                  puts "ran: #{cmd}"
                  puts "result: #{res}"
                end
                dest = Rails.root.join("public/" + gnu_analysis_path).join("#{tool.id}.txt")
                FileUtils.cp("#{analysis_path.to_s}/#{tool.id}.out", dest)
                # add tool to project
                if not @project.tools.exists? tool.id
                  @project.tools << tool
                end
              else
                puts "unknown tool version: #{tool_key} #{tool_version}"
              end
            end
          else
            puts "unknown tool group: #{tool_key}"
          end
        end #end if swamp
      end
      # save project tools, then import (so taxo/tool uploads can learn context)
      @project.save
      end_time = Time.now
      duration = (end_time - start_time).to_f
      puts "[Completed in #{duration.round(1)} s]"
      
      if File.exists? db_path
        FileUtils.cp(db_path, external_db())
        self.import_to_displays(@project.id)
        @digest_happened = true
      else
        @digest_happened = false
      end
      Dir.chdir Rails.root
    end

    # Disabled lizard due to version problems involving
    # CPreExtension -- Will Snavely and Lucas Bengtson
    #Dir.chdir Rails.root.join("scripts")
    #cmd = "./lizard_metrics.py -d #{db_path.to_s} -p #{source_path.to_s}"
    #system(cmd)
    #Dir.chdir Rails.root

    # @out[f] contains the output of the scripts where f is the
    # number of the tool
    if Dir.exists?(analysis_path) and params[:selectedTools].present?
      tool_groups = ToolGroup.all_by_key()
      params[:selectedTools].each do |tool_key|
        unless tool_key.start_with? "swamp"
            tool_group = tool_groups[tool_key]
            if tool_group
              tool_version = params[:tool_versions][tool_key]
              tool = tool_groups[tool_key].tool_from_version(tool_version)
              if tool
                @uploaded[tool_key] = true
                warnings = `cat public/#{gnu_analysis_path}/#{tool.id}.txt`
                if warnings.length() == 0
                  @out[tool_key] = "" # success
                else
                  @out[tool_key] = "#{gnu_analysis_path}/#{tool.id}.txt"  # link to warnings
                end
              else
                puts "unknown tool version: #{tool_key} #{tool_version}"
              end
            else
              puts "unknown tool group: #{tool_key}"
            end
        else #  SWAMP tool information
          tool_group = tool_groups[tool_key]
          if tool_group
            tool = tool_group.tool_from_version("") # Get the swamp tool
            if tool
              warning_file = "#{gnu_analysis_path}/#{tool.id}_*.txt"
              swamp_warning_files = Dir.glob("public/#{warning_file}")

              if swamp_warning_files.length == 1
                @uploaded[tool_key] = true
                warnings = `cat #{swamp_warning_files[0]}`
                if warnings.length() == 0
                  @out[tool_key] = "" # success
                else
                  @out[tool_key] = swamp_warning_files[0].sub('public/', '')  # link to warnings
                end
              elsif swamp_warning_files.length > 1
                @uploaded[tool_key] = true
                swamp_warning_files.each do |out_file|
                  tool_regex = out_file.match /#{tool.id}_(.*)\.txt$/
                  if tool_regex
                    actual_tool_key = tool_regex[1].tr("-","/")
                  end

                  warnings = `cat #{out_file}`
                  @out_multiple[tool_key] = {}

                  if warnings.length() == 0
                    @out_multiple[tool_key][actual_tool_key] = ""
                  else
                    @out_multiple[tool_key][actual_tool_key] = out_file.sub('public/', '').to_s  # link to warnings
                  end
                end
              end
            else
                puts "unknown tool version: #{tool_key} #{tool_version}"
            end
          else
            puts "unknown tool group: #{tool_key}"
          end
        end
      end
    end

  end


  # This action handles downloading the database generated by the scripts
  # Note that since this is from the database page, it does not know anything
  # about any audited information. This is the original database produced by
  # digest_alerts.
  def downloadDatabase
    archive_db = archive_backup_db_from_id(params[:project_id])
    if File.exists?(archive_db)
      send_file(archive_db)
    end
  end


  # This action creates the main auditing page from the database file
  # produced by digest_alerts.
  def fromDatabase
    start_timestamps = get_timestamps()

    # Create new project with the uploaded files and resulting
    # scripts outputs and use import_to_displays()
    project = Project.find(params[:project_id])
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else
      source_path = archive_src_dir_from_id(project.id)
      db_path = archive_backup_db_from_id(project.id)

      if !File.exist?(db_path) or !Dir.exists?(source_path)
        puts "database or source doesn't exist but tried to create, aborting"
        redirect_to "/projects/#{project.id}/database"
      else
        # Otherwise, we move the database over to external.sqlite3
        # and run import_to_displays()
        FileUtils.cp(db_path, external_db())
        start_time = Time.now
        result_of_import = self.import_to_displays(project.id)
        end_time = Time.now
        duration = (end_time - start_time).to_f
        #puts "[completed in #{duration.round(1)} s]"

        if project.save && result_of_import == "invalid"
          puts("database is not consistent! Run Project.manualCreate in the rails console to get a backtrace")
          redirect_to "/projects/#{project.id}/database"
        else
          # If imported successfully, backup the database
          if !Dir.exists?(backup_dir())
            Dir.mkdir backup_dir()
          end

          add_gnu_global_pages(project)

          # Create links
          puts "Updating links in Displays and Messages..."
          start_time = Time.now
          Display.createLinks(project.id)
          end_time = Time.now
          duration = (end_time - start_time).to_f
          puts "[completed in #{duration.round(1)} s]"

          end_timestamps = get_timestamps()
          PerformanceMetrics.addRecord(@scaife_mode, "projects_controller.fromDatabase", "Time to create a SCALe project", "SCALe_user", "Unknown", project.id, start_timestamps, end_timestamps)

          Dir.chdir Rails.root

          respond_to do |format|
            format.html  { redirect_to(project) }
            format.json  { render :json => project,
                                  :status => :created, :location => project }
          end
        end
      end
    end
  end

  ### SCAIFE Language/Taxonomy/Tool integrations
 
  def _scaife_integration_init()
    @errors = Set[]
    #puts params
    if params[:project_id].present?
      @project = Project.find(params[:project_id])
    end
    @scaife_active = scaife_active()
    @current_action = caller[0][/`.*'/][1..-2]
    @current_action.sub!(/Submit$/, "")
    @format = request.format
    @modal = params[:modal].present?
    @disable_lang_select = params[:disable_lang_select].present?
    @render_skin_path = "projects/scaife/scaifeIntegration"
    if @modal
      @render_skin_path += "Modal"
    end
    @render_content_path = "projects/scaife/#{@current_action}Content"
    submit_params = {
      project_id: @project.present? ? @project.id : nil,
      disable_lang_select: @disable_lang_select,
      modal: @modal || nil,
    }
    case @current_action
    when "langSelect"
      @submit_path = language_select_submit_path(submit_params)
    when "langUpload"
      @submit_path = language_upload_submit_path(submit_params)
    when "langMap"
      @submit_path = language_map_submit_path(submit_params)
    when "taxoSelect"
      @submit_path = taxonomy_select_submit_path(submit_params)
    when "taxoUpload"
      @submit_path = taxonomy_upload_submit_path(submit_params)
    when "taxoMap"
      @submit_path = taxonomy_map_submit_path(submit_params)
    when "toolUpload"
      @submit_path = tool_upload_submit_path(submit_params)
    when "toolMap"
      @submit_path = tool_map_submit_path(submit_params)
    end
    @form_title = "SCAIFE"
  end

  def scaifeIntegration
    # a default unembellished generic view is available for testing
    self._scaife_integration_init()
    self._dump_remote_js(request.path)
    respond_to do |format|
      format.html
      format.js
    end
  end

  ### Language integrations

  def _scaife_languages_init()
    @languages_available = \
      @project.present? ? @project.languages : Language.all()
    @scaife_languages_by_id = {}
    @languages_in_scaife = []
    @languages_not_in_scaife = []
    begin
      @languages_in_scaife, @languages_not_in_scaife, @scaife_languages_by_id = self.partition_scaife_languages(@languages_available, scaife_langs_by_id: @scaife_languages_by_id)
    rescue ScaifeError => e
      @errors << e.message
    end
  end

  def _scaife_languages_select_init()
    @form_title = "Project Language Selections"
    @submit_label = "Submit Languages"
  end

  def langSelect
    self._scaife_integration_init()
    self._scaife_languages_select_init()
    respond_to do |format|
      format.html
      format.js
    end
  end

  def langSelectSubmit
    self._scaife_integration_init() 
    langs_selected = params[:select_langs]
    langs_deselected = params[:deselect_langs]
      
    if langs_selected.present?
      langs_selected = langs_selected.values.reject { |v| v.blank? }
      langs_selected = langs_selected.map { |lang_id| Language.find(lang_id) }
    else
      langs_selected = []
    end
    
    if langs_deselected.present?
      langs_deselected = langs_deselected.values.reject { |v| v.blank? }
      langs_deselected = \
        langs_deselected.map { |lang_id| Language.find(lang_id) }
    else
      langs_deselected = []
    end
    sel_cnt = desel_cnt = 0
    if langs_selected.present? or langs_deselected.present?
      langs_deselected.each do |lang|
        if @project.languages.include? lang
          @project.languages.delete(lang)
          desel_cnt += 1
        end
      end
      langs_selected.each do |lang|
        if not @project.languages.include? lang
          @project.languages << lang
          sel_cnt += 1
        end
      end
      if @project.save
        msg = []
        if sel_cnt.present?
          msg << "#{sel_cnt} #{'language'.pluralize(sel_cnt)} added to project"
        end
        if desel_cnt.present?
          msg << "#{desel_cnt} #{'language'.pluralize(desel_cnt)} removed from project"
        end
        @success = msg.join("; ")
      else
        @errors << @project.errors.full_messages
      end
    else
      @errors << "No languages selected or deselected"
    end
    self._scaife_languages_select_init()
    
    if not params[:upload_project].present?
      respond_to do |format|
        format.js
      end
    end
  end

  def _scaife_languages_upload_init()
    if @project.present?
      @form_title += ": Project Language Uploads"
    else
      @form_title += ": SCALE Language Uploads"
    end
    @submit_label = "Upload Languages"
  end

  def langUpload
    #puts "langUpload() #{params}"
    self._scaife_integration_init()
    self._scaife_languages_init()
    self._scaife_languages_upload_init()
    if @project.present? and @languages_available.blank?
      @errors << "Need to select some project languages first."
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def langUploadSubmit
    #puts "langUploadSubmit() #{params}"
    self._scaife_integration_init()
    langs_to_upload = params[:upload_langs]
    if langs_to_upload.present?
      langs_to_upload = langs_to_upload.values.reject { |v| v.blank? }
      langs_to_upload = \
        langs_to_upload.map { |lang_id| Language.find(lang_id) }
    end
    if langs_to_upload.present?
      uploaded_cnt = 0
      begin
        langs_to_upload.each do |lang|
          self.upload_language_to_scaife(lang)
          uploaded_cnt += 1
        end
      rescue ScaifeError => e
        @errors << e.message
      end
      if uploaded_cnt > 0
        @success = \
          "#{uploaded_cnt} #{'language'.pluralize(uploaded_cnt)} uploaded to SCAIFE"
      end
    else
      @errors << "No languages selected for upload"
    end
    self._scaife_languages_init()
    self._scaife_languages_upload_init()
    respond_to do |format|
      format.js
    end
  end

  def upload_language_to_scaife(lang)
    c = ScaifeDatahubController.new
    result = c.createLanguage(
      session[:login_token], lang.name, lang.version
    )
    if result.is_a?(String)
      puts "#{__method__}() error createLanguage(): #{c.scaife_status_code}: #{result}"
      if @debug.present?
        puts c.response
      end
      @errors << result
    else
      # automatically map it
      ActiveRecord::Base.transaction do
        lang.scaife_language_id = result.code_language_id
        if not lang.save
          if @debug.present?
            @errors += lang.errors.full_messages
          else
            @errors << "Internal error"
          end
          raise ScaifeError.new("problem saving language to db")
        end
      end
    end
    puts "language #{lang.id} uploaded to SCAIFE"
  end

  def _scaife_languages_map_init()
    if @project.present?
      @form_title += ": Project Language Mappings"
    else
      @form_title += ": SCALE Language Mappings"
    end
    @submit_label = "Submit Mappings"
  end

  def langMap
    self._scaife_integration_init()
    self._scaife_languages_init()
    self._scaife_languages_map_init()
    if @errors.blank? and @scaife_languages_by_id.blank?
      @errors << "Need to upload some languages to SCAIFE first."
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def langMapSubmit
    self._scaife_integration_init()
    langs_to_map = params[:map_langs]
    if langs_to_map.present?
      langs_to_map = langs_to_map.delete_if { |k, v| v.blank? }
    end
    if langs_to_map.present?
      @mapped_languages = []
      ActiveRecord::Base.transaction do
        langs_to_map.each do |lang_id, scaife_id|
          lang = Language.find(lang_id)
          lang.scaife_language_id = scaife_id
          @mapped_languages << lang
          if not lang.save
            @errors += lang.errors.full_messages
            break
          end
        end
      end
      @success = \
        "#{@mapped_languages.length} #{'language'.pluralize(@mapped_languages.length)} mapped to SCAIFE"
    else
      @errors << "No language mappings were specified"
    end
    self._scaife_languages_init()
    self._scaife_languages_map_init()
    # javascript will reload content with updates
    respond_to do |format|
      format.js
    end
  end
  
  ### Tool selections from Upload Project Page
  def toolSelectSubmit
    if params[:project_id].present?
      @project = Project.find(params[:project_id])
    end
    @scaife_active = scaife_active()
    
    tools_selected = params[:select_tools]
      
    tools_selected = tools_selected.values.reject { |v| v.blank? }
    tools_selected = tools_selected.map { |tool_id| Tool.find(tool_id) }
     
    if tools_selected 
      tools_selected.each do |tool|
        if not @project.tools.include? tool
            @project.tools << tool
        end
      end
      
      if not @project.save
        @errors << @project.errors.full_messages
      end
    end
  end

  ### Taxonomy integrations

  def _scaife_taxonomies_init()
    @taxonomies_available = \
      @project.present? ? @project.taxonomies() : Taxonomy.all()
    @scaife_taxonomies_by_id = {}
    @taxonomies_in_scaife = []
    @taxonomies_not_in_scaife = []
    begin
      @taxonomies_in_scaife, @taxonomies_not_in_scaife, @scaife_taxonomies_by_id = self.partition_scaife_taxonomies(@taxonomies_available, scaife_taxos_by_id: @scaife_taxonomies_by_id)
    rescue ScaifeError => e
      @errors << e.message
    end
  end

  def _scaife_taxonomies_select_init()
    @form_title = "Project Taxonomy Selections"
    @submit_label = "Submit Taxonomies"
  end

  def taxoSelect
    self._scaife_integration_init()
    self._scaife_taxonomies_select_init()
    respond_to do |format|
      format.html
      format.js
    end
  end

  def taxoSelectSubmit
    self._scaife_integration_init()
    taxos_selected = params[:select_taxos]
    taxos_deselected = params[:deselect_taxos]
    if taxos_selected.present?
      taxos_selected = taxos_selected.values.reject { |v| v.blank? }
      taxos_selected = taxos_selected.map { |taxo_id| Taxonomy.find(taxo_id) }
    else
      taxos_selected = []
    end
    if taxos_deselected.present?
      taxos_deselected = taxos_deselected.values.reject { |v| v.blank? }
      taxos_deselected = \
        taxos_deselected.map { |taxo_id| Taxonomy.find(taxo_id) }
    else
      taxos_deselected = []
    end
    sel_cnt = desel_cnt = 0
    if taxos_selected.present? or taxos_deselected.present?
      taxos_deselected.each do |taxo|
        if @project.taxonomies.include? taxo
          @project.taxonomies.delete(taxo)
          desel_cnt += 1
        end
      end
      taxos_selected.each do |taxo|
        if not @project.taxonomies.include? taxo
          @project.taxonomies << taxo
          sel_cnt += 1
        end
      end
      # need to have a more generalized way of handling supersets,
      # including version correlation, at the taxonomy schema level
      cpp_taxo = nil
      @project.taxonomies.each do |taxo|
        if taxo.conditions[0].platform == 'cpp'
          cpp_taxo = taxo
        end
      end
      if cpp_taxo.present?
        Taxonomy.all.each do |taxo|
          # this is really brittle
          if taxo.conditions[0].platform == 'c'
            # unique constraint in schema will trigger otherwise
            if not @project.taxonomies.include? taxo
              @project.taxonomies << taxo
              sel_cnt += 1
              break
            end
          end
        end
      end
      if @project.save
        msg = []
        if sel_cnt.present?
          msg << "#{sel_cnt} #{'taxonomy'.pluralize(sel_cnt)} added to project"
        end
        if desel_cnt.present?
          msg << "#{desel_cnt} #{'taxonomy'.pluralize(desel_cnt)} removed from project"
        end
        @success = msg.join("; ")
      else
        @errors << @project.errors.full_messages
      end
    else
      @errors << "No taxonomies selected or deselected"
    end
    self._scaife_taxonomies_select_init()
    if not params[:upload_project].present?
      respond_to do |format|
        format.js
      end
    end
  end

  def _scaife_taxonomies_upload_init()
    if @project.present?
      @form_title += ": Project Taxonomy Uploads"
    else
      @form_title += ": SCALE Taxonomy Uploads"
    end
    @submit_label = "Upload Taxonomies"
  end

  def taxoUpload
    #puts "taxoUpload() #{params}"
    self._scaife_integration_init()
    self._scaife_taxonomies_init()
    self._scaife_taxonomies_upload_init()
    if @errors.blank? and @taxonomies_available.blank?
      @errors << "Need to select taxonomies first."
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def taxoUploadSubmit
    #puts "taxoUploadSubmit() #{params}"
    self._scaife_integration_init()
    taxos_to_upload = params[:upload_taxos]
    if taxos_to_upload.present?
      taxos_to_upload = taxos_to_upload.values.reject { |v| v.blank? }
      taxos_to_upload = \
        taxos_to_upload.map { |taxo_id| Taxonomy.find(taxo_id) }
    end
    if taxos_to_upload.present?
      uploaded_cnt = 0
      begin
        taxos_to_upload.each do |taxo|
          upload_taxonomy_to_scaife(taxo)
          uploaded_cnt += 1
        end
      rescue ScaifeError => e
        puts "ScaifeError caught in taxoUploadSubmit(): #{e.message}"
        @errors << e.message
      end
      if uploaded_cnt > 0
        @success = \
          "#{uploaded_cnt} #{'taxonomy'.pluralize(uploaded_cnt)} uploaded to SCAIFE"
      end
    else
      @errors << "No taxonomies selected for upload"
    end
    @errors.each do |err|
      puts "taxo upload err: #{err}"
    end
    self._scaife_taxonomies_init()
    self._scaife_taxonomies_upload_init()
    # javascript will reload content with updates
    respond_to do |format|
      format.js
    end
  end

  def upload_taxonomy_to_scaife(taxo)
    # required:
    #   name
    #   version
    #   description   <-- SCALe doesn't have
    #   author_source <-- SCAIFE doesn't handle yet
    #   conditions {}
    #     code_language_ids [str]
    #     condition_name
    #     title
    #     platforms [str]
    #     condition_fields {str: str}
    @errors = Set[]
    c = ScaifeDatahubController.new
    puts "attempt upload of taxonomy: #{taxo.name} #{taxo.version}"
    result = c.createTaxonomy(
      session[:login_token], taxo.name, taxo.version,
      "Sample taxonomy description", taxo.scaife_conditions(), taxo.author_source
    )
    if result.is_a?(String)
      puts "#{__method__}() error createTaxonomy(): #{c.scaife_status_code}: #{result}"
      @errors << result
    else
      cond_cnt = 0
      scaife_conds = result.conditions
      scaife_conds_by_name = scaife_conds.map { |cond| [cond.condition_name, cond] }.to_h
      common, diff_plus, diff_minus = helpers.set_diff(
        taxo.conditions.map { |cond| cond.name },
        scaife_conds_by_name.keys
      )
      if taxo.conditions.length != scaife_conds.length
        msg = []
        if c.scaife_status_code == 422
          msg << "taxonomy #{taxo.id} already exists,"
        end
        msg << "condition count missmatch: #{taxo.conditions.length} conditions in SCALe, #{scaife_conds.length} conditions in SCAIFE"
        puts msg.join(' ')
      end
      if diff_plus.present?
        # we're not handling this possibility yet
        @errors << "#{diff_plus.length} conditions are in SCAIFE but not in SCALe"
      elsif diff_minus.present?
        # SCAIFE taxo does not have all conditions yet, so edit it
        # If successful, *all* conditions will now be mapped to scaife_ids
        puts "editing scaife taxo with #{diff_minus.length} conditions"
        cond_names = Set.new(diff_minus)
        conds_to_add = taxo.conditions.select { |cond| cond_names.include?(cond.name) }
        update_taxonomy_on_scaife(taxo, result["taxonomy_id"], conds_to_add)
      else
        # SCAIFE didn't know about this taxonomy yet
        # map the conditions that uploaded
        ActiveRecord::Base.transaction do
          taxo.scaife_tax_id = result.taxonomy_id
          taxo.conditions.each do |cond|
            if scaife_conds_by_name.include? cond.name
              cond.scaife_cond_id = scaife_conds_by_name[cond.name].condition_id
              if not cond.save
                if @debug.present?
                  @errors += cond.errors.full_messages
                else
                  @errors << "problem saving condition to db"
                end
                break
              end
              cond_cnt += 1
            end
          end
          # finally, save the taxonomy
          if @errors.blank? and not taxo.save
            if @debug.present?
              @errors += taxo.errors.full_messages
            end
          end
        end
      end
      if @errors.blank?
        if diff_minus.blank?
          puts "taxonomy #{taxo.id} (#{cond_cnt} conditions) uploaded to SCAIFE"
        end
      else
        @errors << "problem saving taxonomy to db"
      end
    end
    if @errors.present?
      raise ScaifeError.new("problem uploading taxonomy")
    end
  end

  def update_taxonomy_on_scaife(taxo, scaife_taxo_id, conds_to_add)
    # required:
    #   conditions {}
    #     code_language_ids [str]
    #     condition_name
    #     title
    #     platforms [str]
    #     condition_fields {str: str}
    @errors = Set[]
    c = ScaifeDatahubController.new
    result = c.editTaxonomy(session[:login_token],
                      scaife_taxo_id,
                      taxo.scaife_conditions(conditions: conds_to_add))
    cond_cnt = 0
    if scaife_conds.is_a?(String)
      puts "#{__method__}() error editTaxonomy(): #{c.scaife_status_code}: #{result}"
      @errors << scaife_conds
    else
      # automatically map newly uploaded conditions
      scaife_conds_by_name = scaife_conds.map { |cond| [cond["condition_name"], cond] }.to_h
      ActiveRecord::Base.transaction do
        taxo.conditions.each do |cond|
          cond.scaife_cond_id = scaife_conds_by_name[cond.name]["condition_id"]
          if not cond.save
            if @debug.present?
              @errors += cond.errors.full_messages
            else
              @errors << "problem saving condition to db"
            end
            break
          end
          cond_cnt += 1
        end
        puts "about to save taxo in edit, errors:\n#{@errors.to_a.join("\n")}"
        # if taxonomy was implicitly created by tool upload, the scaife
        # id probably isn't in SCALe yet
        taxo.scaife_tax_id = scaife_taxo_id
        if @errors.blank? and not taxo.save
          if @debug.present?
            @errors += taxo.errors.full_messages
          end
        end
      end
      if @errors.blank?
        puts "taxonomy #{taxo.id} (#{conds_to_add.length} conditions) uploaded (total now #{cond_cnt}) to SCAIFE"
      end
      if @errors.present?
        @errors << "problem saving taxonomy to db"
      end
    end
    if @errors.present?
      puts "WTF edit errors:\n#{@errors.to_a.join("\n")}"
      raise ScaifeError.new("problem uploading (update) taxonomy")
    end
  end

  def _scaife_taxonomies_map_init()
    if @project.present?
      @form_title += ": Project Taxonomy Mappings"
    else
      @form_title += ": SCALE Taxonomy Mappings"
    end
    @submit_label = "Submit Mappings"
  end

  def taxoMap
    self._scaife_integration_init()
    self._scaife_taxonomies_init()
    self._scaife_taxonomies_map_init()
    if @scaife_taxonomies_by_id.blank?
      @errors << "Need to upload some taxonomies to SCAIFE first."
    end
    if @errors.blank? and @taxonomies_available.blank?
      @errors << "Need to select taxonomies first."
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def taxoMapSubmit
    self._scaife_integration_init()
    taxos_to_map = params[:map_taxos]
    if taxos_to_map.present?
      taxos_to_map = taxos_to_map.delete_if { |k, v| v.blank? }
    end
    if taxos_to_map.present?
      @mapped_taxonomies = []
      ActiveRecord::Base.transaction do
        taxos_to_map.each do |taxo_id, scaife_id|
          taxo = Taxonomy.find(taxo_id)
          taxo.scaife_tax_id = scaife_id
          @mapped_taxonomies << taxo
          if not taxo.save
            @errors += taxo.errors.all_messages
            break
          end
        end
      end
      @success = \
        "#{@mapped_taxonomies.length} #{'taxonomy'.pluralize(@mapped_taxonomies.length)} mapped to SCAIFE"
    else
      @errors << "No taxonomy mappings were specified"
    end
    self._scaife_taxonomies_init()
    self._scaife_taxonomies_map_init()
    # javascript will reload content with updates
    respond_to do |format|
      format.js
    end
  end

  ### Tool integrations

  def _scaife_tools_init()
    @tools_available = @project.present? ? @project.tools() : Tool.all()
    @scaife_tools_by_id = {}
    @tools_in_scaife = []
    @tools_not_in_scaife = []
    begin
      @tools_in_scaife, @tools_not_in_scaife, @scaife_tools_by_id = self.partition_scaife_tools(@tools_available)
    rescue ScaifeError => e
      @errors << e.message
    end
  end

  def _scaife_tools_upload_init()
    if @project.present?
      @form_title += ": Project Tool Uploads"
    else
      @form_title += ": SCALE Tool Uploads"
    end
    @submit_label = "Upload Tools"
  end

  def tool_language_requirements(tools)
    acceptable_langs = Set[]
    selected_langs = Set[]
    begin
      all_langs_in_scaife, all_langs_not_in_scaife, scaife_langs_by_id = self.partition_scaife_languages(Language.all())
    rescue ScaifeError => e
      raise e
    end
    tools.each do |tool|
      if @project.present?
        # so, for example, this might eliminate C++ as a requirement
        # but not C
        acceptable_langs += (tool.languages & @project.seen_all_languages)
        selected_langs += (tool.languages & @project.languages)
      else
        # this inlcudes all versions of each language group
        acceptable_langs += tool.languages
        selected_langs += tool.languages
      end
    end
    required_lang_groups = \
      LanguageGroup.group_languages_by_key(acceptable_langs)
    selected_lang_groups =
      LanguageGroup.group_languages_by_key(selected_langs)
    selected_langs_in_scaife = selected_langs & all_langs_in_scaife
    selected_langs_not_in_scaife = selected_langs & all_langs_not_in_scaife
    lang_groups_missing = {}
    langs_in_scaife = Set[]
    langs_not_in_scaife = Set[]
    required_lang_groups.each() do |key, lg|
      if selected_lang_groups.include? key
        langs_not_in_scaife += lg.languages & selected_langs_not_in_scaife
        langs_in_scaife += lg.languages & selected_langs_in_scaife
      else
        lang_groups_missing[key] = lg
      end
    end
    lang_groups_not_in_scaife = {}
    lang_groups_in_scaife = LanguageGroup.group_languages_by_key(langs_in_scaife)
    LanguageGroup.group_languages_by_key(langs_not_in_scaife).each do |key, lg|
      if not lang_groups_in_scaife.include? key
        lang_groups_not_in_scaife[key] = lg
      end
    end
    return lang_groups_missing, lang_groups_not_in_scaife, langs_in_scaife
  end

  def toolUpload
    #puts "toolUpload() #{params}"
    self._scaife_integration_init()
    self._scaife_tools_init()
    self._scaife_tools_upload_init()
    if @project.present? and @errors.blank? and @tools_available.blank?
      @errors << "Need to select analysis tools for project first."
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def toolUploadSubmit
    #puts "toolUploadSubmit()"
    self._scaife_integration_init()
    tools_to_upload = params[:upload_tools]
    if tools_to_upload.present?
      tools_to_upload = tools_to_upload.values.reject { |v| v.blank? }
      tools_to_upload = \
        tools_to_upload.map { |tool_id| Tool.find(tool_id) }
    end
    if tools_to_upload.present?
      begin
        lang_groups_missing, lang_groups_not_in_scaife, langs_in_scaife = self.tool_language_requirements(tools_to_upload)
      rescue ScaifeError => e
        @errors << e.message
      end
      if @errors.blank?
        unsatisfied_names =
          (lang_groups_missing.keys + lang_groups_not_in_scaife.keys).uniq
        if unsatisfied_names.present?
          if @project.present?
            verb = []
            if lang_groups_missing.present?
              verb << "selected"
            end
            if lang_groups_not_in_scaife.present?
              verb << "uploaded"
            end
            verb = verb.join('/')
            # possible TODO: using lang_groups_not_in_scaife, it would be
            # easy to automatically upload these languages down in
            # upload_tool_to_scaife()
            @errors << "Languages of the following #{'type'.pluralize(unsatisfied_names.length)} need to be #{verb} first: #{unsatisfied_names.join(', ')}"
          else
            @errors << "All versions of #{unsatisfied_names.length > 1 ? "each of" : "" } the following #{'language'.pluralize(unsatisfied_names.length)} need to be uploaded first: #{unsatisfied_names.join(', ')}"
          end
        end
      end
      if @errors.blank?
        uploaded_cnt = 0
        checkers_total_cnt = 0
        begin
          tools_to_upload.each do |tool|
            # or, TODO, upload the langs without scaife_ids
            # in upload_tool_to_scaife()
            puts "upload tool #{tool.id}: #{tool.name} #{tool.version}"
            if @project.present?
              # it might be better to include languages the tool knows
              # about and have scaife_ids that the user doesn't happen
              # to have selected for the project...this limits it to
              # only those they have actually selected.
              langs = langs_in_scaife & tool.languages & @project.languages
            else
              langs = langs_in_scaife & tool.languages
            end
            checkers_total_cnt += upload_tool_to_scaife(tool, langs: langs)
            uploaded_cnt += 1
          end
          if @project.present? and checkers_total_cnt > 0
            # this is intended to capture any "unknown checkers" that
            # have been assigned scaife_ids to the external project DB
            AlertConditionsController.archiveDB(@project.id)
            # this might have been called from the database() view, in
            # which case changes need to go to the archive db also.
            # archiveDB() took care of copying to the backup db.
            FileUtils.cp(external_db(), archive_backup_db_from_id(@project.id))
          end
        rescue ScaifeError => e
          puts "ScaifeError caught in toolUploadSubmit(): #{e.message}"
          @errors << e.message
        end
        if uploaded_cnt > 0
          msg = "#{uploaded_cnt} #{'tool'.pluralize(uploaded_cnt)} uploaded to SCAIFE"
          puts msg
          @success = msg
        end
      end
    else
      @errors << "No tools selected for upload"
    end
    # refresh dialogs with any changes
    self._scaife_tools_init()
    self._scaife_tools_upload_init()
    # javascript will reload content with updates
    respond_to do |format|
      format.js
    end
  end

  def upload_tool_to_scaife(tool, langs: nil)
    # required:
    #   name str
    #   version str
    #   category str
    # optional:
    #   author_source str
    #   code_language_ids [str]
    #   checkers [str]
    #   checker_mappings [{}]
    #   code_metrics_headers []
    @errors ||= Set[]
    if langs.blank?
      langs = tool.languages()
    end
    # possible TODO: could automatically upload some languages here
    if langs.any? { |lang| lang.scaife_language_id.blank? }
      raise StandardError.new("blank scaife ids for some langs")
    end
    
    checker_cnt = 0

    # Note: tool.platform is an overloaded variable that can
    # either contain language varieties (e.g., "c/c++") or 
    # the tool category (i.e., "metric").  Currently, tool.platform
    # is used to derive the tool category.
    tool_category = tool.platform[0] == 'metric' ? "METRICS" : "FFSA"

    code_metrics_headers = []
    if tool_category == "METRICS"
        tool_table_name = tool.name.capitalize.split("_oss")[0] + "Metrics"

        with_external_db() do |con|
          result = con.execute("PRAGMA table_info(" + tool_table_name + ");")
          for header in result.pluck("name")
            code_metrics_headers.append(header)
          end
        end
    end

    c = ScaifeDatahubController.new
    result = c.uploadTool(
      session[:login_token],
      tool.name,
      tool.version,
      tool_category, # category
      tool.platform, # language_platforms
      langs.map { |lang| lang.scaife_language_id }, # code_language_ids
      tool.scaife_checker_mappings(), # checker_mappings
      tool.checkers.map { |check| check.name }, # checkers
      code_metrics_headers, # code_metrics_headers
      nil, # author_source
    )
    if result.is_a?(String)
      puts "#{__method__}() error uploadTool(): #{c.scaife_status_code}: #{result}"
      if @debug.present?
        puts c.response
      end
      @errors << result
    else
      # automatically map it along with its conditions
      if c.scaife_status_code == 422
        puts "tool #{tool.id} already exists in scaife"
      end
      ActiveRecord::Base.transaction do
        tool.scaife_tool_id = result.tool_id
        if result.checkers.present?
          # if they aren't present, the tool was already in SCAIFE
          checker_ids = result.checkers.map { |chk| [chk.checker_name, chk.checker_id] }.to_h
          tool.checkers.each do |check|
            if checker_ids[check.name].blank?
              puts "missing scaife_id for checker #{check.name}"
            else
              if check.scaife_checker_id != checker_ids[check.name]
                check.scaife_checker_id = checker_ids[check.name]
                check.save!
                checker_cnt += 1
              end
            end
          end
        end
        tool.save!
        puts "tool #{tool.id} (#{tool.checkers.length} checkers) uploaded to SCAIFE"
      rescue ActiveRecord::ActiveRecordError => e
        puts "problem saving tool to DB: #{e.message}"
        @errors += tool.errors.full_messages
      end
    end
    if @errors.present?
      raise ScaifeError.new("problem uploading tool")
    end
    return checker_cnt
  end

  def _scaife_tools_map_init()
    if @project.present?
      @form_title += ": Project Tool Mappings"
    else
      @form_title += ": SCALE Tool Mappings"
    end
    @submit_label = "Submit Mappings"
  end

  def toolMap
    self._scaife_integration_init()
    self._scaife_tools_init()
    self._scaife_tools_map_init()
    if @scaife_tools_by_id.blank?
      @errors << "Need to upload some tools to SCAIFE first."
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def toolMapSubmit
    self._scaife_integration_init()
    tools_to_map = params[:map_tools]
    if tools_to_map.present?
      tools_to_map = tools_to_map.delete_if { |k, v| v.blank? }
    end
    if tools_to_map.present?
      @mapped_tools = []
      ActiveRecord::Base.transaction do
        tools_to_map.each do |tool_id, scaife_id|
          tool = Tool.find(tool_id)
          tool.scaife_tax_id = scaife_id
          tool.save!
          @mapped_tools << tool
          if not tool.save
            @errors += tool.errors.all_messages
            break
          end
        end
        msg = "#{@mapped_tools.length} #{'tool'.pluralize(@mapped_tools.length)} mapped to SCAIFE"
        puts msg
        @success = msg
      rescue ActiveRecord::ActiveRecordError => e
        puts "problem saving tool to DB: #{e.message}"
        @errors << e.message
      end
    else
      @errors << "No tool mappings were specified"
    end
    # refresh dialogs with any changes
    self._scaife_tools_init()
    self._scaife_tools_map_init()
    # javascript will reload content with updates
    respond_to do |format|
      format.js
    end
  end


  # A more secure delete command.
  def shred(path)
    if Dir.exist?(path)
      Dir.foreach(path) do |file|
        next if file == '.' or file == '..'
        shred(file)
      end
      FileUtils.rm_rf(path)
    elsif File.exist?(path)
      system("shred --zero --remove #{path}")
    end
  end


  def clean_source_html(path)
    if Dir.exists?(path)
      if Dir.exists?("#{path}/HTML")
        FileUtils.rm_rf("#{path}/HTML")
      end
    else
      Dir.mkdir path
    end
  end

end
