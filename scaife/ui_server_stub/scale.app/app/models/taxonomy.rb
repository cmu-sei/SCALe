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

class Taxonomy < ApplicationRecord
  has_many :conditions, dependent: :delete_all
  has_many :project_taxonomies, dependent: :delete_all
  has_many :projects, through: :project_taxonomies
  has_many :checkers, -> { distinct }, through: :conditions

  # 'type' column is reserved in rails, disable single table inheritance
  self.inheritance_column = :_type_disabled

  def format()
    # weird errors about this being a private method if it's just native
    read_attribute(:format)
  end

  def format_fields()
    if @format_fields.blank?
      if self.format.present?
        @format_fields = JSON.parse(self.format).map { |f| f.to_sym }
      else
        @format_fields = []
      end
    end
    return @format_fields
  end

  def version()
    self.version_string
  end

  def platforms()
    return self.conditions.collect { |c| c.platform }.uniq & Tool.platforms
  end

  def languages()
    return Language.where(platform: self.platforms())
  end
  
  def scaife_conditions(conditions: nil)
    if conditions.blank?
      conditions = self.conditions
    else
      # make sure the given conditions belong to this taxonomy
      diff = Set.new(conditions) - self.conditions
      if diff.present?
        raise StandardError.new("foreign conditions handed to taxonomy")
      end
    end
    scaife_conditions = []
    conditions.each do |cond|
      scaife_conditions << cond.to_scaife()
    end
    return scaife_conditions
  end

end
