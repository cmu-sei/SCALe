# -*- coding: utf-8 -*-
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.


# This file defines the actions corresponding to various CRUD 
# actions for the project model. 
class ProjectsController < ApplicationController
  # The show action is not ever rendered as an html page (since the
  # all the project info is shown on the main page). 
  # If this were restructured, I would remove the diagnostics controller
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

  # This action is for the main page; query all projects and send it to the view. 
  # There is also a JSON response for the API. 
  def index
    @projects = Project.all  
    respond_to do |format|
      format.html  
      format.json  { render :json => @projects }
    end
  end

  # This action shows the create new project page, so we initialize a new project. 
  def new
    @project = Project.new
  end

  # This action creates a new project. We redirect to the database page 
  # upon creation. If the project fails to save, then render the
  # new page and pass the errors along to the view. 
  def create
    @project = Project.new(params[:project])
    if @project.save
      respond_to do |format|  
        format.html  { redirect_to(database_project_path(@project)) }
        format.json  { render :json => @project,
                      :status => :created, :location => edit_project_path }
      end
    else
      respond_to do |format|  
        format.html  { render :action => "new" }
        format.json  { render :json => @project.errors,
                      :status => :unprocessable_entity }
      end
    end
  end

  # This action shows the edit project page. 
  def edit
    @project = Project.find(params[:id])
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else
      # Pass some more useful parameters to the view. Specifically,
      # these parameters keep track of what checkboxes are already
      # marked and what files are already uploaded. @out will
      # contain the output of digest_diagnostics. 
      @params = {}
      @params[:map] = params[:map]
      @params[:selectedTools] = params[:selectedTools]
      @uploaded = {}
      @out = {}
      environment= :development
      ActiveRecord::Base.establish_connection environment
      con = ActiveRecord::Base.connection()



      @project = Project.find(params[:id])
      if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
        print "invalid project id: #{@project.id.to_s}"
      else
        project_id = params[:id]
        analysisPath = "#{archive_backup_from_id(project_id)}/analysis"
        #dbPath = "#{archive_backup_from_id(project_id)}/db.sqlite"
        Rails.configuration.ids.each do |i|
          if con.execute("SELECT id FROM Messages WHERE "+
                         "project_id=#{con.quote(project_id)} "+
                         "AND diagnostic_id=#{con.quote(i)} LIMIT 1").count > 0
            @uploaded[i.to_s] = true
            @out[i.to_s] = `cat #{analysisPath}/#{i}.out`
          end
        end
      end
    end
  end

  # This action updates an existing project. 
  def update_project  
    @project = Project.find(params[:project_id])
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else
      # Pass some more useful parameters to the view. Specifically,
      # these parameters keep track of what checkboxes are already
      # marked and what files are already uploaded. @out will
      # contain the output of digest_diagnostics. 
      @params = {}
      @params[:selectedTools] = params[:selectedTools]
      uploaded = []
      newly_uploaded = []
      environment= :development
      ActiveRecord::Base.establish_connection environment
      con = ActiveRecord::Base.connection()

      project_id = params[:project_id]
      analysisPath = "#{archive_backup_from_id(project_id)}/analysis"
      sourcePath = "#{archive_nobackup_from_id(project_id)}/src"
      if !Dir.exists?(sourcePath) or Dir.entries(sourcePath).size <= 2
        respond_to do |format|
          format.html  {redirect_to("/projects/#{project_id}/edit",
                                    :notice=> "Project does not have a source file")}
          format.json {head :no_content}
        end
        return
      end
      
      dbPath = "#{archive_backup_from_id(project_id)}/db.sqlite"

      # If any tools were selected, then we run digest diagnostics:
      if params[:selectedTools] && !params[:selectedTools].empty? 
        # First make sure the analysis path exists
        if !Dir.exists?(analysisPath)
          FileUtils.mkdir_p analysisPath
        end

        # For each select tool, write the uploaded analysis to the server
        backup = false
        params[:selectedTools].each do |i|
          if con.execute("SELECT id FROM Messages WHERE "+
                         "project_id=#{con.quote(project_id)}"+
                         " AND diagnostic_id=#{con.quote(i)} LIMIT 1").count > 0
            uploaded.push(i)
            backup = true
          end
          analysis = params[:file] ? params[:file][i] : nil
          if analysis != "" && analysis != nil
            File.open("#{analysisPath}/#{i}", 'wb') do |file|
              file.write(analysis.read)
              newly_uploaded.push(i)
            end
          end
        end
        if backup
          @displays = @project.displays
          @displays.reload
          #FileUtils.cp(Rails.root.join("db/backup/#{@project.id}/external.sqlite3"),Rails.root.join('db/external.sqlite3')) 
          ActiveRecord::Base.remove_connection
          ActiveRecord::Base.establish_connection :external
          con = ActiveRecord::Base.connection()

          @displays.each do |d|
            if d.flag
              flag = 1
            else
              flag = 0
            end

            if d.checker != "manual"
              # If not a manual entry, update the verdict and flag accordingly
              query = "UPDATE MetaAlerts SET "+
                      "verdict=#{con.quote(d.verdict)}, "+
                      "flag=#{con.quote(flag)}, "+
                      "notes='#{con.quote_string(d.notes)}' "+
                      "WHERE id=#{con.quote(d.meta_alert_id)}"
            # supplemental diagnostics?
            else
              # Otherwise, we need to insert the message and get its ID
              query = "INSERT INTO Messages (diagnostic, path, line, message) VALUES ("+
                      "#{con.quote(d.id)}, #{con.quote(d.path)}, "+
                      "#{con.quote(d.line)}, '#{con.quote_string(d.message)}')"
              safe_query = ActionController::Base.helpers.sanitize(query)
              con.execute(safe_query)
              query = "SELECT id FROM Messages WHERE "+
                      "diagnostic=#{con.quote(d.id)}"
              safe_query = ActionController::Base.helpers.sanitize(query)
              res = con.execute(safe_query)
              query = "INSERT INTO Diagnostics (id, checker, primary_msg,"+
                      " confidence, alert_priority VALUES ("+
                      "#{con.quote(d.id)}, #{con.quote(d.checker)}, "+
                      "#{con.quote(res[0]["id"])},"+
                      "#{con.quote(d.confidence)}, #{con.quote(d.alert_pri)})"+
                      res = con.execute(safe_query)
              query = "INSERT INTO MetaAlerts (id, flag, verdict,"+
                      " previous, notes) VALUES ("+
                      "#{con.quote(d.id)}, #{con.quote(flag)}, "+
                      "#{con.quote(d.verdict)}, #{con.quote(d.previous)}, "+
                      "'#{con.quote_string(d.notes)}')" # taxonomy_id?
            end
            safe_query = ActionController::Base.helpers.sanitize(query)
            con.execute(safe_query)
          end

          ActiveRecord::Base.remove_connection

          ActiveRecord::Base.establish_connection :development
          con = ActiveRecord::Base.connection()

          timestamp = Time.now.strftime('%Y-%m-%d_%H:%M:%S')
          FileUtils.cp(Rails.root.join('db/external.sqlite3'), Rails.root.join("db/backup/#{project_id}/external-#{timestamp}.sqlite3"))
          
          #remove messages and displays for each tool output being replaced
        end

        # Move over to the scripts directory, since
        # digest_diagnostics does not work outside of the scripts directory. 
        Dir.chdir Rails.root.join("scripts")
        # This is the command to run for digest_diagnostics. The second part
        # will pipe the output to ##.out where ## is the number corresponding
        # to the tool. 
        newly_uploaded.each do |i|
          if '#{i}'.match('\d*')  # from web request, so must sanitize
            cmd = "./digest_diagnostics.py #{dbPath.to_s} #{analysisPath.to_s}/#{i} #{i} -s #{sourcePath.to_s}"
            cmd += " > #{analysisPath.to_s}/#{i}.out 2>&1"
            # Run the command
            system(cmd)
          else
            print "invalid tool: #{i}\n"
          end
        end
        Dir.chdir Rails.root.to_s

        # Otherwise, we move the database over to external.sqlite3
        # and run importScaleMI
        FileUtils.cp(dbPath,Rails.root.join('db/external.sqlite3'))

        Display.where(project_id: project_id).delete_all()
        if Display.importScaleMI(project_id) == "invalid"
          puts("database is not consistent! Run Project.manualCreate in the rails console to get a backtrace")
          redirect_to "/projects/#{project_id}/database"
        else
          # If imported successfully, backup the database
          backupPath = Rails.root.join("db/backup")
          if !Dir.exists?(backupPath)
            Dir.mkdir backupPath
          end
          path = Rails.root.join("db/backup/#{project_id}")
          if Dir.exists?(path)
            FileUtils.rm_rf(path)
          end
          Dir.mkdir path

          FileUtils.cp(Rails.root.join('db/external.sqlite3'),path)

          # Next, generate HTML source using htags from GNU Global
          Dir.chdir sourcePath
          # Currently we only use the suggest flag options. 
          system("htags --suggest")
          # Zip the files for easier transport to the public folder
          system("zip -r pages.zip HTML")
          
          # Wipe destination for HTML source
          path = Rails.root.join("public/GNU/#{project_id.to_s}")
          if Dir.exists?(path)
            FileUtils.rm_rf(path)
          end
          Dir.mkdir path

          # Move HTML source to destination and unpack

          FileUtils.cp("pages.zip",path)

          system("unzip #{path}/pages.zip -d #{path}")

          # Cleanup
          File.delete("#{path}/pages.zip")

          # Create links
          Display.createLinks(project_id)

          Dir.chdir Rails.root.to_s
        end
      end
    end

    ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection :development
    con = ActiveRecord::Base.connection()

    respond_to do |format|
      format.html  {redirect_to("/projects/#{project_id}",
                    :notice=> "Succesfully updated project")}
      format.json {head :no_content}
    end

  end

  def update
    @project = Project.find(params[:id])
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else

      respond_to do |format|
        if @project.update_attributes(params[:project])
          format.html  { redirect_to("/",
                                     :notice => 'Project was successfully updated.') }
          format.json  { head :no_content }
        else
          format.html  { render :action => "edit" }
          format.json  { render :json => @project.errors,
                                :status => :unprocessable_entity }
        end
      end
    end
  end

  # This option destroys a project. Since the diagnostics
  # and messages are linked as 'dependent-destroy', the database
  # will also clear out all corresponding diagnostics and messages
  # for the destroyed project. It also cleans up files used outside 
  # of the archive. 
  def destroy
    @project = Project.find(params[:id])
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else

      # First, destroy the project. 
      @project.destroy

      # Next, clean up HTML pages
      path = Rails.root.join("public/GNU/#{@project.id.to_s}")
      if Dir.exists?(path)
        FileUtils.rm_rf(path)
      end

      # Finally, clean up original sqlite database and other files
      path = Rails.root.join("db/backup/#{@project.id.to_s}")
      if Dir.exists?(path)
        FileUtils.rm_rf(path)
      end

      path = archive_backup_from_id(@project.id)
      if Dir.exists?(path)
        FileUtils.rm_rf(path)
      end

      path = archive_nobackup_from_id(@project.id)
      if Dir.exists?(path)
        FileUtils.rm_rf(path)
      end
      
      respond_to do |format|
        format.html { redirect_to projects_url }
        format.json { head :no_content }
      end
    end
  end

  def has_valid_archive_ext(fname)
    valid_exts = [".zip", ".tgz", ".tar.gz"]
    return valid_exts.any? { |ext| fname.end_with?(ext) }
  end 

  def is_valid_upload(src)
    return (src != "") && (src != nil) && has_valid_archive_ext(src.original_filename)
  end

  def extract_uploaded_archive(src, dest)
    if src.end_with?( ".zip")
        system("unzip -d #{dest} -n #{src}")
    elsif [".tgz", ".tar.gz"].any? { |ext| src.end_with?( ext) }
        system("tar xzf #{src} -C #{dest}")
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

          uploadOut = File.join(path, uploaded_io.original_filename)
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
          if uploaded_io == "" || uploaded_io == nil
            @project.errors.add(:gnu_global, "must have be valid and nonempty")
          end
          format.html { render :action => "edit" }
          format.json  { render :json => @project.errors,
                                :status => :unprocessable_entity }
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
      dbPath = "#{archive_backup_from_id(project_id)}/db.sqlite"

      respond_to do |format|
        # If the uploaded file is non-empty: 
        if uploaded_io != "" && uploaded_io != nil
          # First create the required directory structure
          if !Dir.exists?(archive_backup_from_id(project_id))
            FileUtils.mkdir_p archive_backup_from_id(project_id)
          end

          # Copy the uploaded data to the target directory
          File.open(dbPath, 'wb') do |file|
            file.write(uploaded_io.read)
          end
          
          # Also copy it to external.sqlite3 for importing into Rails
          FileUtils.cp(dbPath,Rails.root.join('db/external.sqlite3'))

          # Run importScaleMI to import the data from external.sqlite3
          # If it fails, redirect to /database
          if Display.importScaleMI(project_id) == "invalid"
            @project.errors.add(:sql, "is not consistent! Run Project.manualCreate in the rails console to get a backtrace")
            @project.destroy
            redirect_to "/database"
          else
            # If imported successfully, backup the database. First
            # create the backup directory if it doesn't exist:
            backupPath = Rails.root.join("db/backup")
            if !Dir.exists?(backupPath)
              Dir.mkdir backupPath
            end

            # Then clean out the required directory where the backup 
            # is placed
            path = Rails.root.join("db/backup/#{project_id}")
            if Dir.exists?(path)
              FileUtils.rm_rf(path)
            end
            Dir.mkdir path

            # Finally move the backup here. 
            FileUtils.cp(Rails.root.join('db/external.sqlite3'),path)
            format.html  { redirect_to(@project,
                                       :notice => 'project was successfully created.') }
            format.json  { render :json => @project,
                                  :status => :created, :location => @project }
          end
        else
          if uploaded_io == "" || uploaded_io == nil
            @project.errors.add(:database, "must be valid and nonempty")
          end
          format.html  { render :action => "edit" }
          format.json  { render :json => @project.errors,
                                :status => :unprocessable_entity }
        end
      end
    end
  end


    # This is an action that used to be used for inputting manual 
  # commands through the web interface. This is no longer needed
  # thanks to improvements made to digest_diagnostics. 
  # Note that by nature of the page, commands are easily injected,
  # so the current method is far superior. 

  # def manual
  #   @params = params
  #   #@out = params[:out]
  #   @out = {}

  #   if params[:selectedTools] && !params[:selectedTools].empty?
  #     sourcepath = params[:sourcepath]
  #     #out = @out ? @out : {}


  #     Dir.chdir "scripts"
  #     params[:selectedTools].each do |i|
  #       cmd = "./digest_diagnostics.py db.sqlite " + params[i] + " " + i + " -s " + sourcepath
  #       if !params[:map][i].empty?
  #         cmd += " " + params[:map][i]
  #       end
  #       cmd += " 2>&1"
  #       puts cmd

  #       @out[i] = `#{cmd}`
  #     end    
  #     Dir.chdir Rails.root.to_s
  #   end
  # end

  # This controller handles the showing of database page, and
  # the construction of the database. 
  def database
    # First, fetch the project ID and construct useful paths
    project_id = params[:project_id]
    sourcePath = "#{archive_nobackup_from_id(project_id)}/src"
    analysisPath = "#{archive_backup_from_id(project_id)}/analysis"
    dbPath = "#{archive_backup_from_id(project_id)}/db.sqlite"

    # @displays_exist is a variable that is true if the displays
    # for this project have already been imported into the Rails 
    # database. 
    @displays_exist = Project.find(project_id).displays.exists?

    # Pass some more useful parameters to the view. Specifically,
    # these parameters keep track of what checkboxes are already
    # marked and what files are already uploaded. @out will
    # contain the output of digest_diagnostics. 
    @params = {}
    @params[:map] = params[:map]
    @params[:selectedTools] = params[:selectedTools]
    @uploaded = {}
    @out = {}

    # Upload source if found
    source = params[:file] ? params[:file][:source] : nil
    if is_valid_upload(source)
      # First, make the sourcePath if necessary
      if !Dir.exists?(sourcePath)
        FileUtils.mkdir_p sourcePath
      end

      uploadOut = File.join(sourcePath, source.original_filename)
      # Write the source file
      File.open(uploadOut, 'wb') do |file|
        file.write(source.read)
      end
      extract_uploaded_archive(uploadOut, sourcePath)
    end

    # If any tools were selected, then we run digest diagnostics:
    if params[:selectedTools] && !params[:selectedTools].empty? 
      # First make sure the analysis path exists
      if !Dir.exists?(analysisPath)
        FileUtils.mkdir_p analysisPath
      end

      upload_name = Hash.new
      # For each select tool, write the uploaded analysis to the server
      params[:selectedTools].each do |i|
        analysis = params[:file] ? params[:file][i] : nil
        if analysis != "" && analysis != nil
          orig_name = analysis.original_filename
          target_name = "#{i}.#{File.extname(orig_name)}"
          upload_name[i] = target_name
          File.open("#{analysisPath}/#{target_name}", 'wb') do |file|
            file.write(analysis.read)
          end
        end
      end

      # Move over to the scripts directory, since
      # digest_diagnostics does not work outside of the scripts directory. 
      Dir.chdir Rails.root.join("scripts")
      params[:selectedTools].each do |i|
        # This is the command to run for digest_diagnostics. The second part
        # will pipe the output to ##.out where ## is the number corresponding
        # to the tool. 
        target_name = upload_name[i]
        cmd = "./digest_diagnostics.py #{dbPath.to_s} #{analysisPath.to_s}/#{target_name} #{i} -s #{sourcePath.to_s}"
        cmd += " > #{analysisPath.to_s}/#{i}.out 2>&1"

        # Run the command
	puts cmd
        system(cmd)
      end    
      Dir.chdir Rails.root.to_s
    end

    # Disabled lizard due to version problems involving
    # CPreExtension -- Will Snavely and Lucas Bengtson
    #Dir.chdir Rails.root.join("scripts")
    #cmd = "./lizard_metrics.py -d #{dbPath.to_s} -p #{sourcePath.to_s}"
    #system(cmd)
    #Dir.chdir Rails.root.to_s

    # Lastly, after running digest_diagnostics we set
    # a few more variables useful in the view: 

    # @uploaded[:source] is a boolean that says whether
    # source has already been uploaded
    if Dir.exists?(sourcePath)
      @uploaded[:source] = true
    end

    # @database_exists is a boolean that says whether a database 
    # already exists
    if File.exists?(dbPath)
      @database_exists = true
    end

    # @out[f] contains the output of the scripts where f is the 
    # number of the tool
    if Dir.exists?(analysisPath)
      Dir.foreach(analysisPath) do |f|
        if !(f =~ /.out$/)
          @uploaded[f] = true
          @out[f] = `cat #{analysisPath}/#{f}.out`
        end
      end
    end
  end

  # This action handles downloading the database generated by the scripts
  # Note that since this is from the database page, it does not know anything 
  # about any audited information. This is the original database produced by
  # digest_diagnostics. 
  def downloadDatabase
    path = archive_backup_from_id(params[:project_id])
    if File.exists?("#{path}/db.sqlite")
      send_file("#{path}/db.sqlite") 
    end
  end

  # This action creates the main auditing page from the database file 
  # produced by digest_diagnostics. It is fairly straightforward: 
  def fromDatabase
    # Create new project with the uploaded files and resulting 
    # scripts outputs and use importScaleMI 
    project = Project.find(params[:project_id])
    if not '#{@project.id.to_s}'.match('\d*')  # from web request, so must sanitize
      print "invalid project id: #{@project.id.to_s}"
    else
      sourcePath = "#{archive_nobackup_from_id(project.id)}/src"
      dbPath = "#{archive_backup_from_id(project.id)}/db.sqlite"

      # If the project is already imported then abort, to prevent 
      # importing duplicates. 
      if project.displays.exists?
        puts "project already imported! aborting."
        redirect_to(project)
      elsif !File.exist?(dbPath) || !Dir.exists?(sourcePath)
        puts "database or source doesn't exist but tried to create, aborting"
        redirect_to "/projects/#{project.id}/database"
      else
        # Otherwise, we move the database over to external.sqlite3
        # and run importScaleMI
        FileUtils.cp(dbPath,Rails.root.join('db/external.sqlite3'))

        if project.save && Display.importScaleMI(project.id) == "invalid"
          puts("database is not consistent! Run Project.manualCreate in the rails console to get a backtrace")
          redirect_to "/projects/#{project.id}/database"
        else
          # If imported successfully, backup the database
          backupPath = Rails.root.join("db/backup")
          if !Dir.exists?(backupPath)
            Dir.mkdir backupPath
          end
          path = Rails.root.join("db/backup/#{project.id}")
          if Dir.exists?(path)
            FileUtils.rm_rf(path)
          end
          Dir.mkdir path

          FileUtils.cp(Rails.root.join('db/external.sqlite3'),path)

          # Next, generate HTML source using htags from GNU Global
          sourcePath = "#{archive_nobackup_from_id(project.id)}/src"
  	  
          Dir.chdir sourcePath
          # Currently we only use the suggest flag options. 
          system("htags --suggest")
          # Zip the files for easier transport to the public folder
          system("zip -r pages.zip HTML")
          
          # Wipe destination for HTML source
          path = Rails.root.join("public/GNU/#{project.id.to_s}")
          if Dir.exists?(path)
            FileUtils.rm_rf(path)
          end
          Dir.mkdir path

          # Move HTML source to destination and unpack

          FileUtils.cp("pages.zip",path)

          system("unzip #{path}/pages.zip -d #{path}")

          # Cleanup
          File.delete("#{path}/pages.zip")

          # Create links
          Display.createLinks(project.id)

          Dir.chdir Rails.root.to_s


          respond_to do |format|
            format.html  { redirect_to(project) }
            format.json  { render :json => project,
                                  :status => :created, :location => project }
          end
        end
      end
    end
  end
end
