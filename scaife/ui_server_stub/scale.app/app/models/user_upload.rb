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

class UserUpload < ApplicationRecord
require 'json'

	validates :meta_alert_id, :user_columns, presence: true

	validates :user_columns, user_upload: true

=begin
	store custom user columns. Always overwrites existing rows in the table

	params:
		user_columns (hash) -
			{meta_alert_id => {column => value, column => value...}, ...}

=end
	def self.createUserUpload(user_columns)
		UserUpload.destroy_all
		user_columns.each do |meta_alert_id, custom_columns|
			columns_hash = {}

			custom_columns.each do |classifier_instance_name, value|
				columns_hash[classifier_instance_name] = value
			end

			u = UserUpload.create(meta_alert_id: meta_alert_id,
				user_columns: columns_hash.to_json)

			if not u.valid?
				return false
			end
		end
		return true
	end
end
