# -*- coding: utf-8 -*-

# <legal>
# SCALe version r.6.7.0.0.A
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

# All other controllers inherit from this controller. Several sitewide
# configurations are done here
class ApplicationController < ActionController::Base

  class ScaifeError < StandardError
  end
  class ScaifeResponseError < ScaifeError
  end
  class ScaifeConnectionError < ScaifeError
  end
  class ScaifeAccessError < ScaifeError
  end
  class ScaifeRequirementError < ScaifeError
  end
  class ScaifeLanguageRequirementError < ScaifeRequirementError
  end
  class ScaifeTaxonomyRequirementError < ScaifeRequirementError
  end
  class ScaifeToolRequirementError < ScaifeRequirementError
  end

  # unbuffered stdout for log monitoring
  $stdout.sync = true

  def self.export_config
    {
      :env => Rails.env,
      :app_dir => Rails.root.to_s,
      :db_filename => Rails.configuration.x.db_filename.to_s,
      :db_dir => Rails.configuration.x.db_dir.to_s,
      :external_db_dir => Rails.configuration.x.external_db_dir.to_s,
      :db_path => Rails.configuration.x.db_path.to_s,
      :db_basename => Rails.configuration.x.db_basename.to_s,
      :external_db_path => Rails.configuration.x.external_db_path.to_s,
      :external_db_basename => Rails.configuration.x.external_db_basename.to_s,
      :db_backup_dir => Rails.configuration.x.db_backup_dir.to_s,
      :archive_dir => Rails.configuration.x.archive_dir.to_s,
      :archive_backup_dir => Rails.configuration.x..archive_backup_dir.to_s,
      :archive_nobackup_dir => Rails.configuration.x..archive_nobackup_dir.to_s,
    }
  end

  def self.export_config_as_json(pretty: false)
    if pretty
      return JSON.pretty_generate(self.export_config)
    else
      return JSON.generate(self.export_config)
    end
  end

  if Rails.configuration.x.session_capture_enabled
    before_action do |controller|
      def _deep_convert(obj)
        if obj.is_a?(Hash)
          new = {}
          obj.each do |k, v|
            new[k] = _deep_convert(v)
          end
        elsif obj.is_a? Array
          new = []
          obj.each do |o|
            new << _deep_convert(o)
          end
        elsif obj.is_a? ActionController::Parameters
          new = _deep_convert(obj.to_h)
        elsif obj.is_a? ActionDispatch::Request::Session
          new = _deep_convert(obj.to_h)
        elsif obj.is_a? ActionDispatch::Http::UploadedFile
          new = "@#{obj.original_filename}"
        elsif (obj.is_a? String) or (true if Float(obj) rescue false)
          if obj.is_a? String
            if obj.length > 500
                obj = "OVERFLOW: this was probably a file"
            else
                obj = obj.force_encoding("UTF-8")
            end
          end
          new = obj
        else
          new = "UNHANDLED CLASS: #{obj.class}"
        end
        return new
      end
      rec = {}
      rec[:ts] = Time.now.to_f
      rec[:controller] = controller.controller_name
      rec[:action] = controller.action_name
      rec[:http_method] = request.request_method
      rec[:url] = request.original_url
      rec[:headers] = {}
      request.headers.reject { |key| key.to_s.include?('.') }.each do |k, v|
        if k != "HTTP_COOKIE"
          rec[:headers][k] = v
        end
      end
      if request.referrer.present?
        begin
          referrer = Rails.application.routes.recognize_path(request.referrer)
        rescue
          # in case automation is skipping around too much and left
          # a 'post' referrer route as last query
          referrer = Rails.application.routes.recognize_path(
            request.referrer, method: "post")
        end
        if referrer[:controller].present?
          rec[:referrer_controller] = referrer[:controller]
          rec[:referrer_action] = referrer[:action]
        end
      else
        rec[:referrer_controller] = ""
        rec[:referrer_action] = ""
      end
      raw_post = request.raw_post
      raw_post.force_encoding("UTF-8")
      begin
        rec["params_raw"] = JSON.parse(raw_post)
      rescue JSON::ParserError
        rec["params_raw"] = _deep_convert(request.POST.to_h)
      end
      params = _deep_convert(request.parameters)
      params.delete("controller")
      params.delete("action")
      rec["params_cooked_by_rails"] = params
      session = _deep_convert(request.session)
      rec["session"] = session
      controller.session_capture_write(rec)
    end
  end

  def errors()
    @errors ||= []
  end

  # Force SSL and protect against CSRF
  config.force_ssl = false
  protect_from_forgery

  # Disable caching as Firefox's aggresive caching does not work well
  # with the loading gifs.
  before_action :set_cache_headers

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  # bypass checking for pulsar, etc, during tests that aren't integration tests
  # (a.k.a. "non-integration tests")
  def with_offline_testing()
    original_state = Rails.configuration.x.offline_testing
    self.offline_testing(true)
    yield
  ensure
    self.offline_testing(original_state)
  end

  def offline_testing(enable: nil)
    if not enable.nil?
      Rails.configuration.x.offline_testing = enable.present? ? true : false
    end
    Rails.configuration.x.offline_testing
  end

  # define as both class method and instance method
  def self.with_external_db()
    original_connection = ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection(:external)
    yield ActiveRecord::Base.connection
  ensure
    ActiveRecord::Base.establish_connection(original_connection)
    if not ActiveRecord::Base.connection.active?
      raise "with_internal_db:ensure: datbase is no longer active: #{original_connection[:database]}"
    end
  end
  delegate :with_external_db, to: :class

  # define as both class method and instance method
  def self.with_internal_db()
    # note: sadly if a with_internal_db() block is used inside of a
    # with_external_db() block, the saved external connection will be
    # disconnected even once restored. And con.reconnect! does not seem
    # to work, so establish_connection(:external) must be called again.
    original_connection = ActiveRecord::Base.remove_connection
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
    yield ActiveRecord::Base.connection
  ensure
    ActiveRecord::Base.establish_connection(original_connection)
    if not ActiveRecord::Base.connection.active?
      raise "with_internal_db:ensure: datbase is no longer active: #{original_connection[:database]}"
    end
  end
  delegate :with_internal_db, to: :class


  def with_scaife_access(login_token, server, silent: false)
    if login_token.blank?
      raise ScaifeAccessError.new("no login token present")
    end
    begin
      c = ScaifeRegistrationController.new()
      @registration_response, @registration_status_code = \
        c.get_server_access(server, login_token, silent: silent)
      if @registration_status_code == 200
        yield(@registration_response.x_access_token)
      else
        raise ScaifeAccessError.new(@registration_response)
      end
    end
  end

  def with_scaife_datahub_access(login_token, silent: false)
    server = "datahub"
    with_scaife_access(login_token, server, silent: silent) do |access_token|
      yield(access_token)
    end
  end

  def with_scaife_stats_access(login_token, silent: false)
    server = "statistics"
    with_scaife_access(login_token, server, silent: silent) do |access_token|
      yield(access_token)
    end
  end

  def with_scaife_prioritization_access(login_token, silent: false)
    server = "prioritization"
    with_scaife_access(login_token, server, silent: silent) do |access_token|
      yield(access_token)
    end
  end

  def scaife_active()
    if session[:login_token].present?
      begin
        with_scaife_datahub_access(session[:login_token], silent: true) do |_|
          return scaife_connected()
        end
      rescue ScaifeAccessError => e
        puts "scaife access: #{e}"
        _clear_scaife_session()
        return false
      end
    end
    return false
  end

  def scaife_connected()
    return session[:scaife_mode] == "Connected"
  end

  def _clear_scaife_session()
    if request.present?
      session.delete(:login_token)
      session.delete(:scaife_mode)
    end
  end

  def has_scaife_updates(project_id)
    @project = Project.find(project_id)
    if @project.blank?
      raise ScaifeError.new("invalid project: #{project_id}")
    end
    if @project.ci_enabled
      if self.scaife_connected()
        c = ScaifeDatahubController.new
        begin
          puts "calling c.updatesExist()"
          return c.updatesExist(session[:login_token], @project, waypoint: @project.git_hash, override: params[:scaife_updates_available])
        rescue ScaifeError => e
          puts "scaife updates: #{e}"
          return false
        end
      else
        puts "SCAIFE not connected"
      end
    end
    return false
  end

  # some SCAIFE tools used by both projects and alerts controllers

  def scaife_languages_by_id()
    scaife_langs_by_id = {}
    if scaife_connected()
      c = ScaifeDatahubController.new
      result = c.listLanguages(session[:login_token])
      if result.is_a?(String)
        puts "#{__method__}() error listLanguages(): #{c.scaife_status_code}: #{result}"
        raise ScaifeError.new(result)
      else
        result.each do |scaife_lang|
          scaife_langs_by_id[scaife_lang.code_language_id] = scaife_lang
        end
      end
    end
    return scaife_langs_by_id
  end

  def partition_scaife_languages(langs, scaife_langs_by_id: false)
    scaife_langs_by_id ||= {}
    langs_in_scaife = []
    langs_not_in_scaife = []
    if scaife_langs_by_id.blank?
      begin
        scaife_langs_by_id = self.scaife_languages_by_id()
      rescue ScaifeError => e
        raise e
      end
    end
    langs.each do |lang|
      if lang.scaife_language_id.present? \
          and scaife_langs_by_id.include? lang.scaife_language_id
        langs_in_scaife << lang
      else
        langs_not_in_scaife << lang
      end
    end
    return langs_in_scaife, langs_not_in_scaife, scaife_langs_by_id
  end

  def scaife_taxonomies_by_id()
    scaife_taxos_by_id = {}
    if scaife_connected()
      c = ScaifeDatahubController.new
      result = c.listTaxonomies(session[:login_token])
      if result.is_a?(String)
        puts "#{__method__}() error listTaxonomies(): #{c.scaife_status_code}: #{result}"
        raise ScaifeError.new(result)
      else
        result.each do |scaife_taxo|
          scaife_taxos_by_id[scaife_taxo.taxonomy_id] = scaife_taxo
        end
      end
    end
    return scaife_taxos_by_id
  end

  def partition_scaife_taxonomies(taxos, scaife_taxos_by_id: false)
    scaife_taxos_by_id ||= {}
    taxos_in_scaife = []
    taxos_not_in_scaife = []
    if scaife_taxos_by_id.blank?
      begin
        scaife_taxos_by_id = self.scaife_taxonomies_by_id()
      rescue ScaifeError => e
        raise e
      end
    end
    taxos.each do |taxo|
      if taxo.scaife_tax_id.present? \
          and scaife_taxos_by_id.include? taxo.scaife_tax_id
        taxos_in_scaife << taxo
      else
        taxos_not_in_scaife << taxo
      end
    end
    return taxos_in_scaife, taxos_not_in_scaife, scaife_taxos_by_id
  end

  def scaife_tools_by_id()
    scaife_tools_by_id = {}
    if scaife_connected()
      c = ScaifeDatahubController.new
      result = c.listTools(session[:login_token])
      if result.is_a?(String)
        puts "#{__method__}() error listTools(): #{c.scaife_status_code}: #{result}"
        raise ScaifeError.new(result)
      else
        result.each do |scaife_tool|
          scaife_tools_by_id[scaife_tool.tool_id] = scaife_tool
        end
      end
    end
    return scaife_tools_by_id
  end

  def partition_scaife_tools(tools, scaife_tools_by_id: false)
    scaife_tools_by_id ||= {}
    tools_in_scaife = []
    tools_not_in_scaife = []
    if scaife_tools_by_id.blank?
      begin
        scaife_tools_by_id = self.scaife_tools_by_id()
      rescue ScaifeError => e
        raise e
      end
    end
    tools.each do |tool|
      if tool.scaife_tool_id.present? \
          and scaife_tools_by_id.include? tool.scaife_tool_id
        tools_in_scaife << tool
      else
        tools_not_in_scaife << tool
      end
    end
    return tools_in_scaife, tools_not_in_scaife, scaife_tools_by_id
  end

  def project_language_requirements(project)
    # required groups include all versions of that language
    required_lang_groups =
      LanguageGroup.group_languages_by_key(project.seen_all_languages())
    # selected groups include only those versions selected
    selected_lang_groups = \
      LanguageGroup.group_languages_by_key(project.languages())
    selected_langs_in_scaife, selected_langs_not_in_scaife, scaife_langs_by_id = self.partition_scaife_languages(project.languages())
    lang_groups_missing = {}
    langs_not_in_scaife = Set[]
    required_lang_groups.each() do |key, lg|
      if selected_lang_groups.include? key
        # user has selected at least one language version from a seen group
        langs_not_in_scaife += lg.languages & selected_langs_not_in_scaife
      else
        lang_groups_missing[key] = lg
      end
    end
    lang_groups_not_in_scaife = {}
    lang_groups_in_scaife = LanguageGroup.group_languages_by_key(selected_langs_in_scaife)
    LanguageGroup.group_languages_by_key(selected_langs_not_in_scaife).each do |key, lg  |
      if not lang_groups_in_scaife.include? key
        lang_groups_not_in_scaife[key] = lg
      end
    end
    return lang_groups_missing, lang_groups_not_in_scaife, selected_langs_in_scaife, scaife_langs_by_id
  end

  def project_taxonomy_requirements(project)
    # required groups include all versions of that taxonomy
    required_taxo_groups =
      TaxonomyGroup.group_taxonomies_by_key(project.seen_taxonomies())
    # selected groups include only those versions selected
    selected_taxo_groups = \
      TaxonomyGroup.group_taxonomies_by_key(project.taxonomies())
    selected_taxos_in_scaife, selected_taxos_not_in_scaife, scaife_taxos_by_id = self.partition_scaife_taxonomies(project.taxonomies())
    taxo_groups_missing = {}
    taxos_not_in_scaife = Set[]
    required_taxo_groups.each() do |key, tg|
      if selected_taxo_groups.include? key
        # user has selected at least one taxonomy version from a seen group
        taxos_not_in_scaife += tg.taxonomies & selected_taxos_not_in_scaife
      else
        taxo_groups_missing[key] = tg
      end
    end
    taxo_groups_not_in_scaife = {}
    taxo_groups_in_scaife = TaxonomyGroup.group_taxonomies_by_key(selected_taxos_in_scaife)
    TaxonomyGroup.group_taxonomies_by_key(selected_taxos_not_in_scaife).each do |key, tg  |
      if not taxo_groups_in_scaife.include? key
        taxo_groups_not_in_scaife[key] = tg
      end
    end
    return taxo_groups_missing, taxo_groups_not_in_scaife, selected_taxos_in_scaife, scaife_taxos_by_id
  end

  def project_tool_requirements(project)
    # required groups include all versions of that tool
    tools_in_scaife, tools_not_in_scaife, scaife_tools_by_id = self.partition_scaife_tools(project.tools())
    return tools_not_in_scaife, tools_in_scaife, scaife_tools_by_id
  end

  def import_to_displays(project_id)
   # Complete time reduction efforts in RC-1558
   # Comments below were intended to eliminate the second call to Load Data into DB
   # when the Create Project from Database button is pressed after the Create DB button
   # if session[:last_sync_project_id].to_i == project_id
   #   return # If the DB was already loaded with this project skip this step
   # end
    import_result = Display.importScaleMI(project_id, request: request)
    Display.sync_checkers(project_id)
    session[:last_sync_project_id] = project_id
    return import_result
  end

  def switch_project_context(project_id)
    if session[:last_sync_project_id].to_i != project_id
      if session[:last_sync_project_id].present?
        last_backup_db = backup_external_db_from_id(session[:last_sync_project_id])
        if File.exists? last_backup_db
          FileUtils.copy(last_backup_db, external_db())
          AlertConditionsController.archiveDB(session[:last_sync_project_id])
        end
      end
      this_backup_db = backup_external_db_from_id(project_id)
      FileUtils.copy(this_backup_db, external_db())
      Display.sync_checkers(project_id)
      session[:last_sync_project_id] = project_id
    end
  end

  # Below are some URL / path helpers

  # This returns the path to the database page for a SCALe project
  def database_project_path(project)
    "/projects/#{project.id}/database"
  end

  # This returns the path to the creation page for creating a project
  # from an existing SCAIFE package
  def scaife_project_path(project)
    "/projects/#{project.id}/scaife"
  end

  # This returns the path to the database page for a SCAIFE CI project
  def scaife_ci_project_path(project)
    "/projects/#{project.id}/scaife_ci"
  end

  # paths

  def self.archive_dir()
    Rails.configuration.x.archive_dir
  end
  delegate :archive_dir, to: :class

  def self.archive_backup_dir()
    Rails.configuration.x.archive_backup_dir
  end
  delegate :archive_backup_dir, to: :class

  def self.archive_nobackup_dir()
    Rails.configuration.x.archive_nobackup_dir
  end
  delegate :archive_nobackup_dir, to: :class

  def log_file_dir()
    Rails.root.join("log")
  end

  # This returns the system path to the backed up project archive
  # Most things are backedup except for raw source code
  def self.archive_backup_dir_from_id(project_id)
    archive_backup_dir().join(project_id.to_s)
  end
  delegate :archive_backup_dir_from_id, to: :class

  def self.archive_nobackup_dir_from_id(project_id)
    archive_nobackup_dir().join(project_id.to_s)
  end
  delegate :archive_nobackup_dir_from_id, to: :class

  def self.archive_backup_db_from_id(project_id)
    archive_backup_dir_from_id(project_id).join("db.sqlite")
  end
  delegate :archive_backup_db_from_id, to: :class

  def self.archive_analysis_dir_from_id(project_id)
    archive_backup_dir_from_id(project_id).join("analysis")
  end
  delegate :archive_analysis_dir_from_id, to: :class

  def self.archive_supplemental_dir_from_id(project_id)
    archive_backup_dir_from_id(project_id).join("supplemental")
  end
  delegate :archive_supplemental_dir_from_id, to: :class

  def self.archive_src_dir_from_id(project_id)
    archive_nobackup_dir_from_id(project_id).join("src")
  end
  delegate :archive_src_dir_from_id, to: :class

  def self.tmp_dir()
    Rails.root.join("tmp")
  end
  delegate :tmp_dir, to: :class

  def self.db_dir()
    Rails.configuration.x.db_dir
  end
  delegate :db_dir, to: :class

  def self.internal_db()
    Rails.configuration.x.db_path
  end
  delegate :internal_db, to: :class

  def self.external_db()
    Rails.configuration.x.external_db_path
  end
  delegate :external_db, to: :class

  def self.backup_dir()
    Rails.configuration.x.db_backup_dir
  end
  delegate :backup_dir, to: :class

  def self.backup_dir_from_id(project_id)
    backup_dir().join(project_id.to_s)
  end
  delegate :backup_dir_from_id, to: :class

  def self.backup_external_db_from_id(project_id)
    backup_dir_from_id(project_id).join(Rails.configuration.x.external_db_basename)
  end
  delegate :backup_external_db_from_id, to: :class

  def self.backup_external_db_timestamp_from_id(project_id)
    timestamp = Time.now.strftime('%Y-%m-%d_%H:%M:%S')
    backup_dir_from_id(project_id).join("external-#{timestamp}.sqlite3")
  end
  delegate :backup_external_db_timestamp_from_id, to: :class

  def self.scripts_dir()
    Rails.root.join("scripts")
  end
  delegate :scripts_dir, to: :class

  def session_capture_file(filename: nil)
    if filename.blank?
      filename = tmp_dir().join(Rails.configuration.x.session_capture_filename)
    end
  end

  def session_capture_reset()
    if File.file? self.session_capture_file()
      File.open(self.session_capture_file(), 'w').close()
    end
  end

  def session_capture_write(data)
    if data.present?
      if File.file? self.session_capture_file()
        entries = JSON.load(self.session_capture_file().open())
      end
      entries = [] if entries.blank?
      entries << data
      File.open(self.session_capture_file(), 'w') do |fh|
        #JSON.dump(entries, fh)
        fh.write(JSON.pretty_generate(entries))
      end
    end
  end

  def self.filter_stacktrace(e)
    # given an exception, filter down the stacktrace to something
    # interesting
    vend_dir = Rails.root.join("vendor")
    lines = []
    lines << "Exception #{e.class}:"
    e.backtrace.each do |line|
      next if not line.start_with? Rails.root.to_s
      next if line.start_with? vend_dir.to_s
      lines << line
    end
    lines << "Exception type/message: #{e.class} #{e}"
    return lines
  end
  delegate :filter_stacktrace, to: :class


  before_action :require_login

  private

  def require_login
    #puts "\naction: #{self.action_name}"
    #puts "original_fullpath: #{request.original_fullpath}"
    user_page = request.original_fullpath.starts_with?("/users")
    #puts "session[:login_user]: #{session[:login_user]}"
    logged_in = session[:login_user].present?
    if not logged_in and not user_page
      puts("redirecting to /users/unauthorized\n")
      redirect_to "/users/unauthorized",
                  notice: "Please Login to view that page!" and return
    end
    if logged_in and (request.original_fullpath == "/users/unauthorized")
      puts("redirecting to /\n")
      redirect_to "/", notice: "Welcome!" and return
    end
  end

end
