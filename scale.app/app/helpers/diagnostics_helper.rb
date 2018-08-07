# -*- coding: utf-8 -*-
# Copyright (c) 2007-2018 Carnegie Mellon University. All Rights Reserved. See COPYRIGHT file for details.

# This file provides a shortcut for retrieving the columns of a diagnotic. The link renderer is for the pagination. 

module DiagnosticsHelper

  # The LinkRenderer class is for the pagination gem, and defines
  # how the HTML for the pagination is rendered. 
  class LinkRenderer < WillPaginate::ActionView::LinkRenderer
      def to_html
        html = pagination.map do |item|
          item.is_a?(Fixnum) ?
            page_number(item) :
            send(item)
        end

        html = html.insert(1,html.last)

        html.pop

        html = html.join(@options[:link_separator])
        
        @options[:container] ? html_container(html) : html
      end
  end


  # If the doc dir has exports of the CERT rules, scan through them and build a rule -> file map
  # to be used when bringing up rule hyperlinks (and Google can't be used, say b/c we are offline)
  def DiagnosticsHelper.build_rule_map
    result = {}
    doc = "public/doc"
    Dir.new(doc).each do |lang|
      if File.directory?("#{doc}/#{lang}")
        Dir.new("#{doc}/#{lang}").each do |page|
          if File.file?("#{doc}/#{lang}/#{page}")
            IO.foreach("#{doc}/#{lang}/#{page}") do |line|
              begin
                line.match('\s<title>.*\s:\s(\w*\d*-\w*)\.\s') do |match|
                  result[match[1]] = "#{lang}/#{page}"
                end
              rescue ArgumentError # to survive bad UTF8 chars
              end
            end
          end
        end
      end
    end
    result
  end
  $Rule_Map = DiagnosticsHelper.build_rule_map


  # This is a helper that will parse the column name and return the corresponding
  # HTML formatted data. 
  def getContentFast(col, d)
    case col
    when :id
       content_tag(:p) do
          d[:id].to_s + "\u00a0(d)" #a non-breaking space (&nbsp;) preceeds "(d)"
        end
    when :meta_alert_id
      if Message.where("diagnostic_id = " + d[:diagnostic_id].to_s + " AND project_id = " + d[:project_id].to_s).count > 1
        content_tag(:p) do
          str = d[:meta_alert_id].to_s + "\u00a0(m)"
          link_to str, display_path(d), remote: true
        end
      else
        content_tag(:p) do
          d[:meta_alert_id].to_s + "\u00a0(m)"
        end
      end
    when :flag
      best_in_place d, :flag, as: :checkbox, collection: ["[ ]", "[x]"]
    when :verdict
      best_in_place d, :verdict, class: "best_in_place_verdict", as: :select, collection: [[0,"[Unknown]"],[1,"[Complex]"],[2,"[False]"],[3,"[Dependent]"],[4,"[True]"]]
    when :previous
      case d[:previous]
      when 1
        "Complex"
      when 2
        "False"
      when 3
        "Dependent"
      when 4
        "True"
      else
        "Unknown"
      end
    when :line
      content_tag(:a, { href: d.link }) do 
        d[:line].to_s
      end
    when :checker
      link_to d[:checker].to_s, diagnostics_path(
                project_id: d.project_id,
                path: d.path,
                line: d.line,
                checker: d.checker,
                commit: "Filter")
    when :confidence
      "--"
    when :alert_priority
      "--"
	## charuta
	## is this necessary
	#when :cwe_likelihood
	 # d[:cwe_likelihood]
    when :notes
      best_in_place d, :notes, class: "best_in_place_notes", as: :textarea
    when :supplemental
       #d[:dead]=true#LLBDEBUG
       ( (d[:ignored] ? "Ignored<br>" : "") +
         (d[:dead] ? "Dead<br>" : "") + 
         (d[:inapplicable_environment] ? "Inapplicable Env.<br>" : "") + 
         (["", "Dangerous - Low<br>", "Dangerous - Med<br>", "Dangerous - High<br>"].at(d[:dangerous_construct])) +
         (link_to 'Edit', diagnostic_path(d), remote: true).to_s
       ).html_safe
    when :rule
      # Try to lookup a local version of the link
      url = nil
      if ($Rule_Map != nil) and ($Rule_Map.is_a?(Hash))
          if ($Rule_Map.has_key?(d[col]))
              url = "/doc/#{$Rule_Map[d[col]]}"
          end
      end

      if url == nil
          # If rule is a CWE, find it in MITRE's site
          d[col].match("CWE-(.*)") do |match|
            cwe = match[1]
            if (File.exists?("public/doc/CWE.pdf"))
              url = "/doc/CWE.pdf"
            else
              url = "https://cwe.mitre.org/data/definitions/#{cwe}.html"
            end
          end
      end
      
      if url == nil
          # Must be a CERT rule, google it in CERT's site.
          url = "http://www.google.com/search?btnI&q=#{d[col]}%20site%3Awww.securecoding.cert.org"
      end

      link_to(d[col], url)
    when :message
      #d[:message]
      if Message.where("diagnostic_id = " + d[:diagnostic_id].to_s + " AND project_id = " + d[:project_id].to_s).count > 1
        content_tag(:span) do
          (d[:message] + " " + (link_to 'Secondary Message Set', display_path(d), remote: true).to_s).html_safe
        end
      else
        content_tag(:span) do
          d[:message]
        end
      end
    else
      d[col]
    end
  end

end
