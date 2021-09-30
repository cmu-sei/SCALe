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

class CreateDisplays < ActiveRecord::Migration[4.2]
  def change
    create_table :displays do |t|
      t.boolean     :flag
      t.integer     :verdict
      t.integer     :previous
      t.string      :path
      t.integer     :line
      t.string      :link
      t.string      :message
      t.string      :checker
      t.string      :tool
      t.string      :rule
      t.string      :title
      t.integer     :severity
      t.integer     :likelihood
      t.integer     :remediation
      t.integer     :priority
      t.integer     :level
      t.string      :cwe_likelihood
      t.string      :notes
      t.boolean     :ignored
      t.boolean     :dead
      t.boolean     :inapplicable_environment
      t.integer     :dangerous_construct
      t.decimal     :confidence
      t.integer     :alert_priority
      t.datetime    :time
    end
  end
end
