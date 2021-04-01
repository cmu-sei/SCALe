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

require 'test_helper'

class ScaifeRegistrationControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "getLoginModal" do
  	headers = basic_auth
  	headers["Accept"] = "text/javascript"
  	get '/scaife-registration/login', as: :json, headers: headers, xhr: true

  	assert_response :success
  end

  test "getRegisterModal" do
  	headers = basic_auth
  	headers["Accept"] = "text/javascript"
  	get '/scaife-registration/register', as: :json, headers: headers, xhr: true

  	assert_response :success
  end

  test "submitRegister register successful and login successful" do
  	first = "first"
  	last = "last"
  	org = "org"
  	user = "user"
  	pass = "pass"
  	reg_code = 201
  	login_code = 200
  	reg_body = "User Created"
  	login_body = { x_access_token: "test-access-token" }.to_json
  	expected_login_token = "test-access-token"
  	expected_scaife_mode = "Connected"

		stub_and_test_submitRegister(first, last, org, user, pass, reg_code,
			login_code, reg_body, login_body, expected_login_token,
			expected_scaife_mode)
  end

  test "submitRegister register successful and login fail" do
  	first = "first"
  	last = "last"
  	org = "org"
  	user = "user"
  	pass = "pass"
  	reg_code = 201
  	login_code = 400
  	reg_body = "User Created"
  	login_body = "Invalid Request"
  	expected_login_token = nil
  	expected_scaife_mode = nil

		stub_and_test_submitRegister(first, last, org, user, pass, reg_code,
			login_code, reg_body, login_body, expected_login_token,
			expected_scaife_mode)
	end

  test "submitRegister register fail" do
  	first = "first"
  	last = "last"
  	org = "org"
  	user = "user"
  	pass = "pass"
  	reg_code = 400
  	login_code = nil
  	reg_body = "Invalid Request"
  	login_body = nil
  	expected_login_token = nil
  	expected_scaife_mode = nil

		stub_and_test_submitRegister(first, last, org, user, pass, reg_code,
			login_code, reg_body, login_body, expected_login_token,
			expected_scaife_mode)
  end

  test "submitRegister blank fields" do
  	first = ""
  	last = ""
  	org = ""
  	user = ""
  	pass = ""
  	reg_code = nil
  	login_code = nil
  	reg_body = "Please populate all of the fields"
  	login_body = nil
  	expected_login_token = nil
  	expected_scaife_mode = nil

		stub_and_test_submitRegister(first, last, org, user, pass, reg_code,
			login_code, reg_body, login_body, expected_login_token,
			expected_scaife_mode)
  end

  test "submitRegister missing field" do
  	first = "first"
  	last = "last"
  	org = "org"
  	user = "user"
  	pass = ""
  	reg_code = nil
  	login_code = nil
  	reg_body = "Please populate all of the fields"
  	login_body = nil
  	expected_login_token = nil
  	expected_scaife_mode = nil

		stub_and_test_submitRegister(first, last, org, user, pass, reg_code,
			login_code, reg_body, login_body, expected_login_token,
			expected_scaife_mode)
  end

  test "submitLogin success" do
  	user = "user"
  	pass = "pass"
  	code = 200
  	body = { x_access_token: "test-access-token" }.to_json
  	response_msg = nil
  	expected_login_token = "test-access-token"
  	expected_scaife_mode = "Connected"

  	stub_and_test_submitLogin(user, pass, code, body, expected_login_token,
  		expected_scaife_mode)

  end

  test "submitLogin fail" do
  	user = "user"
  	pass = "pass"
  	code = 400
  	body = "Invalid Username or Password"
  	response_msg = body
  	expected_login_token = nil
  	expected_scaife_mode = nil

  	stub_and_test_submitLogin(user, pass, code, body, expected_login_token,
  		expected_scaife_mode)
  end

  test "submitLogin blank fields" do
  	user = ""
  	pass = ""
  	code = nil
  	body = nil
  	response_msg = "Invalid User or Password"
  	expected_login_token = nil
  	expected_scaife_mode = nil

  	stub_and_test_submitLogin(user, pass, code, body, expected_login_token,
  		expected_scaife_mode)
  end

  test "submitLogin user blank" do
  	user = ""
  	pass = "pass"
  	code = nil
  	body = nil
  	response_msg = "Invalid User or Password"
  	expected_login_token = nil
  	expected_scaife_mode = nil

  	stub_and_test_submitLogin(user, pass, code, body, expected_login_token,
  		expected_scaife_mode)
  end

  test "submitLogin password blank" do
  	user = "user"
  	pass = ""
  	code = nil
  	body = nil
  	response_msg = "Invalid User or Password"
  	expected_login_token = nil
  	expected_scaife_mode = nil

  	stub_and_test_submitLogin(user, pass, code, body, expected_login_token,
  		expected_scaife_mode)
  end
end
