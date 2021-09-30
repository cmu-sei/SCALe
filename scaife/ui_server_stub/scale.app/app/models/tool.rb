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

class Tool < ApplicationRecord
  has_many :checkers, dependent: :delete_all
  has_many :project_tools, dependent: :delete_all
  has_many :projects, through: :project_tools
  has_many :taxonomies, -> { distinct }, through: :checkers
  has_many :conditions, -> { distinct }, through: :checkers

  class << self

    def platforms()
      self.all.collect { |t| t.platform }.flatten.uniq
    end

    def by_scaife_id(id)
      @by_scaife_id ||= {}
      if @by_scaife_id[id].blank?
        @by_scaife_id[id] = self.where(scaife_tool_id: id).first
        if @by_scaife_id[id].blank?
          raise ScaifeError.new("unknown tool scaife ID: #{id}")
        end
      end
      return @by_scaife_id[id]
    end

  end

  def platform()
    JSON.parse(read_attribute(:platform))
  end

  def platform_str()
    # this is just for display, not CSS, so '/' instead of '-'
    self.platform().join('/')
  end

  def platform_json()
    read_attribute(:platform)
  end

  def group_key()
    # nees to be a dash because of CSS use
    return "#{self.name}-#{self.platform.join('-')}"
  end

  def languages()
    return Language.where(platform: self.platform)
  end

  def languages_str()
    self.languages.collect { |lang| lang.name }.uniq.join('/')
  end

  # Creates the Checker-to-Condition Mappings in SCAIFE format.
  def checker_to_condition_mappings()
    checker_mappings = []
      
    for checker in self.checkers
      mapping = {}
      scaife_conditions = []

      checker.conditions.each do |cond|
          scaife_cond = { # Remove the CWE prefix 
            condition_name: cond.name || "",
            title: cond.title || "",
            taxonomy_name: cond.taxonomy.name,
            taxonomy_version: cond.taxonomy.version
          }
          if cond.additional_fields.present?
            scaife_cond["condition_fields"] = cond.additional_fields
          end
          scaife_conditions << scaife_cond
      end
      if not scaife_conditions.empty?
        mapping["checker_name"] = checker.name
        mapping["conditions"] = scaife_conditions
          
        checker_mappings << mapping
      end
    end
    
    return checker_mappings
  end
  
  def scaife_checker_mappings()
    # Create the checker mappings JSON
    checker_mappings = []
    mappings = self.checker_to_condition_mappings()
    
    if not mappings.empty?
      checker_mapping = {}
      checker_mapping["mapping_source"] = "SCALe UI"
      checker_mapping["mapper_identity"] = ["secure coding team"]
      checker_mapping["mapping_version"] = self.version.to_s # Keep same version as the tool for now
      checker_mapping["mapping_date"] = DateTime.now
      checker_mapping["mappings"] = mappings
      
      checker_mappings << checker_mapping
    end
    
    return checker_mappings
  end

end
