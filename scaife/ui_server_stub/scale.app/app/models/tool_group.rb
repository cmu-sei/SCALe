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

class ToolGroup

  class << self

    def all()
      tool_groups = []
      tool_groups_by_key = self.all_by_key()
      Tool.all.each do |tool|
        tg = self.new(tool.name, tool.platform)
        if tool_groups_by_key.include? tg.key
          tool_groups << tool_groups_by_key.delete(tg.key)
        end
      end
      return tool_groups
    end

    def all_by_key()
      if @all_by_key.blank?
        @all_by_key = {}
        Tool.all.each do |tool|
          tg = self.new(tool.name, tool.platform)
          (@all_by_key[tg.key] ||= tg).add_tool(tool)
        end
      end
      @all_by_key.each do |name, tg|
        tg.tools.each do |tool|
          if tool.scaife_tool_id.blank?
            tool.reload
          end
        end
      end
      return @all_by_key
    end

    def from_key(key)
      return self.all_by_key()[key]
    end

  end

  def initialize(name, platform)
    @name = name
    @platform = platform
  end

  attr_reader :name
  attr_reader :platform

  def platform_str()
    # for display purposes, not CSS, so '/' rather than '-'
    self.platform.join('/')
  end

  def key()
    # needs to be a dash because CSS form element names
    return "#{self.name}-#{self.platform.join('-')}"
  end

  def add_tool(tool)
    @tools ||= []
    @tools_by_id ||= {}
    @tools_by_version ||= {}
    if @tools_by_id.include? tool.id
      puts "tool collision by id (#{self.key}): #{tool.id}"
      return
    end
    if @tools_by_version.include? tool.version
      puts "tool collision by version (#{self.key}): #{tool.version}"
      return
    end
    @tools << tool
    @tools_by_id[tool.id] = tool
    @tools_by_version[tool.version] = tool
    return tool
  end

  attr_accessor :tools
  attr_accessor :tools_by_id
  attr_accessor :tools_by_version

  def tool_from_version(version)
    return (@tools_by_version ||= {})[version]
  end

  def tool_from_id(id)
    return (@tools_by_id ||= {})[id]
  end

  def versions()
    self.tools.map { |tool| tool.version }
  end

  def ids()
    self.tools.map { |tool| tool.id }
  end

end
