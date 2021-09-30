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

class ScaifeApiPrioritizationTest < ActiveSupport::TestCase
  test "SCAIFE list_prioritizations returns 200" do
    x_access_token = "valid_access_token"
    p_id = 1
    body = {  }.to_json
    code = 200

    stub_and_test_list_prioritizations(x_access_token, p_id, body,
      code)
  end

  test "SCAIFE list_prioritizations returns 404" \
  "found" do
    x_access_token = "valid_access_token"
    p_id = 1
    body = "Prioritization Schemes Not Found"
    code = 404

    stub_and_test_list_prioritizations(x_access_token, p_id, body,
      code)
  end

  test "SCAIFE list_prioritizations returns 400" do
    x_access_token = "invalid_access_token"
    p_id = 1
    body = "Invalid Request"
    code = 400

    stub_and_test_list_prioritizations(x_access_token, p_id, body,
      code)
  end

  test "SCAIFE create_prioritization returns 200" do
    x_access_token = "valid_access_token"
    p_scheme_id = "5cbdfbdc5831220c6e15d5e5"
    pname = "priority scheme name"
    p_ids = ["1", "2"]
    formula = "formula"
    w_cols = { col: "col" }
    is_global = true
    is_remote = false
    body = {
      priority_scheme_id: p_scheme_id,
      priority_scheme_name: pname,
    }.to_json
    code = 200
    stub_and_test_create_prioritization(x_access_token,
            p_scheme_id, pname, p_ids, formula, w_cols, is_global,
            is_remote, body, code)
  end

  test "SCAIFE create_prioritization returns 400" \
  "scheme with that name already exists" do
    x_access_token = "valid_access_token"
    p_scheme_id = "5cbdfbdc5831220c6e15d5e5"
    pname = "duplicate priority scheme name"
    p_ids = ["1", "2"]
    formula = "formula"
    w_cols = { col: "col" }
    is_global = true
    is_remote = false
    body = "Cannot Save Prioritization Scheme"
    code = 400

    stub_and_test_create_prioritization(x_access_token,
            p_scheme_id, pname, p_ids, formula, w_cols, is_global,
            is_remote, body, code)
  end

  test "SCAIFE create_prioritization returns 401" \
  "global and remote flags are true" do
    x_access_token = "valid_access_token"
    p_scheme_id = "5cbdfbdc5831220c6e15d5e5"
    pname = "priority scheme name"
    p_ids = ["1", "2"]
    formula = "formula"
    w_cols = { col: "col" }
    is_global = true
    is_remote = true
    body = "Global and Remote Flags Cannot Both be True"
    code = 401

    stub_and_test_create_prioritization(x_access_token,
            p_scheme_id, pname, p_ids, formula, w_cols, is_global,
            is_remote, body, code)
  end

  test "SCAIFE create_prioritization returns 405" do
    x_access_token = "invalid_access_token"
    p_scheme_id = "5cbdfbdc5831220c6e15d5e5"
    pname = "priority scheme name"
    p_ids = ["1", "2"]
    formula = "formula"
    w_cols = { col: "col" }
    is_global = true
    is_remote = true
    body = "Cannot Create Prioritization Scheme"
    code = 405

    stub_and_test_create_prioritization(x_access_token,
            p_scheme_id, pname, p_ids, formula, w_cols, is_global,
            is_remote, body, code)
  end

  test "SCAIFE update_prioritization returns 200" do
    x_access_token = "valid_access_token"
    p_id = "5cbdfbdc5831220c6e15d5e5"
    pname = "priority scheme name"
    p_ids = ["3", "4"]
    formula = "updated formula"
    w_cols = { col: "new col" }
    body = nil
    code = 200

    stub_and_test_update_prioritization(x_access_token, p_id,
      pname, p_ids, formula, w_cols, body, code)
  end

  test "SCAIFE update_prioritization returns 400" do
    x_access_token = "invalid_access_token"
    p_id = "5cbdfbdc5831220c6e15d5e5"
    pname = "priority scheme name"
    p_ids = ["3", "4"]
    formula = "updated formula"
    w_cols = { col: "new col" }
    body = "Invalid Request"
    code = 400

    stub_and_test_update_prioritization(x_access_token, p_id,
      pname, p_ids, formula, w_cols, body, code)
  end

  test "SCAIFE update_prioritization returns 404" do
    x_access_token = "invalid_access_token"
    p_id = "5cbdfbdc5831220c6e15d5e5"
    pname = "priority scheme name"
    p_ids = ["3", "4"]
    formula = "updated formula"
    w_cols = { col: "new col" }
    body = "Prioritization Scheme Unavailable"
    code = 404

    stub_and_test_update_prioritization(x_access_token, p_id,
      pname, p_ids, formula, w_cols, body, code)
  end

  test "SCAIFE update_prioritization returns 405" do
    x_access_token = "invalid_access_token"
    p_id = "5cbdfbdc5831220c6e15d5e5"
    pname = "priority scheme name"
    p_ids = ["3", "4"]
    formula = "updated formula"
    w_cols = { col: "new col" }
    body = "Cannot Update Prioritization Scheme"
    code = 405

    stub_and_test_update_prioritization(x_access_token, p_id,
      pname, p_ids, formula, w_cols, body, code)
  end

  test "SCAIFE get_prioritization returns 200" do
    x_access_token = "valid_access_token"
    proj_id = '2'
    ps_id = "5cbdfbdc5831220c6e15d5e5"
    body = {
      priority_scheme_name: 'pname',
      formula: 'formula',
      weighted_columns: { col: 'col' },
      is_global: true,
      is_remote: false,
    }.to_json
    code = 200

    stub_and_test_get_prioritization(x_access_token, proj_id,
      ps_id, body, code)
  end

  test "SCAIFE get_prioritization returns 400" do
    x_access_token = "invalid_access_token"
    proj_id = '2'
    ps_id = "5cbdfbdc5831220c6e15d5e5"
    body = "Invalid Request"
    code = 400

    stub_and_test_get_prioritization(x_access_token, proj_id,
      ps_id, body, code)
  end

  test "SCAIFE get_prioritization returns 404" do
    x_access_token = "valid_access_token"
    proj_id = '2'
    ps_id = "invalid_ps_id"
    body = "Prioritization Scheme Unavailable"
    code = 404

    stub_and_test_get_prioritization(x_access_token, proj_id,
      ps_id, body, code)
  end

  test "SCAIFE delete_prioritization returns 200" do
    x_access_token = "valid_access_token"
    proj_id = '2'
    ps_id = "5cbdfbdc5831220c6e15d5e5"
    body = nil
    code = 200

    stub_and_test_delete_prioritization(x_access_token,
            proj_id, ps_id, body, code)
  end

  test "SCAIFE delete_prioritization returns 400" do
    x_access_token = "invalid_access_token"
    proj_id = '2'
    ps_id = "5cbdfbdc5831220c6e15d5e5"
    body = "Invalid Request"
    code = 400

    stub_and_test_delete_prioritization(x_access_token,
            proj_id, ps_id, body, code)
  end

  test "SCAIFE delete_prioritization returns 405" do
    x_access_token = "valid_access_token"
    proj_id = '2'
    ps_id = "5cbdfbdc5831220c6e15d5e5"
    body = "Cannot Delete Prioritization Scheme"
    code = 405

    stub_and_test_delete_prioritization(x_access_token,
            proj_id, ps_id, body, code)
  end
end
