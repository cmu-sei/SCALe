# -*- coding: utf-8 -*-
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.


# An instance of a Display class is literally a row that is displayed
# to the auditor.
class Display < ActiveRecord::Base


# Consequently, the attributes for a Display are the columns of the
# table.
  attr_accessible :id, :flag, :verdict, :ignored, :dead,
      :inapplicable_environment, :dangerous_construct,
      :previous, :path, :line, :link, :message, :checker, :tool,
      :rule, :title, :severity, :liklihood, :remediation,
      :priority, :level, :cwe_likelihood, :notes, :project_id,
      :meta_alert_id, :diagnostic_id

    # A display belongs to a particular project, and each display
    # can have many messages.
    belongs_to :project
    has_many :messages

    #TODO: rework this to allow for fused alerts

    # We enforce that the meta_alert_id must be present and unique within
    # the scope of each project.
    #validates_uniqueness_of :meta_alert_id, scope: [ :project_id ]
    validates_presence_of :meta_alert_id

    # TODO: find a better way to do validation.  These are outdated because the model is more complex.
    # Uncommenting this prevents single diagnostic edits.

    # We also validate that some of the columns are non-negative integers
    #validates :meta_alert_id, :numericality => { :greater_than_or_equal_to => 0, only_integer: true }
    #validates :line, :numericality => { :greater_than_or_equal_to => 0, only_integer: true }
    #validates :liklihood, :numericality => { :greater_than_or_equal_to => 0, only_integer: true }
    #validates :remediation, :numericality => { :greater_than_or_equal_to => 0, only_integer: true }
    #validates :priority, :numericality => { :greater_than_or_equal_to => 0, only_integer: true }
    #validates :level, :numericality => { :greater_than_or_equal_to => 0, only_integer: true }
	  #validates :cwe_likelihood, :numericality => { :greater_than_or_equal_to => 0, only_integer: false }
    #validates :dangerous_construct, :numericality => { :greater_than_or_equal_to => 0, only_integer: true }

 # This helper function constructs the filter query from the parameters
 # submitted by the filter form at the top of the main auditing page.
 # connection.quote is used to quote and sanitize all inputs.
 def self.constructSQLFilter(project_id, id_type, id, verdict, previous, path, line, tool, checker, rule, taxonomy)
    filter = "project_id = " + connection.quote(project_id)
    #if(meta_alert_id != "")
    #  filter += " AND meta_alert_id = " + connection.quote(meta_alert_id)
    #end
    if(id_type == "Diagnostic ID")
        filter += " AND id = " + connection.quote(id)
    elsif(id_type == "Meta-Alert ID")
       filter += " AND meta_alert_id = " + connection.quote(id)
    end
    if(verdict.to_i != -1)
      filter += " AND verdict = " + connection.quote(verdict)
    end
    if(previous.to_i != -1)
      filter += " AND previous = " + connection.quote(previous)
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
    if(rule != "")
      filter += " AND rule = " + connection.quote(rule)
    end
    if(!taxonomy.empty?)
      current_filter = filter
      filter += " AND rule = " + connection.quote(taxonomy[0])
      taxonomy[1, taxonomy.length].each do |r| #ignore first item in list
        filter += " OR " + current_filter + " AND rule = " + connection.quote(r)
      end
    end
	## set up later for filtering based on cwe_likelihood and notes also
