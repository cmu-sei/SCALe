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

require 'test_helper'

class ScaifeApiRegistrationTest < ActiveSupport::TestCase
	test "SCAIFE_register returns 201" do
		first = "John"
		last = "Doe"
		org = "SEI"
		user = "test_user"
		pass = "Test!abc123"
    body = "User Created"
		code = 201

		stub_and_test_register(first, last, org, user, pass, body, code)
	end

	test "SCAIFE_register returns 400 invalid credentials" do
		first = "John"
		last = "Doe"
		org = "SEI"
		user = "invalid_user"
		pass = "invalid_pass"
		body = "Invalid Username or Password"
		code = 400

		stub_and_test_register(first, last, org, user, pass, body, code)
	end

	test "SCAIFE_register returns 400 invalid request" do
		first = "John"
		last = "Doe"
		org = "SEI"
		user = "user"
		pass = "pass"
		body = "Invalid Request"
		code = 400

		stub_and_test_register(first, last, org, user, pass, body, code)
	end

	test "SCAIFE_login returns 200" do
		user = "valid_user"
		pass = "valid_pass"
		body = { x_access_token: "test-access-token" }.to_json
		code = 200

		stub_and_test_login(user, pass, body, code)
	end

	test "SCAIFE_login returns 400" do
		user = "invalid_user"
		pass = "invalid_pass"
		body = "Invalid Username or Password"
		code = 400

		stub_and_test_login(user, pass, body, code)
	end

	test "SCAIFE_login returns 405" do
		user = "valid_user"
		pass = "valid_pass"
		body = "Login Unavailable"
		code = 405

		stub_and_test_login(user, pass, body, code)
	end

	test "SCAIFE_get_access_token returns 200" do
		server = "prioritization"
		login_token = "valid_login_token"
		access_token = "access_token"
		body = { x_access_token: access_token }.to_json
		code = 200

		stub_and_test_get_access_token(server, login_token, body, code)
	end

	test "SCAIFE_get_access_token returns 400" do
		server = "invalid"
		login_token = "invalid_login_token"
		body = "Invalid Request"
		code = 400

		stub_and_test_get_access_token(server, login_token, body, code)
	end

	test "SCAIFE_get_access_token returns 405" do
		server = "datahub"
		login_token = "login_token"
		body = "Server Access Unavailable"
		code = 405

		stub_and_test_get_access_token(server, login_token, body, code)
	end
end
