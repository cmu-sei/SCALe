# -*- coding: utf-8 -*-

# <legal>
# SCALe version r.6.2.2.2.A
# 
# Copyright 2020 Carnegie Mellon University.
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

# An instance of a Display class is literally a row that is displayed
# to the auditor.
class Display < ActiveRecord::Base

  # Consequently, the attributes for a Display are the columns of the
  # table.

  #attr_accessible :id, :flag, :verdict, :ignored, :dead,
  #    :inapplicable_environment, :dangerous_construct,
  #    :previous, :path, :line, :link, :message, :checker, :tool,
  #    :condition, :title, :severity, :likelihood, :remediation,
  #    :priority, :level, :cwe_likelihood, :notes, :project_id,
  #    :meta_alert_id, :alert_id


    # A display belongs to a particular project, and each display
    # can have many messages.
    belongs_to :project
    has_many :messages

    #TODO: rework this to allow for fused alertConditions

    # We enforce that the meta_alert_id must be present and unique within
    # the scope of each project.
    #validates_uniqueness_of :meta_alert_id, scope: [ :project_id ]
    validates_presence_of :meta_alert_id

    # TODO: find a better way to do validation.  These are outdated because the model is more complex.
    # Uncommenting this prevents single alert edits.

    # We also validate that some of the columns are non-negative integers
    #validates :meta_alert_id, :numericality => { :greater_than_or_equal_to => 0, only_integer: true }
    #validates :line, :numericality => { :greater_than_or_equal_to => 0, only_integer: true }
    #validates :likelihood, :numericality => { :greater_than_or_equal_to => 0, only_integer: true }
    #validates :remediation, :numericality => { :greater_than_or_equal_to => 0, only_integer: true }
    #validates :priority, :numericality => { :greater_than_or_equal_to => 0, only_integer: true }
    #validates :level, :numericality => { :greater_than_or_equal_to => 0, only_integer: true }
    #validates :cwe_likelihood, :numericality => { :greater_than_or_equal_to => 0, only_integer: false }
    #validates :dangerous_construct, :numericality => { :greater_than_or_equal_to => 0, only_integer: true }

  # This helper function constructs the filter query from the parameters
  # submitted by the filter form at the top of the main auditing page.
  # connection.quote is used to quote and sanitize all inputs.
  def self.constructSQLFilter(project_id, id_type, id, verdict, path, line, tool, checker, condition, taxonomy)
    filter = "project_id = " + connection.quote(project_id)
    #if(meta_alert_id != "")
    #  filter += " AND meta_alert_id = " + connection.quote(meta_alert_id)
    #end
    if(id_type == "Display (d) ID")
        filter += " AND id = " + connection.quote(id)
    elsif(id_type == "Meta-Alert (m) ID")
       filter += " AND meta_alert_id = " + connection.quote(id)
    end
    if(verdict.to_i != -1)
      filter += " AND verdict = " + connection.quote(verdict)
    end
    if(tool != "")
      filter += " AND tool = " + connection.quote(tool)
    end
    if(path != "")
      filter += " AND path = " + connection.quote(path)
    end
    if(line != "")
      filter += " AND line = " + connection.quote(line)
    end
    if(checker != "")
      filter += " AND checker = " + connection.quote(checker)
    end
    if(condition != "")
      filter += " AND condition = " + connection.quote(condition)
    end
    if(!taxonomy.empty?)
      current_filter = filter
      filter += " AND condition = " + connection.quote(taxonomy[0])
      taxonomy[1, taxonomy.length].each do |r| #ignore first item in list
        filter += " OR " + current_filter + " AND condition = " + connection.quote(r)
      end
    end
#    # set up later for filtering based on cwe_likelihood and notes also
#    if(cwe_likelihood != "")
#      filter += " AND cwe_likelihood = " + connection.quote(cwe_likelihood)
#    end
    return filter
  end

=begin
  takes the meta_alert_id and project_id for a determination and returns a string
  to be used as the key for detMap which is the two params joined in order by ", "

  params:
    meta_alert_id (int) - meta alert id associated with the determination
    project_id (int) - the project id associated with the determination

  returns:
    (string) - meta_alert_id and project_id joined by ", " in that order.
