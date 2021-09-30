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

class Checker < ApplicationRecord
  has_many :condition_checker_links
  has_many :conditions, through: :condition_checker_links
  has_many :taxonomies, -> { distinct }, through: :conditions
  belongs_to :tool

  class << self

    def by_scaife_id(id)
      # lazy loader by scaife ID
      @by_scaife_id ||= {}
      if @by_scaife_id[id].blank?
        @by_scaife_id[id] = self.where(scaife_checker_id: id).first
        if @by_scaife_id[id].blank?
          raise ScaifeError.new("unknown checker scaife ID: #{id}")
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
