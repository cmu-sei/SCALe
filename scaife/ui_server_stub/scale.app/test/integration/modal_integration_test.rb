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

class ModalIntegrationTest < ActionDispatch::IntegrationTest
	test "getModals classifiers returns 405 in SCALe-only scaife_mode" do
		project_id = 1
		className = "classifiers"
		chosen = "chosen"
		mode = "SCALe-only"
		status = 405

    request_getModals(mode, project_id, className, chosen)

		assert_equal status, response.status
	end

	test "getModals classifiers renders correct template in Demo scaife_mode" do
		project_id = 1
		className = "classifiers"
		chosen = "chosen"
		mode = "Demo"

		request_getModals(mode, project_id, className, chosen)

		assert_template partial: 'classifier_schemes/_classifier.html.erb'
	end
end
