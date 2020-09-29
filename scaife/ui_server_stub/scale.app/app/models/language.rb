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

class Language < ApplicationRecord
  has_many :project_languages, dependent: :delete_all
  has_many :projects, through: :project_languages

  class << self

    def all_by_name()
      langs = {}
      self.all do |lang|
        (langs[lang.name] ||= []) << lang
      end
      return langs
    end

    def all_by_platform()
      langs = {}
      self.all.each() do |lang|
        (langs[lang.platform] ||= []) << lang
      end
      return langs
    end

    def all_by_platform_and_name()
      by_plat_and_name = {}
      self.all.each do |lang|
        by_name = by_plat_and_name[lang.platform.downcase] ||= {}
        (by_name[lang.name] ||= []) << lang
      end
      return by_plat_and_name
    end

    def by_platform(plat)
      self.all.where(platform: plat)
    end

    def by_project_id(proj_id)
      langs = []
      temp = Project.find(proj_id).languages()

      temp.each do |lang|
          #puts lang.name
          langs.append(lang.name)
      end
      return langs
    end

    def platforms()
      return self.all.collect { |l| l.platform }.uniq
    end
  end

end
