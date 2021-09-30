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

class Condition < ApplicationRecord
  belongs_to :taxonomy
  has_many :condition_checker_links
  has_many :checkers, through: :condition_checker_links
  has_many :tools, -> { distinct }, through: :checkers

  def additional_field_names
    # avoid hitting the taxonomies table for every single condition
    @@taxonomy_fields ||= {}
    return(@@taxonomy_fields[self.taxonomy_id] ||= self.taxonomy.format_fields)
  end

  def additional_field_data
    if @data_row.blank?
      if self.formatted_data.present?
        @data_row = JSON.parse(self.formatted_data)
      else
        @data_row = []
      end
    end
    return @data_row
  end

  def additional_fields
    if @data.blank?
      @data = Hash[self.additional_field_names.zip(self.additional_field_data)]
    end
    return @data
  end

  def platform
    if @platform.blank?
      @platform = self.additional_fields[:platform] \
        || self.additional_fields[:cwe_platform]
    end
    return @platform
  end

  def languages
    if @languages.blank?
      @languages = []
      if self.type != 'cwe'
        by_name = \
          Language.all_by_platform_and_name()[self.platform.downcase] || {}
        by_name.each do |name, langs|
          # just choose the last one (which happens to be highest version)
          # (at some point in the future we need to associate selected
          # language versions into this)
          @languages << langs[-1]
        end
      end
    end
    @languages.each do |lang|
      if lang.scaife_language_id.blank?
        lang.reload
      end
    end
    return @languages
  end

  def to_scaife()
    scaife_cond = {
        # required
        condition_name: self.name || "",
        title: self.title || "",
    }
    if self.additional_fields.present?
      scaife_cond["condition_fields"] = self.additional_fields
    end
    # code_language_ids not required yet
    # platforms not required (means OS, the language-related 'platform'
    return scaife_cond
  end

  def type()
    return self.taxonomy.type
  end

  class << self

    def by_scaife_id(id)
      # lazy loader by scaife ID
      @by_scaife_id ||= {}
      if @by_scaife_id[id].blank?
        @by_scaife_id[id] = self.where(scaife_cond_id: id).first
        if @by_scaife_id[id].blank?
          raise ScaifeError.new("unknown condition scaife ID: #{id}")
        end
      end
      return @by_scaife_id[id]
    end

  end

end

class ConditionCheckerLink < ApplicationRecord
  belongs_to :condition
  belongs_to :checker
end
