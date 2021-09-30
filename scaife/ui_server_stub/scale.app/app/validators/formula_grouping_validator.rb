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

class FormulaGroupingValidator < ActiveModel::EachValidator

=begin
	Ensure the number of parenthesis match

	params:
		record - instance
		attribute - attribute being validated. expects :formula
		val - value of the attribute in the passed instance

=end
	def validate_each(record, attribute, val)
		pStack = []
		if val.present?
			for i in 0..val.length
				if val[i] == "("
					pStack << "E"

				elsif val[i] == ")"
					if pStack.empty? #fail if trying to pop without an open parenthesis
						record.errors[attribute] << "closing parenthesis without opening parenthesis"
					end

					pStack.pop
				end
			end

			if not pStack.empty?
				record.errors[attribute] << "1 or more missing closing parentheses"
			end
		end
	end
end
