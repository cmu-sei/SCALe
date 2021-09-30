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

module Utility
module Db
=begin

	db utility functions

=end

=begin

	switch the db connection

	params:
		type (bool) - is the target_db an external db
			options:
				false - use Rails db for current env
				true - use external db, required target_db
		target_db (str) - path of the db to connect to if is_ext is true


	returns:
		connection object for the target_db if is_ext is true
		nothing if is_ext is false

	Usage:
	connect to external db: "ext_con = switch_db_con(true, ext_db_path)"
	connect back to rails db: "switch_db_con(false)"

=end
	def switch_db_con(is_ext, target_db = nil, is_prod = false)
                if is_ext and is_prod
                    ActiveRecord::Base.remove_connection
                    ActiveRecord::Base.establish_connection :external
                    return ActiveRecord::Base.connection()

		elsif is_ext and not is_prod
                        ActiveRecord::Base.remove_connection
			ActiveRecord::Base.establish_connection(
				adapter: Rails.configuration.x.db_adapter,
				database: target_db
			)

			return ActiveRecord::Base.connection()
		else
			ActiveRecord::Base.remove_connection
			ActiveRecord::Base.establish_connection(Rails.env.to_sym)
		end
	end

end
end
