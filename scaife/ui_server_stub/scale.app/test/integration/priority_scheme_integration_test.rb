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

class PrioritySchemeIntegrationTest < ActionDispatch::IntegrationTest
  test "getPriorityModal returns 405 in SCALe-only scaife_mode" do
    mode = "SCALe-only"
    priority_id = 0
    project_id = 1
    status = 405

    request_getPriorityModal(mode, priority_id, project_id)

    assert_equal status, response.status
  end

  test "create/edit priority scheme stores all columns in demo scaife_mode" do
    @user_uploads = '{"complexity":7,"coupling":9,"impact":4,"residual_risk":3,"risk":6,"safeguard_countermeasure":1,"severity":8,"threat":5,"vulnerability":2}'
    cert_level = 5
    cert_likelihood = 5
    cert_priority = 5
    cert_remediation = 5
    cert_severity = 2
    complexity = 7
    confidence = 5
    coupling = 9
    cwe_likelihood = 1
    impact = 4
    residual_risk = 3
    risk = 6
    safeguard_countermeasure = 1
    severity = 8
    threat = 5
    vulnerability = 2
    pName = "test"
    mode = "Demo"

    request_change_scaife_mode(mode)
    post '/priorities/1/save', as: :json, params: {
      project_id: 1,
      priority_name: pName,
      formula: "IF_CWES(cwe_likelihood)+IF_CERT_RULES(safeguard_countermeasure)",
      save_type: "local",
      columns: {
        cert_level: cert_level,
        cert_likelihood: cert_likelihood,
        cert_priority: cert_priority,
        cert_remediation: cert_remediation,
        cert_severity: cert_severity,
        complexity: complexity,
        confidence: confidence,
        coupling: coupling,
        cwe_likelihood: cwe_likelihood,
        impact: impact,
        residual_risk: residual_risk,
        risk: risk,
        safeguard_countermeasure: safeguard_countermeasure,
        severity: severity,
        threat: threat,
        vulnerability: vulnerability
      }
    },
    headers: basic_auth

    assert_response :success
    ps = PriorityScheme.where(name: pName).take
    assert ps.valid?

    # validate columns in db
    assert_equal cert_level, ps.cert_level
    assert_equal  cert_likelihood, ps.cert_likelihood
    assert_equal cert_priority, ps.cert_priority
    assert_equal cert_remediation, ps.cert_remediation
    assert_equal cert_severity, ps.cert_severity
    assert_equal confidence, ps.confidence
    assert_equal cwe_likelihood, ps.cwe_likelihood
    assert_equal @user_uploads, ps.weighted_columns

    #test edit
    @user_uploads = '{"complexity":4,"coupling":2,"impact":8,"residual_risk":7,"risk":10,"safeguard_countermeasure":2,"severity":3,"threat":4,"vulnerability":5}'
    cert_level = 9
    cert_likelihood = 8
    cert_priority = 7
    cert_remediation = 6
    cert_severity = 5
    complexity = 4
    confidence = 3
    coupling = 2
    cwe_likelihood = 9
    impact = 8
    residual_risk = 7
    risk = 10
    safeguard_countermeasure = 2
    severity = 3
    threat = 4
    vulnerability = 5
    pName = "test"
    pId = ps.id

    post '/priorities/1/edit', as: :json, params: {
      project_id: 1,
      priority_name: pName,
      priority_id: pId,
      formula: "IF_CWES(cwe_likelihood)+IF_CERT_RULES(safeguard_countermeasure)",
      save_type: "local",
      columns: {
        cert_level: cert_level,
        cert_likelihood: cert_likelihood,
        cert_priority: cert_priority,
        cert_remediation: cert_remediation,
        cert_severity: cert_severity,
        complexity: complexity,
        confidence: confidence,
        coupling: coupling,
        cwe_likelihood: cwe_likelihood,
        impact: impact,
        residual_risk: residual_risk,
        risk: risk,
        safeguard_countermeasure: safeguard_countermeasure,
        severity: severity,
        threat: threat,
        vulnerability: vulnerability
      }
    },
    headers: basic_auth

    assert_response :success
    ps = PriorityScheme.where(name: pName).take
    assert ps.valid?

    # validate columns in db
    assert_equal cert_level, ps.cert_level
    assert_equal  cert_likelihood, ps.cert_likelihood
    assert_equal cert_priority, ps.cert_priority
    assert_equal cert_remediation, ps.cert_remediation
    assert_equal cert_severity, ps.cert_severity
    assert_equal confidence, ps.confidence
    assert_equal cwe_likelihood, ps.cwe_likelihood
    assert_equal @user_uploads, ps.weighted_columns
  end

    test "runPriority returns 405 in SCALe-only scaife_mode" do
        project_id = projects(:project_9).id
        pname = priority_schemes(:one).name
        formula = "IF_CWES(cwe_likelihood)+IF_CERT_RULES(safeguard_countermeasure)"
        cols = "cwe_likelihood|confidence|cert_severity|cert_likelihood|"\
        "cert_remediation|cert_priority|cert_level|confidence|"\
        "user_safeguard_countermeasure|user_vulnerability|user_residual_risk|"\
        "user_impact|user_threat|user_risk|user_complexity|user_severity|"\
        "user_coupling"
        accept = "text/html"
        mode = "SCALe-only"
        status = 405

        request_run_priority(mode, project_id, pname, formula, cols, accept)

        assert_equal status, response.status
    end

    test "runPriority redirects to project page for html format in Demo" \
    "scaife_mode" do
        project_id = projects(:project_9).id
        pname = priority_schemes(:one).name
        formula = "IF_CWES(cwe_likelihood)+IF_CERT_RULES(safeguard_countermeasure)"
        cols = "cwe_likelihood|confidence|cert_severity|cert_likelihood|"\
        "cert_remediation|cert_priority|cert_level|confidence|"\
        "user_safeguard_countermeasure|user_vulnerability|user_residual_risk|"\
        "user_impact|user_threat|user_risk|user_complexity|user_severity|"\
        "user_coupling"
        accept = "text/html"
        mode = "Demo"

        request_run_priority(mode, project_id, pname, formula, cols, accept)

        assert_redirected_to "/projects/#{project_id}"
    end

    test "runPriority returns json object for json format and updates"\
    "Project.last_used_priority_scheme in Demo scaife_mode" do
        project = projects(:project_9)
        ps = priority_schemes(:run)
        formula = "IF_CWES(cwe_likelihood)+IF_CERT_RULES(safeguard_countermeasure)"
        cols = "cwe_likelihood|confidence|cert_severity|cert_likelihood|"\
        "cert_remediation|cert_priority|cert_level|confidence|"\
        "user_safeguard_countermeasure|user_vulnerability|user_residual_risk|"\
        "user_impact|user_threat|user_risk|user_complexity|user_severity|"\
        "user_coupling"
        accept = "application/json"
        mode = "Demo"

        request_run_priority(mode, project.id, ps.name , formula, cols, accept)

        assert_response :success
        assert_equal "", response.body
        assert_equal ps.id , Project.find(9).last_used_priority_scheme
        assert_equal ps.name, controller.instance_variable_get(:@priority)
    end

    test "createPriority returns 405 in SCALe-only scaife_mode" do
        pname =  "abctest123"
        project_id = 1
        formula = "IF_CWES(cwe_likelihood+safeguard_countermeasure)+IF_CERT_RULES(cert_likelihood)"
        save_type = "local"
        cols = {
            cwe_likelihood: "1",
            confidence: "0",
            cert_severity: "0",
            cert_likelihood: "1",
            cert_remediation: "0",
            cert_priority: "0",
            cert_level: "0",
            safeguard_countermeasure: "1",
            vulnerability: "0",
            residual_risk: "0",
            impact: "0",
            threat: "0",
            risk: "0",
            complexity: "0",
            severity: "0",
            coupling: "0"
        }
        status = 405
        mode = "SCALe-only"

        request_create_priority(mode, pname, project_id, save_type, formula, cols, status)
    end

    test "createPriority returns 200 on success in Demo scaife_mode" do
        pname =  "abctest123"
        project_id = 1
        formula = "IF_CWES(cwe_likelihood+safeguard_countermeasure)+IF_CERT_RULES(cert_likelihood)"
        save_type = "local"
        cols = {
            cwe_likelihood: "1",
            confidence: "0",
            cert_severity: "0",
            cert_likelihood: "1",
            cert_remediation: "0",
            cert_priority: "0",
            cert_level: "0",
            safeguard_countermeasure: "1",
            vulnerability: "0",
            residual_risk: "0",
            impact: "0",
            threat: "0",
            risk: "0",
            complexity: "0",
            severity: "0",
            coupling: "0"
        }
        status = 200
        mode = "Demo"

        request_create_priority(mode, pname, project_id, save_type, formula, cols, status)
    end

    test "createPriority returns 400 on bad request in Demo scaife_mode" do
        pname =  "abctest123"
        project_id = 1
        formula = "IF_CWES(cwe_likelihood+safeguard_countermeasure)+IF_CERT_RULES(cert_likelihood)"
        save_type = "local"
        cols = {
        }
        status = 400
        mode = "Demo"

        request_create_priority(mode, pname, project_id, save_type, formula, cols, status)
    end

    test "editPriority returns 405 in SCALe-only scaife_mode" do
        pname =  "edit"
        ps = PriorityScheme.where(name: pname).take

        priority_id = ps.id
        project_id = 1
        formula = "IF_CWES(cwe_likelihood+safeguard_countermeasure)+IF_CERT_RULES(cert_likelihood)"
        save_type = "local"
        cols = {
            cwe_likelihood: "1",
            confidence: "0",
            cert_severity: "0",
            cert_likelihood: "1",
            cert_remediation: "0",
            cert_priority: "0",
            cert_level: "0",
            safeguard_countermeasure: "1",
            vulnerability: "0",
            residual_risk: "0",
            impact: "0",
            threat: "0",
            risk: "0",
            complexity: "0",
            severity: "0",
            coupling: "0"
        }
        status = 405
        mode = "SCALe-only"

        request_edit_priority(mode, pname, priority_id, project_id, save_type, formula, cols, status)
    end

    test "editPriority returns 200 on success in Demo scaife_mode" do
        pname =  "edit"
        ps = PriorityScheme.where(name: pname).take

        priority_id = ps.id
        project_id = 1
        formula = "IF_CWES(cwe_likelihood+safeguard_countermeasure)+IF_CERT_RULES(cert_likelihood)"
        save_type = "local"
        cols = {
            cwe_likelihood: "1",
            confidence: "0",
            cert_severity: "0",
            cert_likelihood: "1",
            cert_remediation: "0",
            cert_priority: "0",
            cert_level: "0",
            safeguard_countermeasure: "1",
            vulnerability: "0",
            residual_risk: "0",
            impact: "0",
            threat: "0",
            risk: "0",
            complexity: "0",
            severity: "0",
            coupling: "0"
        }
        status = 200
        mode = "Demo"

        request_edit_priority(mode, pname, priority_id, project_id, save_type, formula, cols, status)
    end

    test "editPriority returns 400 on bad request in Demo scaife_mode" do
        pname =  "doesntexist"
        ps = PriorityScheme.where(name: pname).take

        assert_nil(ps) #assert the priority scheme does not exist

        priority_id = -1
        project_id = 1
        formula = "IF_CWES(cwe_likelihood+safeguard_countermeasure)+IF_CERT_RULES(cert_likelihood)"
        save_type = "local"
        cols = {
            cwe_likelihood: "1",
            confidence: "0",
            cert_severity: "0",
            cert_likelihood: "1",
            cert_remediation: "0",
            cert_priority: "0",
            cert_level: "0",
            safeguard_countermeasure: "1",
            vulnerability: "0",
            residual_risk: "0",
            impact: "0",
            threat: "0",
            risk: "0",
            complexity: "0",
            severity: "0",
            coupling: "0"
        }
        status = 400
        mode = "Demo"

        request_edit_priority(mode, pname, priority_id, project_id, save_type, formula, cols, status)
    end

    test "deletePriority returns 405 in SCALe-only scaife_mode" do
        pname = "delete"
        ps = PriorityScheme.where(name: pname).take

        project_id = 1
        priority_id = ps.id,
        status = 405
        mode = "SCALe-only"

        request_delete_priority(mode, pname, project_id, priority_id, status)
    end

    test "deletePriority returns 200 on success in Demo scaife_mode" do
        pname = "delete"
        ps = PriorityScheme.where(name: pname).take

        project_id = 1
        priority_id = ps.id
        status = 200
        mode = "Demo"

        request_delete_priority(mode, pname, project_id, priority_id, status)
    end
end
