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

class UserUploadValidator < ActiveModel::EachValidator

=begin
	validate the JSON from user upload

	params:
		record - instance of the record to validate
		attribute - the attribute to be validated
		value - the value of the attribute in the passed instance

=end
	def validate_each(record, attribute, value)
		if value.present?
			data = {}
			begin
				data = JSON.parse(value)
			rescue JSON::ParserError
				record.errors[attribute] << "invalid json"
			end

			if not data.empty?
				#check if any empty key value pairs
				data.each do |key, value|
					if key.empty?
						record.errors[attribute] << "empty key in data"
					end
					if value.empty?
						record.errors[attribute] << "empty value in data"
					end
				end
			end
		end
	end
end
