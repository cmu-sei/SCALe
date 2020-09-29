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

require 'test_helper'

class UserUploadTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "createUserUpload overwrites the UserUpload table" do
  	user_columns = JSON.parse('{
			"1": {
				"safeguard_countermeasure": "5",
				"vulnerability": "1",
				"residual_risk": "4",
				"impact": "9",
				"threat": "1",
				"risk": "1",
				"complexity": "5",
				"severity": "5",
				"coupling": "1"
			},
			"2": {
				"safeguard_countermeasure": "9",
				"vulnerability": "3",
				"residual_risk": "3",
				"impact": "3",
				"threat": "1",
				"risk": "1",
				"complexity": "1",
				"severity": "9",
				"coupling": "3"
			},
			"3": {
				"safeguard_countermeasure": "3",
				"vulnerability": "1",
				"residual_risk": "1",
				"impact": "1",
				"threat": "8",
				"risk": "1",
				"complexity": "5",
				"severity": "5",
				"coupling": "1"
			}
		}')
  	success = UserUpload.createUserUpload(user_columns)

  	assert success
  	assert_equal(user_columns.keys.length, UserUpload.count)
  	assert UserUpload.exists?(
  		meta_alert_id: 3,
  		user_columns: {
				"safeguard_countermeasure": "3",
				"vulnerability": "1",
				"residual_risk": "1",
				"impact": "1",
				"threat": "8",
				"risk": "1",
				"complexity": "5",
				"severity": "5",
				"coupling": "1"
			}.to_json
  	)
  end

=begin
  	Test validators
=end
	test "validates presence of meta_alert_id and user_columns" do
		u = UserUpload.new
		assert_not u.valid?
		assert_equal [:meta_alert_id, :user_columns], u.errors.keys
	end

	test "validates user_columns JSON data invalid JSON" do
	 user_columns = '{
			"safeguard_countermeasure": "3",
			"vulnerability": "1",
			"residual_risk": "1",
			"impact": "1",
			"threat": "8",
			"risk": "1",
			"complexity": "5",
			"severity": "5",
			"coupling": "1"'

		u = UserUpload.create(meta_alert_id: 1, user_columns: user_columns)

		assert_not u.valid?
		assert_equal [:user_columns], u.errors.keys
		assert_equal ["invalid json"],
            u.errors.messages[:user_columns]
	end

	test "validates user_columns JSON data empty key" do
		user_columns = '{
				"safeguard_countermeasure": "3",
				"vulnerability": "1",
				"residual_risk": "1",
				"impact": "1",
				"threat": "8",
				"risk": "1",
				"complexity": "5",
				"severity": "5",
				"": "1"
			}'

		u = UserUpload.create(meta_alert_id: 1, user_columns: user_columns)

		assert_not u.valid?
		assert_equal [:user_columns], u.errors.keys
		assert_equal ["empty key in data"],
            u.errors.messages[:user_columns]
	end

	test "validates user_columns JSON data empty value" do
				user_columns = '{
				"safeguard_countermeasure": "3",
				"vulnerability": "1",
				"residual_risk": "1",
				"impact": "1",
				"threat": "8",
				"risk": "1",
				"complexity": "5",
				"severity": "",
				"coupling": "1"
			}'

		u = UserUpload.create(meta_alert_id: 1, user_columns: user_columns)

		assert_not u.valid?
		assert_equal [:user_columns], u.errors.keys
		assert_equal ["empty value in data"],
            u.errors.messages[:user_columns]
	end
end