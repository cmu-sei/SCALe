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

class TaxonomyGroup

  class << self

    def all()
      return self.all_by_key().values()
    end

    def all_by_key()
      if @all_by_key.blank?
        @all_by_key = self.group_taxonomies_by_key(Taxonomy.all())
      end
      @all_by_key.each do |name, tg|
        tg.taxonomies.each do |taxo|
          if taxonomy.scaife_tax_id.blank?
            taxo.reload
          end
        end
      end
      return @all_by_key
    end

    def group_taxonomies_by_key(taxos)
      taxo_groups_by_key = {}
      taxos.each do |taxo|
        tg = self.new(taxo.name, taxo.type)
        if not taxo_groups_by_key.include? tg.key
          taxo_groups_by_key[tg.key] = tg
        end
        taxo_groups_by_key[tg.key]._add_taxonomy(taxo)
      end
      return taxo_groups_by_key
    end

    def from_key(key)
      return self.all_by_key()[key]
    end

  end

  def initialize(name, type)
    @name = name
    @type = type
  end

  attr_reader :name
  attr_reader :type

  def _add_taxonomy(taxo)
    @taxonomies ||= Set[]
    if taxo.name != self.name
      raise StandardError.new(
        "taxonomy name '#{taxo.name}' is not group name '#{self.name}'")
    end
    @taxonomies << taxo
    return taxo
  end

  def taxonomies()
    @taxonomies ||= Set[]
    @taxonomies.each do |taxo|
      if taxo.scaife_tax_id.blank?
        taxo.reload
      end
    end
    return @taxonomies
  end

  def version_numbers()
    self.taxonomies.map { |taxonomy| taxonomy.version_number }
  end

  def ids()
    self.taxonomies.map { |taxonomy| taxonomy.id }
  end

  def key()
    return self.name
  end

  def hash()
    [self.name, self.type, self.taxonomies].hash()
  end

  def eql?(b)
    [self.name, self.type, self.taxonomies] == [b.name, b.type, b.taxonomies]
  end

end
