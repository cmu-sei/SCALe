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

class Project < ActiveRecord::Base

  # A project has 2 attributes: a name and description.
  #attr_accessible :description, :name

  has_many :project_tools, dependent: :delete_all
  has_many :tools, through: :project_tools
  has_many :project_taxonomies, dependent: :delete_all
  has_many :taxonomies, through: :project_taxonomies
  has_many :project_languages, dependent: :delete_all
  has_many :languages, through: :project_languages
  has_many :checkers, through: :tools
  has_many :conditions, through: :taxonomies

  # A project is associated with many displays and many messages, and
  # upon destruction of the project, these displays and messages
  # should also be destroyed.
  has_many :displays, :dependent => :delete_all
  has_many :messages, :dependent => :delete_all
  has_many :determinations, :dependent => :delete_all
  has_many :priority_schemes, :dependent => :delete_all

  # It must have a name
  validates :name, :presence => true

  class << self

    # for detecting the presence of unknown checkers
    attr_accessor :max_external_linked_checker_id

  end

  attr_accessor :is_test_suite

  def all_taxonomies()
    # all potential taxonomies based on this project's selected tools
    Taxonomy.distinct.joins(%Q(
      JOIN conditions ON conditions.taxonomy_id = taxonomies.id
      JOIN condition_checker_links ON condition_checker_links.condition_id = conditions.id
      JOIN checkers ON checkers.id = condition_checker_links.checker_id
      JOIN project_tools ON project_tools.tool_Id = checkers.tool_id
    )).where('project_tools.project_id' => self.id)
  end

  def all_conditions()
    # all potential conditions based on this project's selected tools
    Condition.distinct.joins(%Q(
      JOIN condition_checker_links ON condition_checker_links.condition_id = conditions.id
      JOIN checkers ON checkers.id = condition_checker_links.checker_id
      JOIN project_tools ON project_tools.tool_Id = checkers.tool_id
    )).where('project_tools.project_id' => self.id)
  end

  def seen_taxonomies()
    # selected taxonomies triggered on this project's source archive
    # analysis
    #
    # Note: the below query works because taxonomies are added to the
    # project_taxonomies table as they are encountered during the import
    # of tool analyses. If that weren't the case, this would be used
    # instead:
    #
    # self.all_taxonomies.distinct.joins(%Q(
    #   JOIN displays ON displays.condition = conditions.name
    # )).where("displays.project_id" => self.id)
    self.taxonomies.distinct.joins(%Q(
      JOIN conditions ON conditions.taxonomy_id = taxonomies.id
      JOIN displays ON displays.condition = conditions.name
    )).where("displays.project_id" => self.id)
  end

  def seen_conditions()
    # all conditions from selected taxonomies triggered on this
    # project's source archive analysis (see comment in
    # seen_taxonomies() for caveat)
    self.conditions.distinct.joins(%Q(
      JOIN displays ON displays.condition = conditions.name
    )).where("displays.project_id" => self.id)
  end

  def seen_tools()
    # all selected tools that acturally generated alerts during
    # project's source archive analysis (it's possible to select tools
    # for a project that has no source code written in the language(s)
    # that tools supports, for example)
    self.tools.distinct.joins(%Q(
      JOIN displays ON displays.tool_id = tools.id
    )).where("displays.project_id" == self.id)
  end

  def seen_checkers()
    # all checkers triggered on this project's source archive
    # analysis (includes unknown checkers that aren't in the
    # .properties files yet)
    Checker.distinct.joins(%Q(
      JOIN displays ON displays.checker = checkers.name
    )).where("displays.project_id" => self.id)
  end

  def seen_defined_checkers()
    # all checkers belonging to selected tools triggered on this
    # project's source archive analysis (does not include unknown
    # checkers)
    self.checkers.distinct.joins(%Q(
      JOIN displays ON displays.checker = checkers.name
    )).where("displays.project_id" => self.id)
  end

  def platforms()
    return self.tools.collect { |t| t.platform }.flatten.uniq
  end

  def seen_platforms()
    # all platforms, belonging to selected tools for this project, seen
    # in conditions triggered on this project's source archive analysis
    seen_plats = self.seen_conditions.collect { |c| c.platform }.uniq
    return seen_plats & self.platforms()
  end

  def seen_all_platforms()
    # all platforms, belonging to any tool, seen in conditions triggered
    # on this project's source archive analysis (should probably be the
    # same as seen_platforms()
    seen_plats = self.seen_conditions.collect { |c| c.platform }.uniq
    return seen_plats & Tool.platforms
  end

  def seen_languages()
    # languages explicitly selected for this project that have been seen
    return self.languages.where(platform: self.seen_platforms())
  end

  def seen_all_languages()
    # languages seen even if not selected for this project
    return Language.where(platform: self.seen_all_platforms())
  end

  def _tools2taxo_inference()
    # information helpful for javascript to highlight suggested
    # taxonomies during taxonomy selection for projects
    tools2taxos = {}
    project_taxos = self.seen_taxonomies()
    ToolGroup.all.each do |tg|
      # possibly checked tools on page
      tools2taxos[tg.key] ||= {}
      tg.tools.each do |tool|
        if self.tools.exists? tool.id
          # confirmed (previously selected) tool
          tools2taxos[tg.key][tool.version] =
            (project_taxos & tool.taxonomies).collect { |taxo| taxo.id }
        else
          # tool possibly just checked on web page
          tools2taxos[tg.key][tool.version] =
            tool.taxonomies.collect { |taxo| taxo.id }
        end
      end
    end
    project_taxos = project_taxos.collect { |taxo| taxo.id }
    return tools2taxos, project_taxos
  end


  # This function was used a long time ago for manually creating projects
  # from the command line. It has thus been deprecated.
  def self.manualCreate
    project = Project.new(name: "manual import", description: "manually created from the rails console")
    project.save!
    if Display.importScaleMI(project.id) == "invalid"
      project.destroy
    else
      path = Rails.root.join("db/backup/#{project.id}")
      if Dir.exists?(path)
        FileUtils.rm_rf(path)
      end
      Dir.mkdir path

      FileUtils.cp(Rails.root.join('db/external.sqlite3'),path)
    end
  end
end

class ProjectTool < ApplicationRecord
  belongs_to :project
  belongs_to :tool
end

class ProjectLanguage < ApplicationRecord
  belongs_to :project
  belongs_to :language
end

class ProjectTaxonomy < ApplicationRecord
  belongs_to :project
  belongs_to :taxonomy
end