=end
  def self.genDetMapKey(meta_alert_id, project_id)
    return meta_alert_id.to_s + ", " + project_id.to_s
  end

  def self.with_external_db()
    original_connection = ActiveRecord::Base.remove_connection()
    ActiveRecord::Base.establish_connection(:external)
    yield ActiveRecord::Base.connection()
  ensure
    ActiveRecord::Base.establish_connection(original_connection)
  end

  #Add Project Taxonomies
  def self.add_project_taxonomy(conn, project_id, taxonomy_id)
        sql = "SELECT * FROM project_taxonomies WHERE taxonomy_id = #{taxonomy_id} AND project_id = #{project_id}"
        row = conn.execute(sql)
        if row.none?
            sql = "INSERT INTO project_taxonomies (project_id, taxonomy_id) VALUES(#{project_id}, #{taxonomy_id})"
            conn.execute(sql)
        end
  end

  # Speedily inserts all the database entries into the Displays table.
  def self.importScaleMI(project_id)
    puts "Loading Data into the DB..."
    start_time = Time.now
    # these need to be in method scope
    db_version = nil
    created_at = nil
    data = nil
    determinations = nil
    messages = nil
    ext_u_uploads = nil
    ext_c_schemes = nil
    ext_p_schemes = nil

    u_uploads_fields_uniq = ["meta_alert_id", "user_columns"]
    u_uploads_fields_all = u_uploads_fields_uniq + ["created_at", "updated_at"]

    c_schemes_fields_uniq = ["classifier_instance_name", "classifier_type", "source_domain", "created_at", "updated_at", "adaptive_heuristic_name", "adaptive_heuristic_parameters", "ahpo_name", "ahpo_parameters", "scaife_classifier_id", "scaife_classifier_instance_id"]
    c_schemes_fields_all = c_schemes_fields_uniq + ["created_at", "updated_at", "scaife_classifier_id", "scaife_classifier_instance_id"]

    # this one has a project_id
    p_schemes_fields_all = ["name", "formula", "weighted_columns", "confidence", "cert_severity", "cert_likelihood", "cert_remediation", "cert_priority", "cert_level", "cwe_likelihood", "p_scheme_type", "created_at", "updated_at", "scaife_p_scheme_id"]

    # db/external.sqlite3 is imported into the database. This assumes
    # that the external.sqlite3 has already been uploaded.
    self.with_external_db() do |con|

      # Grab & return version from imported project
      proj = con.execute("SELECT * FROM Projects").first
      db_version = con.quote(proj["version"])
      created_at = con.quote(proj["created_at"])

      # Fetching all the alert data and all the distinct messages.
      # note: ConditionCheckerLinks not required due the presence
      # of Alerts.checker_id and MetaAlerts.condition_id
      data = con.execute(%Q(
        SELECT DISTINCT MetaAlerts.id, Messages.path,
        Messages.line, Messages.message,
        Checkers.name AS checker, Tools.id AS tool_id,
        Tools.name AS tool, Tools.version AS tool_version,
        Taxonomies.id AS taxonomy_id, Taxonomies.name AS taxonomy,
        Taxonomies.version_string AS taxonomy_version, Taxonomies.format,
        Conditions.name AS condition, Conditions.title,
        Alerts.id AS alert_id, Conditions.formatted_data AS data,
        MetaAlerts.code_language, MetaAlerts.confidence_score
        FROM Alerts
        JOIN Messages ON Messages.id=Alerts.primary_msg
        JOIN MetaAlertLinks ON MetaAlertLinks.alert_id=Alerts.id
        JOIN MetaAlerts ON MetaAlerts.id=MetaAlertLinks.meta_alert_id
        JOIN Checkers ON Checkers.id=Alerts.checker_id
        JOIN Conditions ON Conditions.id=MetaAlerts.condition_id
        JOIN Taxonomies ON Taxonomies.id=Conditions.taxonomy_id
        JOIN Tools ON Tools.id=Checkers.tool_id
      ))

      determinations = con.execute("SELECT * FROM Determinations")

      # Also, select all messages separately to insert in the Messages table
      messages = con.execute("SELECT * FROM Messages")

      # Select all ClassifierSchemes, PrioritySchemes, UserUploads
      ext_u_uploads = con.execute("SELECT * from UserUploads")
      ext_c_schemes = con.execute("SELECT * from ClassifierSchemes")
      ext_p_schemes = con.execute("SELECT * from PrioritySchemes")

    end

    # Commence inserting entries into the main database
    con = ActiveRecord::Base.connection()

    # Save the old logger, since I temporarily disable the logger
    # for the mass insertions (too verbose).
    old_logger = ActiveRecord::Base.logger

    # need to be in method-scope
    det_fields = nil
    detsMap = nil

    # Use a single transaction with raw sql inserts for maximum performance
    ActiveRecord::Base.transaction do

      # First, remove anything associated with this project
      ["displays", "messages", "determinations"].each do |table|
        con.execute("DELETE FROM #{table} WHERE project_id=#{project_id}")
      end

      con.execute("UPDATE projects SET version=#{db_version},"\
                  " created_at=#{created_at}"\
                  " WHERE id=#{project_id}")

      ActiveRecord::Base.logger = nil

      # Also insert all additional messages into the associated table.
      external_db_fields = ["alert_id", "path", "line", "message"]
      dev_db_fields = ["alert_id", "path", "line", "message"]
      messages.each do |r|
        values = external_db_fields.collect{|f| con.quote(r[f])}
        con.execute("INSERT INTO messages ('project_id', '" + dev_db_fields.join("', '") + "')" +
                    " VALUES ('#{project_id}', " + values.join(", ") + ")")
      end

      det_fields = ["time", "verdict", "flag", "notes", "ignored", "dead",
                    "inapplicable_environment", "dangerous_construct"]

      if determinations.present?
        determinations.each do |r|
          values = det_fields.collect{|f| ActiveRecord::Base.connection.quote(r[f])}
          meta_alert_id = ActiveRecord::Base.connection.quote(r["meta_alert_id"])
          con.execute("INSERT INTO determinations ('project_id', 'meta_alert_id', '" +
                      det_fields.join("', '") +
                      "') VALUES ('#{project_id}', '#{meta_alert_id}', " +
                      values.join(", ") + ")")
        end
      end

      # insert unknown UserUploads
      dev_u_uploads_uniq = Set[]
      dev_u_uploads = con.execute("SELECT * from user_uploads")
      dev_u_uploads.each do |r|
        dev_u_uploads_uniq << u_uploads_fields_uniq.collect { |f| con.quote(r[f]) }
      end
      ext_u_uploads.each do |r|
        vals_uniq = u_uploads_fields_uniq.collect { |f| con.quote(r[f]) }
        if not dev_u_uploads_uniq.include? vals_uniq
          vals_all = u_uploads_fields_all.collect { |f| con.quote(r[f]) }
          con.execute("INSERT INTO user_uploads ('#{u_uploads_fields_all.join("', '")}') VALUES (#{vals_all.join(', ')})")
        end
      end

      # insert unknown ClassifierSchemes
      dev_c_schemes_uniq = Set[]
      dev_c_schemes = con.execute("SELECT * from classifier_schemes")
      dev_c_schemes.each do |r|
        dev_c_schemes_uniq << c_schemes_fields_uniq.collect { |f| con.quote(r[f]) }
      end
      ext_c_schemes.each do |r|
        vals_uniq = c_schemes_fields_uniq.collect { |f| con.quote(r[f]) }
        if not dev_c_schemes_uniq.include? vals_uniq
          vals_all = c_schemes_fields_all.collect { |f| con.quote(r[f]) }
          con.execute("INSERT INTO classifier_schemes ('#{c_schemes_fields_all.join("', '")}') VALUES (#{vals_all.join(', ')})")
        end
      end

      con.execute("DELETE FROM priority_schemes WHERE project_id=#{project_id}")
      ext_p_schemes.each do |r|
        vals_all = p_schemes_fields_all.collect { |f| con.quote(r[f]) }
        con.execute("INSERT INTO priority_schemes ('project_id', '#{p_schemes_fields_all.join("', '")}') VALUES ('#{project_id}', #{vals_all.join(', ')})")
      end

      # TODO: Copy all data needed to run SCALe from external.sqlite3 to
      # development.sqlite3 to avoid having to copy/delete/recopy
      # tables, and connect/disconnect/reconnect to different databases

    end

    dets = Determination.where(project_id: project_id).order(time: :asc)
      .select(det_fields + ["meta_alert_id"])
    detsMap = Hash.new
    
    if dets.present?
      dets.each do |det|
        meta_alert_id = det[:meta_alert_id]
        det = det.attributes.slice(*det_fields).values.map(&:to_s)
        key = self.genDetMapKey(meta_alert_id, project_id)
        if detsMap.key?(key)
          detsMap[key] = [det, detsMap[key][1] + 1]
        else
          detsMap[key] = [det, 1]
        end
      end
    end

    begin
      ActiveRecord::Base.transaction do
        fields = ["path", "line", "link", "message",
                  "checker", "condition", "title", "alert_id",
                  "tool_id", "tool", "tool_version",
                  "taxonomy_id", "taxonomy", "taxonomy_version"]
        variable_fields = Set["severity", "likelihood", "remediation",
                              "priority", "level", "cwe_likelihood"]
        formats_fields = {}
        formats_idxs = {}
        confidence_score = nil
        data.each do |r|
          #For entry, extract taxonomy_id and add it to the project_taxonomies table
          self.add_project_taxonomy(con, "#{project_id}", r["taxonomy_id"])

          # For entry, extract and sanitize each Display attribute
          # and insert it into the displays table.
          values = fields.collect{|f| ActiveRecord::Base.connection.quote(r[f])}
          format_json = r["format"]
          data_json = r["data"]
          confidence_score = r["confidence_score"]
          code_language = r["code_language"]
          if not formats_fields.has_key? format_json
            fmt_fields = []
            fmt_idxs = []
            fmt = JSON.parse(format_json)
            fmt.each_index do |i|
              field = fmt[i]
              if variable_fields.include? field
                fmt_fields << field
                fmt_idxs << i
              end
            end
            formats_fields[format_json] = fmt_fields
            formats_idxs[format_json] = fmt_idxs
          end
          var_fields = formats_fields[format_json]
          var_idxs = formats_idxs[format_json]
          var_values_all = JSON.parse(data_json)
          var_values = []
          var_idxs.each do |i|
            var_values << ActiveRecord::Base.connection.quote(var_values_all[i])
          end
          meta_alert_id = ActiveRecord::Base.connection.quote(r["id"])
          key = self.genDetMapKey(meta_alert_id, project_id)
          
          if detsMap.key?(key)
            det_values = detsMap[key][0]
            previous = detsMap[key][1] - 1
          else # Project created from new files without determinations
            det_values = [Time.now, "0", "false", "0", "false", "false", "false", "0"]
            previous = 0
          end

          if !det_values.nil?
            sql = "INSERT INTO displays ('id', 'meta_alert_id', 'project_id', 'previous', '" +
              fields.join("', '") + "', '" +
              var_fields.join("', '") + "', '" +
              det_fields.join("', '") + "', '" +
              'confidence' + "', '" +
              'code_language' + "')" +
              " VALUES (NULL, '#{meta_alert_id}', '#{project_id}', '#{previous}', " +
              values.join(", ") + ", " +
              var_values.join(", ") + ", " +
              "'#{det_values.join("', '")}'" + ", " +
              "'#{confidence_score}'" + ", " +
              "'#{code_language}'" + ")"
            con.execute(sql)
          else
            Rails.logger.info "/app/models/display.rb line 278: determination was nil"
          end
        end
      end
      end_time = Time.now
      duration = (end_time - start_time).to_f
      puts "[Completed in #{duration.round(1)} s]"
    rescue ActiveRecord::StatementInvalid => invalid
      # If there is an inconsistency with the Scale database then catch and report the error
      puts invalid.message
      ActiveRecord::Base.logger = old_logger
      Rails.logger.info "/app/models/display.rb line 286: Invalid sql statement"
      return "invalid"
    end

    # Restore the original logger and end the transaction
    ActiveRecord::Base.logger = old_logger

  end

  def self.sync_checkers(project_id)
    # Collect external checker rows
    ext_checker_rows = []
    with_external_db() do |con|
      ext_checker_rows = con.execute("SELECT * FROM Checkers")
    end

    # connect with development db
    con = ActiveRecord::Base.connection()

    # Collect development checkers with scaife_checker_ids
    dev_checker_rows = con.execute("SELECT * FROM checkers WHERE scaife_checker_id <> ''")

    ActiveRecord::Base.transaction do
      # Remove checkers in development.sqlite3, since new checkers may
      # have been inserted into external.sqlite3 when parsing the
      # specified SA tool output
      con.execute("DELETE FROM checkers")

      checker_fields = ["id", "name", "tool_id", "regex", "scaife_checker_id"]

      # Copy external checkers to development checkers
      ext_checker_keys = Set[]
      ext_checker_scaife_ids = {}
      ext_checker_rows.each do |r|
        values = checker_fields.collect{|f| ActiveRecord::Base.connection.quote(r[f])}
        con.execute(
          "INSERT INTO checkers ('" + checker_fields.join("', '") + "')" +
          " VALUES (" + values.join(", ") + ")")
        key = [r["name"],r["tool_id"]]
        ext_checker_keys << key
        if r["scaife_checker_id"].present?
          ext_checker_scaife_ids[key] = r["scaife_checker_id"]
        end
      end

      # Update development checkers with existing scaife_checker_id values.
      # dev_checker_rows are all those that have scaife_checker_id present
      dev_checker_rows.each do |r|
        # don't include unknown checkers from the prior project since
        # those checker_ids might collide with unknown checker_ids from
        # the current project
        if ext_checker_keys.include? [r["name"],r["tool_id"]]
          con.execute(
            "UPDATE checkers " +
            "SET scaife_checker_id = '#{r["scaife_checker_id"]}' " + 
            "WHERE id = '#{r["id"]}'"
          )
        end
      end
    end

  end

  # Assuming the HTML files are located in public/GNU/[proj_id]/HTML,
  # this updates the database with links to their corresponding pages
  def self.createLinks(project_id)
    f = File.open(File.join(Rails.root, "public/GNU/#{project_id.to_s}/HTML", "FILEMAP"))
    dict = {}

    # Remove leading slashes in the Filemap for consistency, it isn't always there
    # If this is fixed in digest_alerts then this is redundant.
    f.each_line do |line|
      l = line.split("\t")
      if l[0].starts_with?("/")
        l[0] = l[0].slice(1..-1)
      end
      dict[l[0].downcase] = l[1]
    end

    # The rest of this is just updating every alert and message corresponding to the project
    # First select all (id,path,line) tuples from the alerts and messages tables
    con = connection()
    data = con.execute("SELECT id, path, line FROM displays WHERE project_id='#{project_id}' ")
    messages = con.execute("SELECT id, path, line FROM messages WHERE project_id='#{project_id}' ")

    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    ActiveRecord::Base.transaction do
      data.each do |r|
        link = ""
        path = r["path"].downcase
        # If the path starts with a slash, remove it
        if path.starts_with?("/")
          path = path.slice(1..-1)
        end
        if defined?(path) && defined?(dict[path]) && !dict[path].nil?
          # If the path is defined in the GNU Global filemap then set
          # the URL accordingly.
          link = "/GNU/#{project_id.to_s}/HTML/" + dict[path]
        else
          # Otherwise use the default URL
          link = "/GNU/#{project_id.to_s}/HTML/"
        end
        if !r["line"].nil?
          # If there is a line number, append the tag to the URL
          link = link.to_s + "#L"+ (r["line"].to_s)
        end
        # Finally, update the database with the resulting URL
        con.execute "UPDATE displays SET link = #{con.quote(link)} WHERE id=#{con.quote(r["id"])}"
      end

      # Do the same thing for every message as well
      messages.each do |r|
        link = ""
        path = r["path"].downcase
        if path.starts_with?("/")
          path = path.slice(1..-1)
        end
        if defined?(path) && defined?(dict[path]) && !dict[path].nil?
          link = "/GNU/#{project_id.to_s}/HTML/" + dict[path]
        else
          link = "/GNU/#{project_id.to_s}/HTML/"
        end
        if !r["line"].nil?
          link = link.to_s + "#L"+ (r["line"].to_s)
        end
        sql = "UPDATE messages SET link = #{con.quote(link)} WHERE id=#{con.quote(r["id"])}"
        con.execute sql
      end
    end

    ActiveRecord::Base.logger = old_logger

    return true

  end

end
