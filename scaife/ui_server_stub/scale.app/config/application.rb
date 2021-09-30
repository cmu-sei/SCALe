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

require File.expand_path('../boot', __FILE__)

Dir.glob("./lib/*.{rb}").each { |file| require file } # require each file from lib directory

require 'rails/all'
require 'rest-client'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end


# Only allow local SCALe server to embed its pages in frames. (Unnecessary in Rails 4)
# SecureHeaders::Configuration.default()


module Scale
  class Application < Rails::Application
    config.ids = [11, 12, 13, 21, 22, 23, 24, 25, 26, 27, 28, 31, 32, 33, 34, 35, 36, 41, 42, 53, 61, 91, 92, 93]
    config.names = ["gcc_oss", "rosecheckers_oss", "codesonar", "msvc", "pclint", "fortify", "coverity", "ldra", "cppcheck_oss", "clang_oss", "clang_compiler_oss", "eclipse_oss", "findbugs_oss","fortify","coverity", "javacheck_oss", "findsecbugs_oss", "perlcritic_oss", "blint_oss", "fortify", "swamp_scarf_oss", "lizard_oss", "ccsm_oss", "understand"]
    config.platforms = ["c", "c", "c", "c", "c", "c", "c", "c", "c", "java", "java", "java",  "java", "java", "java", "perl", "perl", "js", "agnostic", "metric", "metric", "metric"]
    # TODO must read this material from scripts/tools.org directly
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # so test mode autoloads libs
    config.autoload_paths << "#{Rails.root}/lib"

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # SCAIFE server action relative urls for registration
    config.x.scaife.register = 'register'
    config.x.scaife.login = 'login'
    config.x.scaife.logout = 'logout'
    config.x.scaife.get_access_token = 'servers'

    # SCAIFE server action relative urls for datahub
    config.x.scaife.list_projects = 'projects' # GET /projects
    config.x.scaife.list_packages = 'packages' # GET /packages
    config.x.scaife.list_languages = 'languages' # GET /languages
    config.x.scaife.create_language = 'languages' # POST /languages
    config.x.scaife.list_taxonomies = 'taxonomies' # GET /taxonomies
    config.x.scaife.create_taxonomy = 'taxonomies' # POST /taxonomies
    config.x.scaife.edit_taxonomy = 'taxonomies' # PUT /taxonomies
    config.x.scaife.list_tools = 'tools' # GET /tools
    config.x.scaife.get_tool_data = 'tools' # GET /tools/<tool_id>
    config.x.scaife.upload_tool = 'tools' # POST /tools
    config.x.scaife.edit_tool = 'tools' # PUT /tools/<tool_id>
    config.x.scaife.create_project = 'projects' # POST /projects
    config.x.scaife.edit_project = 'projects' # PUT /projects/{project_id}
    config.x.scaife.send_meta_alerts_for_project = 'projects' # POST /projects/{project_id}/determinations
    config.x.scaife.enable_data_forwarding = 'projects' # POST /projects/{project_id}
    config.x.scaife.create_package = 'packages' # POST /packages
    config.x.scaife.test_suites = 'test_suites'
    config.x.scaife.packages = 'packages'
    config.x.scaife.projects = 'projects'

    # SCAIFE server action relative urls for prioritization
    config.x.scaife.list_priority_schemes = 'priorities'
    config.x.scaife.create_priority_scheme = 'priorities'
    config.x.scaife.update_priority_scheme = 'priorities'
    config.x.scaife.get_priority_scheme = 'priorities'
    config.x.scaife.delete_priority_scheme = 'priorities'

    # SCAIFE server action relative urls for statistics
    config.x.scaife.list_classifiers = 'classifiers' # GET
    config.x.scaife.create_classifier = 'classifiers' # POST
    config.x.scaife.run_classifier1 = 'classifiers' # PUT /classifiers/{classifier_instance_id}/projects/{project_id}
    config.x.scaife.run_classifier2 = 'projects' # PUT /classifiers/{classifier_instance_id}/projects/{project_id}
    config.x.scaife.edit_classifier = 'classifiers' # PUT /classifiers/{classifier_instance_id}
    config.x.scaife.delete_classifier = 'classifiers' # DELETE /classifiers/{classifier_instance_id}

    # db names (this abstracts out development vs test)
    config.x.db_config = config.database_configuration[Rails.env]
    config.x.external_db_config = config.database_configuration["external"]
    config.x.db_filename = config.x.db_config["database"]
    config.x.external_db_filename = config.x.external_db_config["database"]
    config.x.db_dir = Rails.root.join(File.dirname(config.x.db_filename.to_s))
    config.x.external_db_dir = config.x.db_dir

    # the db_filename values already have 'db/' as a prefix because of
    # config/database.yml
    config.x.db_path = Rails.root.join(config.x.db_filename)
    config.x.db_basename = File.basename(config.x.db_path)
    config.x.external_db_path = Rails.root.join(config.x.external_db_filename)
    config.x.external_db_basename = File.basename(config.x.external_db_path)

    config.x.db_backup_dir = config.x.db_dir.join(Rails.env, "backup")
    config.x.archive_dir = Rails.root.join("archive", Rails.env)
    config.x.archive_backup_dir = config.x.archive_dir.join("backup")
    config.x.archive_nobackup_dir = config.x.archive_dir.join("nobackup")

    # db adapter type
    config.x.db_adapter = config.x.db_config["adapter"]

    # session capture
    config.x.session_capture_enabled = false
    config.x.session_capture_filename = "session_capture.json"

    config.x.offline_testing = false

    # Default confidence thresholds
    config.x.default_efp_confidence_threshold = 0.7
    config.x.default_etp_confidence_threshold = 0.7

    # Default sort order
    def generate_sort_keys()
      all_sort_fields = { 'Display (d) ID' => 'id',
                          'Meta-Alert (m) ID' => 'meta_alert_id',
                          'Flag' => 'flag',
                          'Line' => 'line',
                          'Severity' => 'severity',
                          'Likelihood' => 'likelihood',
                          'Remediation' => 'remediation',
                          'CERT Priority' => 'priority',
                          'Level' => 'level',
                          'Checker' => 'checker',
                          'Message' => 'message',
                          'Path' => 'path',
                          'Label' => 'class_label',
                          'Confidence' => 'confidence',
                          'Category' => 'category',
                          'Time' => 'time',
                          'AlertCondition Priority' => 'meta_alert_priority' }
      all_sort_dirs = ['ASC','DESC']
      return all_sort_fields.to_a.product(all_sort_dirs).collect{ |key, dir|
        [key[0] + ' ' + dir, key[1] + ' ' + dir]}.to_h
    end

    config.x.all_sort_keys = generate_sort_keys
    config.x.default_ordering = 'Path ASC, Line ASC'
  end

end
