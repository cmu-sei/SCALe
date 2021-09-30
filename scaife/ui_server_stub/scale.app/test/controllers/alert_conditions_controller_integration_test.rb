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

class AlertConditionsControllerIntegrationTest < ActionDispatch::IntegrationTest
	test "changeSCAIFEMode connected not allowed" do
		request_change_scaife_mode("Connected")

		assert_equal 400, response.status
	end

	test "changeSCAIFEMode changes to demo" do
		request_change_scaife_mode("Demo")

		assert_response :success
	end

	test "changeSCAIFEMode changes to SCALe-only" do
		request_change_scaife_mode("SCALe-only")

		assert_response :success
	end

	test "AlertConditionsController index returns 200 for text/html accept header" do
		project = projects(:project_1)
		accept = "text/html"
		args = {}
		request_alert_controller_index(project.id, accept, args)
	end

	test "AlertConditionsController index returns 200 for js format" do
		project = projects(:project_1)
		accept = "text/javascript"
		args = {}
		request_alert_controller_index(project.id, accept, args)
	end

	test "fused redirects to index and sets session[:view]" do
		project_id = projects(:project_1).id
		view = "fused"
		request_fused_unfused_view(project_id, view)

		project = projects(:project_1)
		accept = "text/html"
		args = {}
		request_alert_controller_index(project.id, accept, args)
		assert_equal view, @controller.instance_variable_get(:@view)
	end

	test "unfused returns 200 and sets session[:view]" do
		project_id = projects(:project_1).id
		view = "unfused"
		request_fused_unfused_view(project_id, view)

		assert_equal view, @controller.instance_variable_get(:@view)
	end

	test "massUpdate returns 200 select all checkbox checked, all displayed "\
	"alertConditions updated" do
		project_id = 10
		view = "fused"
		verdict = "4"
		flag = "true"
		ignored = "true"
		dead = "true"
		ienv = "true"
		dc = "2"
		expected_verdict = 4
		expected_flag = 1
		expected_ignored = 1
		expected_dead = 1
		expected_ienv = 1
		expected_dc = 2
		mass_update_args = {select_all_checkbox: true}

		#filter by checkers
		accept = "text/javascript"
		checker = "test_checker"
		index_args = {
			checker: checker
		}

		verify_mass_update(project_id, view, verdict, flag, ignored, dead, ienv, dc,
			expected_verdict, expected_flag, expected_ignored, expected_dead,
			expected_ienv, expected_dc, mass_update_args, accept, checker, index_args)
	end

	test "massUpdate all checkbox unchecked unfused view all displayed"\
	" alertConditions updated" do
		project_id = 10
		view = "unfused"
		verdict = "4"
		flag = "false"
		ignored = "true"
		dead = "true"
		ienv = "true"
		dc = "2"
		expected_verdict = 4
		expected_flag = false
		expected_ignored = true
		expected_dead = true
		expected_ienv = true
		expected_dc = 2
		mass_update_args = {
			selectedAlertConditions: [
				displays(:massupdate_display_0).id,
				displays(:massupdate_display_1).id
			]
		}

		#filter by checkers
		accept = "text/javascript"
		checker = "test_checker"
		index_args = {
			checker: checker
		}

		verify_mass_update(project_id, view, verdict, flag, ignored, dead, ienv, dc,
			expected_verdict, expected_flag, expected_ignored, expected_dead,
			expected_ienv, expected_dc, mass_update_args, accept, checker, index_args)
	end

	test "massUpdate all checkbox unchecked fused view all displayed"\
	" alertConditions updated" do
		project_id = 10
		view = "fused"
		verdict = "3"
		flag = "true"
		ignored = "true"
		dead = "true"
		ienv = "true"
		dc = "2"
		expected_verdict = 3
		expected_flag = 1
		expected_ignored = 1
		expected_dead = 1
		expected_ienv = 1
		expected_dc = 2
		mass_update_args = {
			selectedAlertConditions: [1, 2]
		}

		#filter by checkers
		accept = "text/javascript"
		checker = "test_checker"
		index_args = {
			checker: checker
		}

		verify_mass_update(project_id, view, verdict, flag, ignored, dead, ienv, dc,
			expected_verdict, expected_flag, expected_ignored, expected_dead,
			expected_ienv, expected_dc, mass_update_args, accept, checker, index_args)
	end

end
