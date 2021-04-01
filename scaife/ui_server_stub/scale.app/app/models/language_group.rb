# -*- coding: utf-8 -*-

# <legal>
# SCALe version r.6.5.5.1.A
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

class LanguageGroup

  class << self

    def all()
      return self.all_by_key().values()
    end

    def from_key(key)
      return self.all_by_key()[key]
    end

    def all_by_key()
      if @all_by_key.blank?
        @all_by_key = self.group_languages_by_key(Language.all())
      end
      @all_by_key.each_value do |lg|
        lg.languages do |lang|
          if lang.scaife_language_id.blank?
            lang.reload
          end
        end
      end
      return @all_by_key
    end

    def group_languages_by_key(langs)
      lang_groups_by_key = {}
      langs.each do |lang|
        lg = self.new(lang.name, lang.platform)
        if not lang_groups_by_key.include? lg.key
          lang_groups_by_key[lg.key] = lg
        end
        lang_groups_by_key[lg.key]._add_language(lang)
      end
      return lang_groups_by_key
    end

    def group_languages(langs)
      return Set.new(self.group_languages_by_key(langs).values())
    end

    def all_by_platform_and_name()
      by_plat_name = {}
      self.all.each do |lg|
        by_plat = by_plat_name[lg.name] ||= {}
        by_name = by_plat[lg.platform] ||= []
        by_name << lg.languages
      end
      return by_plat_name
    end

  end

  def initialize(name, platform)
    @name = name
    @platform = platform
  end

  attr_reader :name
  attr_reader :platform

  def _add_language(lang)
    @languages ||= Set[]
    if lang.name != self.name
      raise StandardError.new(
        "language name '#{lang.name}' is not group name '#{self.name}'")
    end
    if lang.platform != self.platform
      raise StandardError.new(
        "language platform '#{lang.platform}' is not group platform '#{self.platform}'")
    end
    @languages << lang
    return lang
  end

  def languages
    @languages ||= Set[]
    @languages.each do |lang|
      if lang.scaife_language_id.blank?
        lang.reload
      end
    end
    return @languages
  end

  def versions()
    self.languages.map { |lang| lang.version }
  end

  def ids()
    self.languages.map { |lang| lang.id }
  end

  def key()
    return self.name
  end

  def hash()
    [self.name, self.platform, self.languages].hash()
  end

  def eql?(b)
    [self.name, self.platform, self.languages] == [b.name, b.platform, b.languages]
  end

end
