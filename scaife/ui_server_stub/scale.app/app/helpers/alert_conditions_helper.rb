# -*- coding: utf-8 -*-

# This file provides a shortcut for retrieving the columns of an alertCondition. The link renderer is for the pagination.

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

module AlertConditionsHelper
  include LogDet

  # The LinkRenderer class is for the pagination gem, and defines
  # how the HTML for the pagination is rendered.
  class LinkRenderer < WillPaginate::ActionView::LinkRenderer
      def to_html
        html = pagination.map do |item|
          item.is_a?(Integer) ?
            page_number(item) :
            send(item)
        end

        html = html.insert(1,html.last)

        html.pop

        html = html.join(@options[:link_separator])

        @options[:container] ? html_container(html) : html
      end
  end


  # If the doc dir has exports of the CERT rules, scan through them and
  # build a condition -> file map to be used when bringing up condition
  # hyperlinks (and Google can't be used, say b/c we are offline)
  def AlertConditionsHelper.build_rule_map
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
    return result
  end
  $Rule_Map = AlertConditionsHelper.build_rule_map


  # This is a helper that will parse the column name and return the corresponding
  # HTML formatted data.
  def getContentFast(col, d)

    case col
    when :id
       content_tag(:p) do
          d[:id].to_s + "\u00a0(d)" #a non-breaking space (&nbsp;) preceeds "(d)"
        end
    when :meta_alert_id
      if Message.where("alert_id = " + d[:alert_id].to_s + " AND project_id = " + d[:project_id].to_s).count > 1
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
      best_in_place d, :flag, class: "best_in_place_flag", as: :checkbox, collection: ["[ ]", "[x]"]
    when :verdict
      best_in_place d, :verdict, class: "best_in_place_verdict", as: :select, collection: [[0,"[Unknown]"],[1,"[Complex]"],[2,"[False]"],[3,"[Dependent]"],[4,"[True]"]]
    when :previous
      if d[:previous] > 0
        ((link_to d[:previous].to_s, display_path(d), target: '_blank').to_s).html_safe
      else
        d[:previous]
      end
    when :line
      content_tag(:a, { href: d.link }) do
        #puts d.link
        d[:line].to_s
      end
    when :checker
      link_to d[:checker].to_s, alert_conditions_path(
                project_id: d.project_id,
                path: d.path,
                line: d.line,
                checker: d.checker,
                commit: "Filter")
    when :confidence
      content_tag(:p) do
        if d[:confidence]
          if d[:confidence] != -1
            d[:confidence].to_s
          end
        end
      end
    when :meta_alert_priority
      content_tag(:p) do
        if d[:meta_alert_priority]
          if d[:meta_alert_priority] > 0
            d[:meta_alert_priority].to_s
          end
        end
      end
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
         (link_to 'Edit', alert_condition_path(d), data: {toggle: "modal", target: "#myModal"}).to_s
       ).html_safe
    when :condition
      # Try to lookup a local version of the link
      rule_link = nil
      if ($Rule_Map != nil) and ($Rule_Map.is_a?(Hash))
          if ($Rule_Map.has_key?(d[col]))
              rule_link = $Rule_Map[d[col]]
          end
      end

      if (rule_link != nil)
          rule_link = "/doc/#{rule_link}"
      else #rule_link == nil
          #Test if rule is a CWE
          match = d[col].match("CWE-(.*)")
          if (match == nil)
            # Must be a CERT rule, google it in CERT's site.
            rule_link = "http://www.google.com/search?btnI&q=#{d[col]}%20site%3Awww.securecoding.cert.org"
          else
            # If rule is a CWE, find it in MITRE's site
            cwe = match[1]
            if (File.exists?("public/doc/CWE.pdf"))
              rule_link = "/doc/CWE.pdf"
            else
              rule_link = "https://cwe.mitre.org/data/definitions/#{cwe}.html"
            end
          end
      end

       link_to(d[col], rule_link)



      # Try to lookup a local version of the link
      #local_link = nil
      #if ($Rule_Map != nil) and ($Rule_Map.is_a?(Hash))
      #    if ($Rule_Map.has_key?(d[col]))
      #        local_link = $Rule_Map[d[col]]
      #    end
      #end

      #if local_link != nil
      #    link_to(d[col], "/doc/#{local_link}")
      #else
      #    link_to(d[col], "http://www.google.com/search?btnI&q=#{d[col]}%20site%3Awww.securecoding.cert.org")
      #end



    when :message
      #d[:message]
      if Message.where("alert_id = " + d[:alert_id].to_s + " AND project_id = " + d[:project_id].to_s).count > 1
        content_tag(:span) do
          (d[:message] + " " + (link_to 'Secondary Message Set', display_path(d), target: '_blank').to_s).html_safe


#link_to post_path(@post, :my_param => "param value")
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

=begin
get the selection for the filter with the given param hash key and session
hash key

args:
  paramKey (symbol) - key for the filter in the params hash
  sessionKey (symbol) - key for the filter in the session hash
  defaultVal (string) - the default value for the filter

=end
  def getFilterSelection(paramKey, sessionKey, defaultVal)
    if params[paramKey].nil? # wasn't changed in the filter form
      v = session[sessionKey].nil? ? defaultVal : session[sessionKey]
    else
      v = params[paramKey]
    end
    session[sessionKey] = v

    return v
  end

=begin
  update the attributes of the given display from massUpdate

  args:
    d (Display) - Display object to be updated
    verdict (int) - verdict
      -1 = not set
    flag (str) - flag
      "-1" = not set
    ignored (bool or str) - ignored
      "-1" = not set
    dead (bool or str) - dead
      "-1" = not set
    ienv (bool or str) - inapplicable environment
      "-1" = not set
    dc (str) - dangerous construct
=end
  def update_attrs(d, verdict, flag, ignored, dead, ienv, dc)
    if(verdict != -1)
      d.update_attribute(:verdict, verdict)
    end
    if(flag != "-1")
      d.update_attribute(:flag, flag)
    end
    if ignored != "-1"
      d.update_attribute(:ignored, ignored)
    end
    if dead != "-1"
      d.update_attribute(:dead, dead)
    end
    if ienv != "-1"
      d.update_attribute(:inapplicable_environment, ienv)
    end
    if dc != "-1"
      d.update_attribute(:dangerous_construct, dc)
    end

    if (verdict != -1) or (flag != "-1") or (ignored != "-1") or (dead != "-1")\
      or (ienv != "-1") or (dc != "-1")
      log_det(d)
    end
  end
end