#    if(cwe_likelihood != "")
#      filter += " AND cwe_likelihood = " + connection.quote(cwe_likelihood)
#    end
    #puts filter
    return filter
  end

  # Speedily inserts all the database entries into the Displays table. It
  # risks ignoring validations to avoid taking too long on large projects.
  def self.importScaleMI(project_id)
    environment = :development
    start_time = Time.now

    # db/external.sqlite3 is imported into the database. This assumes
    # that the external.sqlite3 has already been uploaded.
    establish_connection :external
    con = connection()

    puts("Importing new data")

    # Fetching all the diagnostic data and all the distinct messages.
    #"select distinct diagnostics.id, diagnostics.flag, diagnostics.verdict, diagnostics.previous, messages.path, messages.line, messages.message, diagnostics.checker, tools.name as tool, rules.name, rules.title, rules.severity, rules.liklihood, rules.remediation, rules.priority, rules.level  from diagnostics inner join checkers on checkers.name=diagnostics.checker "

    cert_data = con.execute(\
      "SELECT DISTINCT MetaAlerts.id, MetaAlerts.flag, MetaAlerts.verdict,"\
      "MetaAlerts.ignored, MetaAlerts.dead, MetaAlerts.inapplicable_environment, "\
      "MetaAlerts.dangerous_construct, MetaAlerts.previous, Messages.path,"\
      "Diagnostics.confidence, Diagnostics.alert_priority, Messages.line, Messages.message, "\
      "Checkers.name AS checker, Tools.name AS tool, TaxonomyEntries.name, TaxonomyEntries.title, "\
      "CERTRules.severity, CERTRules.liklihood, CERTRules.remediation, "\
      "CERTRules.priority, CERTRules.level, MetaAlerts.notes, Diagnostics.id AS diagnostic_id "\
      "FROM Diagnostics "\
      "JOIN Messages ON Messages.id=Diagnostics.primary_msg "\
      "JOIN DiagnosticMetaAlertLinks ON DiagnosticMetaAlertLinks.diagnostic=Diagnostics.id "\
      "JOIN MetaAlerts ON MetaAlerts.id=DiagnosticMetaAlertLinks.meta_alert_id "\
      "JOIN Checkers ON Checkers.id=Diagnostics.checker "\
      "JOIN TaxonomyCheckerLinks ON TaxonomyCheckerLinks.checker=Checkers.id "\
      "JOIN TaxonomyEntries ON TaxonomyEntries.id=MetaAlerts.taxonomy_id "\
      "JOIN CERTRules ON CERTRules.taxonomy_id=TaxonomyEntries.id "\
      "JOIN Tools ON Tools.id=Checkers.tool ")

    cwe_data = con.execute(\
      "SELECT DISTINCT MetaAlerts.id, MetaAlerts.flag, MetaAlerts.verdict,"\
      "MetaAlerts.ignored, MetaAlerts.dead, MetaAlerts.inapplicable_environment, "\
      "MetaAlerts.dangerous_construct, MetaAlerts.previous, Messages.path,"\
      "Diagnostics.confidence, Diagnostics.alert_priority, Messages.line, Messages.message, "\
      "Checkers.name AS checker, Tools.name AS tool, TaxonomyEntries.name, TaxonomyEntries.title, "\
      "cwes.cwe_likelihood, MetaAlerts.notes, Diagnostics.id AS diagnostic_id "\
      "FROM Diagnostics "\
      "JOIN Messages ON Messages.id=Diagnostics.primary_msg "\
      "JOIN DiagnosticMetaAlertLinks ON DiagnosticMetaAlertLinks.diagnostic=Diagnostics.id "\
      "JOIN MetaAlerts ON MetaAlerts.id=DiagnosticMetaAlertLinks.meta_alert_id "\
      "JOIN Checkers ON Checkers.id=Diagnostics.checker "\
      "JOIN TaxonomyCheckerLinks ON TaxonomyCheckerLinks.checker=Checkers.id "\
      "JOIN TaxonomyEntries ON TaxonomyEntries.id=MetaAlerts.taxonomy_id "\
      "JOIN CWEs ON CWEs.taxonomy_id=TaxonomyEntries.id "\
      "JOIN Tools ON Tools.id=Checkers.tool ")

    data = cert_data + cwe_data


    # Also, select all messages separately to insert in the Messages table
    messages = con.execute("SELECT * FROM Messages")
    remove_connection

    # We need to now restore the connection to the original database.

    # Commence inserting entries into the main database
    establish_connection environment
    con = connection()

    # Save the old logger, since I temporarily disable the logger
    # for the mass insertions (too verbose).
    old_logger = ActiveRecord::Base.logger

    # Use a single transaction with raw sql inserts for maximum performance
    con.execute("BEGIN TRANSACTION")

    ActiveRecord::Base.logger = nil

    ActiveRecord::Base.transaction do
      data.each do |r|
        # For entry, extract and sanitize each Display attribute
        # and insert it into the displays table.
        id = ActiveRecord::Base.connection.quote(r["id"]);
        flag = ActiveRecord::Base.connection.quote(r["flag"]);
        verdict = ActiveRecord::Base.connection.quote(r["verdict"]);
	      ignored = ActiveRecord::Base.connection.quote(r["ignored"]);
	      dead = ActiveRecord::Base.connection.quote(r["dead"]);
	      inapplicable_environment = ActiveRecord::Base.connection.quote(r["inapplicable_environment"]);
	      dangerous_construct = ActiveRecord::Base.connection.quote(r["dangerous_construct"]);
        previous = ActiveRecord::Base.connection.quote(r["previous"]);
        path = ActiveRecord::Base.connection.quote(r["path"]);
        line = ActiveRecord::Base.connection.quote(r["line"]);
        message = ActiveRecord::Base.connection.quote(r["message"]);
        checker = ActiveRecord::Base.connection.quote(r["checker"]);
        tool = ActiveRecord::Base.connection.quote(r["tool"]);
        rule = ActiveRecord::Base.connection.quote(r["rule"]);
        title = ActiveRecord::Base.connection.quote(r["title"]);
        confidence = ActiveRecord::Base.connection.quote(r["confidence"]);
        alert_priority = ActiveRecord::Base.connection.quote(r["alert_priority"]);
        name = ActiveRecord::Base.connection.quote(r["name"]);
        severity = ActiveRecord::Base.connection.quote(r["severity"]);
        liklihood = ActiveRecord::Base.connection.quote(r["liklihood"]);
        remediation = ActiveRecord::Base.connection.quote(r["remediation"]);
        priority = ActiveRecord::Base.connection.quote(r["priority"]);
        level = ActiveRecord::Base.connection.quote(r["level"]);
		cwe_likelihood = ActiveRecord::Base.connection.quote(r["cwe_likelihood"]);
        diagnostic_id = ActiveRecord::Base.connection.quote(r["diagnostic_id"]);
        notes = ActiveRecord::Base.connection.quote(r["notes"]);
        begin
          sql = "INSERT INTO displays ("+
          "'meta_alert_id', "+
          "'flag', "+
          "'verdict', "+
          "'ignored', "+
          "'dead', "+
          "'inapplicable_environment', "+
          "'dangerous_construct', "+
          "'previous', "+
          "'path', "+
          "'line', "+
          "'link', "+
          "'message', "+
          "'checker', "+
          "'tool', "+
          "'rule', "+
          "'title', "+
          "'confidence', "+
          "'alert_priority', "+
          "'severity', "+
          "'liklihood', "+
          "'remediation', "+
          "'priority', "+
          "'level', "+
		  "'cwe_likelihood', "+
		  "'notes', "+
          "'diagnostic_id', "+
          "'project_id')"+
          "VALUES "+
          "(#{id}, "+
          "#{flag}, "+
          "#{verdict}, "+
          "#{ignored}, "+
          "#{dead}, "+
          "#{inapplicable_environment}, "+
          "#{dangerous_construct}, "+
          "#{previous}, "+
          "#{path}, "+
          "#{line}, "+
          "'/HTML/', "+
          "#{message}, "+
          "#{checker}, "+
          "#{tool}, "+
          "#{name}, "+
          "#{title}, "+
          "#{confidence}, "+
          "#{alert_priority}, "+
          "#{severity}, "+
          "#{liklihood}, "+
          "#{remediation}, "+
          "#{priority}, "+
          "#{level},"+
		  "#{cwe_likelihood}, "+
		  "#{notes}, "+
          "#{diagnostic_id}, "+
          "#{project_id});"

          con.execute sql
        rescue ActiveRecord::StatementInvalid => invalid
          # If there is an inconsistency with the Scale database then catch and report the error
          ActiveRecord::Base.logger = old_logger
          con.execute("END TRANSACTION")

          puts invalid
          puts ""
          puts "Invalid sql table. Check the keys to ensure unique entries"
          puts "Examining diagnostic with id = " + r["id"].to_s + ". If any of the below entries come up with more than 1, fix the scale database."
          puts ""

          remove_connection
          establish_connection :external
          con = connection()

          puts "Diagnostic with id=#{r["id"]}"
          d1 = con.execute("SELECT * FROM Diagnostics WHERE id=#{r["id"]}")
          puts d1
          puts ""

          puts "Checkers with matching key"
          d2 = con.execute("SELECT * FROM Checkers WHERE name='#{d1[0]["checker"]}'")
          puts d2
          puts ""

          puts "Tools with matching key"
          d3 = con.execute("SELECT * FROM Tools WHERE id='#{d1[0]["tool"]}'")
          puts d3
          puts ""

          puts "Messages with matching key"
          d4 = con.execute("SELECT * FROM Messages WHERE id='#{d1[0]["primary_msg"]}'")
          puts d4
          puts ""

          puts "Rules with matching key"
          d3 = con.execute("SELECT * FROM CERTRules WHERE name='#{d2[0]["rule"]}'")
          puts d3
          puts ""

          remove_connection
          establish_connection environment
          return "invalid"
        end
      end
    end

    # Also insert all additional messages into the associated table.
    ActiveRecord::Base.transaction do
      messages.each do |m|
        diagnostic = ActiveRecord::Base.connection.quote(m["diagnostic"])
        path = ActiveRecord::Base.connection.quote(m["path"])
        line = ActiveRecord::Base.connection.quote(m["line"])
        message = ActiveRecord::Base.connection.quote(m["message"])
        sql = "INSERT INTO Messages ('project_id', 'diagnostic_id', 'path', 'line', 'message') VALUES ('#{project_id}', #{diagnostic}, #{path}, #{line}, #{message})"
        con.execute sql
      end
    end

    # Restore the original logger and end the transaction
    ActiveRecord::Base.logger = old_logger
    con.execute("END TRANSACTION")

    end_time = Time.now

    # Print the time it took for the transaction
    puts("Time elapsed: #{(end_time-start_time).to_i}")
  end

  # Assuming the HTML files are located in public/GNU/[proj_id]/HTML,
  # this updates the database with links to their corresponding pages
  def self.createLinks(project_id)
    f = File.open(File.join(Rails.root, "public/GNU/#{project_id.to_s}/HTML", "FILEMAP"))
    dict = {}

    # Remove leading slashes in the Filemap for consistency, it isn't always there
    # If this is fixed in digest_diagnostics then this is redundant.
    f.lines.each do |line|
      l = line.split("\t")
      if l[0].starts_with?("/")
        l[0] = l[0].slice(1..-1)
      end
      dict[l[0].downcase] = l[1]
      puts l[0]
    end

    # The rest of this is just updating every diagnostic and message corresponding to the project
    # First select all (id,path,line) tuples from the diagnostics and messages tables
    con = connection()
    data = con.execute("SELECT id, path, line FROM displays WHERE project_id='#{project_id}' ")
    messages = con.execute("SELECT id, path, line FROM Messages WHERE project_id='#{project_id}' ")
    con.execute("BEGIN TRANSACTION")

    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

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
      sql = "UPDATE Displays SET link = #{con.quote(link)} WHERE id=#{con.quote(r["id"])}"
      con.execute sql
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
      sql = "UPDATE Messages SET link = #{con.quote(link)} WHERE id=#{con.quote(r["id"])}"
      con.execute sql
    end

    ActiveRecord::Base.logger = old_logger
    con.execute("END TRANSACTION")
    # return true
    true
  end
end
