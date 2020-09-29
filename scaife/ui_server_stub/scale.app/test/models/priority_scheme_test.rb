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

class PrioritySchemeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

=begin

   Test createScheme

=end
    test "createScheme inserts a row in the table if row with that name
    doesn't already exist" do
        pname = "pname"
        p_id = 1
        formula = "formula"
        priority_type = "local"
        w_cols = JSON.parse('{
            "complexity":7,
            "coupling":9,
            "impact":4,
            "residual_risk":3,
            "risk":6,
            "safeguard_countermeasure":1,
            "severity":8,
            "threat":5,
            "vulnerability":2
        }')
        conf = 1.0
        cert_sev = 2
        cert_like = 3
        cert_rem = 4
        cert_pri = 5
        cert_lvl = 6
        cwe_like = 7
        count = PriorityScheme.count
        PriorityScheme.createScheme(pname, p_id, formula, priority_type, w_cols, conf, cert_sev,
            cert_like, cert_rem, cert_pri, cert_lvl, cwe_like)

        assert_equal(count + 1, PriorityScheme.count)
        assert PriorityScheme.exists?(
            name: pname,
            project_id: p_id,
            formula: formula,
            weighted_columns: {
            "complexity":7,
            "coupling":9,
            "impact":4,
            "residual_risk":3,
            "risk":6,
            "safeguard_countermeasure":1,
            "severity":8,
            "threat":5,
            "vulnerability":2
            }.to_json,
            confidence: conf,
            cert_severity: cert_sev,
            cert_likelihood: cert_like,
            cert_remediation: cert_rem,
            cert_priority: cert_pri,
            cert_level: cert_lvl,
            cwe_likelihood: cwe_like
        )
    end

    test "createScheme doesn't insert a row in the table if a row with that name
    already exists" do
        pname = "MyString"
        p_id = 0
        formula = "0"
        priority_type = "local"
        w_cols = JSON.parse('{
            "complexity":7,
            "coupling":9,
            "impact":4,
            "residual_risk":3,
            "risk":6,
            "safeguard_countermeasure":1,
            "severity":8,
            "threat":5,
            "vulnerability":2
        }')
        conf = 0.0
        cert_sev = 1
        cert_like = 1
        cert_rem = 1
        cert_pri = 1
        cert_lvl = 1
        cwe_like = 1
        PriorityScheme.createScheme(pname, p_id, formula, priority_type, w_cols, conf, cert_sev,
            cert_like, cert_rem, cert_pri, cert_lvl, cwe_like)

        count = PriorityScheme.count

        PriorityScheme.createScheme(pname, p_id, formula, priority_type, w_cols, conf, cert_sev,
                  cert_like, cert_rem, cert_pri, cert_lvl, cwe_like)

        assert_equal(count, PriorityScheme.count)
        assert PriorityScheme.exists?(
            name: pname
        )
    end

=begin

    Test editScheme

=end
    test "editScheme should edit existing record" do

        pname = "MyString"
        p_id = 2
        formula = "1"
        w_cols = JSON.parse('{
            "complexity":8,
            "coupling":7,
            "impact":5,
            "residual_risk":2,
            "risk":1,
            "safeguard_countermeasure":3,
            "severity":4,
            "threat":2,
            "vulnerability":1
        }')
        conf = 1
        cert_sev = 4
        cert_like = 5
        cert_rem = 6
        cert_pri = 7
        cert_lvl = 8
        cwe_like = 9

        ps_id = PriorityScheme.find_by(name: pname).id

        count = PriorityScheme.count
        PriorityScheme.editScheme(ps_id, pname, p_id, formula, w_cols, conf, cert_sev,
            cert_like, cert_rem, cert_pri, cert_lvl, cwe_like)

        assert_equal(count, PriorityScheme.count)
        assert PriorityScheme.exists?(
            name: pname,
            project_id: p_id,
            formula: formula,
            p_scheme_type: "local",
            weighted_columns: {
            "complexity":8,
            "coupling":7,
            "impact":5,
            "residual_risk":2,
            "risk":1,
            "safeguard_countermeasure":3,
            "severity":4,
            "threat":2,
            "vulnerability":1
            }.to_json,
            confidence: conf,
            cert_severity: cert_sev,
            cert_likelihood: cert_like,
            cert_remediation: cert_rem,
            cert_priority: cert_pri,
            cert_level: cert_lvl,
            cwe_likelihood: cwe_like
        )
    end

=begin

    Test validation

=end
    test "should have necessary required validators" do
        ps = PriorityScheme.new

        assert_not ps.valid?
        assert_equal [:name, :project_id, :formula, :p_scheme_type, :weighted_columns,
            :confidence, :created_at, :updated_at, :cert_severity, :cert_likelihood,
            :cert_remediation, :cert_priority, :cert_level, :cwe_likelihood], ps.errors.keys
    end

    test "validates numericality of int columns" do
        pname = "numericality"
        p_id = 1
        formula = "formula"
        w_cols = JSON.parse('{
            "complexity":8,
            "coupling":7,
            "impact":5,
            "residual_risk":2,
            "risk":1,
            "safeguard_countermeasure":3,
            "severity":4,
            "threat":2,
            "vulnerability":1
        }'),
        conf = 1.0
        cert_sev = 'a'
        cert_like = 'a'
        cert_rem = 'a'
        cert_pri = 'a'
        cert_lvl = 'a'
        cwe_like = 'a'
        ts = Time.now
        ps = PriorityScheme.new(
            name: pname,
            project_id: p_id,
            formula: formula,
            p_scheme_type: "local",
            weighted_columns: {
            "complexity":8,
            "coupling":7,
            "impact":5,
            "residual_risk":2,
            "risk":1,
            "safeguard_countermeasure":3,
            "severity":4,
            "threat":2,
            "vulnerability":1
            }.to_json,
            confidence: conf,
            created_at: ts,
            updated_at: ts,
            cert_severity: cert_sev,
            cert_likelihood: cert_like,
            cert_remediation: cert_rem,
            cert_priority: cert_pri,
            cert_level: cert_lvl,
            cwe_likelihood: cwe_like
        )

        assert_not ps.valid?
        assert_equal [:cert_severity, :cert_likelihood, :cert_remediation,
            :cert_priority, :cert_level, :cwe_likelihood], ps.errors.keys
    end

    test "validates constraints of int columns" do
        pname = "intconstraints"
        p_id = 1
        formula = "formula"
        w_cols = JSON.parse('{
            "complexity":8,
            "coupling":7,
            "impact":5,
            "residual_risk":2,
            "risk":1,
            "safeguard_countermeasure":3,
            "severity":4,
            "threat":2,
            "vulnerability":1
        }'),
        conf = 1.0
        cert_sev = 11
        cert_like = 11
        cert_rem = 11
        cert_pri = -1
        cert_lvl = 10
        cwe_like = 0
        ts = Time.now
        ps = PriorityScheme.new(
            name: pname,
            project_id: p_id,
            formula: formula,
            p_scheme_type: "local",
            weighted_columns: {
            "complexity":8,
            "coupling":7,
            "impact":5,
            "residual_risk":2,
            "risk":1,
            "safeguard_countermeasure":3,
            "severity":4,
            "threat":2,
            "vulnerability":1
            }.to_json,
            confidence: conf,
            created_at: ts,
            updated_at: ts,
            cert_severity: cert_sev,
            cert_likelihood: cert_like,
            cert_remediation: cert_rem,
            cert_priority: cert_pri,
            cert_level: cert_lvl,
            cwe_likelihood: cwe_like
        )

        assert_not ps.valid?
        assert_equal [:cert_severity, :cert_likelihood, :cert_remediation,
            :cert_priority], ps.errors.keys
    end

    test "validates project_id numericality" do
        ps = PriorityScheme.find_by name: "ProjectId"

        assert ps.valid?

        ps.project_id = 0
        assert_not ps.valid?

        ps.project_id = "hi"
        assert_not ps.valid?

        ps.project_id = 100
        assert ps.valid?
    end

=begin
    Test custom Validators
=end
    test "validates formula parentheses grouping, no errors for valid
    grouping" do
        pname = "parens"
        p_id = 1
        formula = "()"
        w_cols = JSON.parse('{
            "complexity":8,
            "coupling":7,
            "impact":5,
            "residual_risk":2,
            "risk":1,
            "safeguard_countermeasure":3,
            "severity":4,
            "threat":2,
            "vulnerability":1
        }'),
        conf = 1.0
        cert_sev = 10
        cert_like = 10
        cert_rem = 10
        cert_pri = 1
        cert_lvl = 10
        cwe_like = 1
        ts = Time.now
        ps = PriorityScheme.new(
            name: pname,
            project_id: p_id,
            formula: formula,
            p_scheme_type: "local",
            weighted_columns: {
            "complexity":8,
            "coupling":7,
            "impact":5,
            "residual_risk":2,
            "risk":1,
            "safeguard_countermeasure":3,
            "severity":4,
            "threat":2,
            "vulnerability":1
            }.to_json,
            confidence: conf,
            created_at: ts,
            updated_at: ts,
            cert_severity: cert_sev,
            cert_likelihood: cert_like,
            cert_remediation: cert_rem,
            cert_priority: cert_pri,
            cert_level: cert_lvl,
            cwe_likelihood: cwe_like
        )

        assert ps.valid?
        assert_equal [], ps.errors.keys

    end

    test "validates formula parentheses grouping, error for missing close
    paren" do
        pname = "parens2"
        p_id = 1
        formula = "(()"
        w_cols = JSON.parse('{
            "complexity":8,
            "coupling":7,
            "impact":5,
            "residual_risk":2,
            "risk":1,
            "safeguard_countermeasure":3,
            "severity":4,
            "threat":2,
            "vulnerability":1
        }'),
        conf = 1.0
        cert_sev = 10
        cert_like = 10
        cert_rem = 10
        cert_pri = 1
        cert_lvl = 10
        cwe_like = 1
        ts = Time.now
        count = PriorityScheme.count
        ps = PriorityScheme.create(
            name: pname,
            project_id: p_id,
            formula: formula,
            p_scheme_type: "local",
            weighted_columns: {
            "complexity":8,
            "coupling":7,
            "impact":5,
            "residual_risk":2,
            "risk":1,
            "safeguard_countermeasure":3,
            "severity":4,
            "threat":2,
            "vulnerability":1
            }.to_json,
            confidence: conf,
            created_at: ts,
            updated_at: ts,
            cert_severity: cert_sev,
            cert_likelihood: cert_like,
            cert_remediation: cert_rem,
            cert_priority: cert_pri,
            cert_level: cert_lvl,
            cwe_likelihood: cwe_like
        )

        assert_not ps.valid?
        assert_equal(count, PriorityScheme.count)
        assert_equal [:formula], ps.errors.keys
        assert_equal ["1 or more missing closing parentheses"],
            ps.errors.messages[:formula]
    end

    test "validates formula parentheses grouping, error for missing open
    paren" do
        pname = "parens3"
        p_id = 1
        formula = "(()))"
        w_cols = JSON.parse('{
            "complexity":8,
            "coupling":7,
            "impact":5,
            "residual_risk":2,
            "risk":1,
            "safeguard_countermeasure":3,
            "severity":4,
            "threat":2,
            "vulnerability":1
        }'),
        conf = 1.0
        cert_sev = 10
        cert_like = 10
        cert_rem = 10
        cert_pri = 1
        cert_lvl = 10
        cwe_like = 1
        ts = Time.now
        count = PriorityScheme.count
        ps = PriorityScheme.create(
            name: pname,
            project_id: p_id,
            formula: formula,
            p_scheme_type: "local",
            weighted_columns: {
            "complexity":8,
            "coupling":7,
            "impact":5,
            "residual_risk":2,
            "risk":1,
            "safeguard_countermeasure":3,
            "severity":4,
            "threat":2,
            "vulnerability":1
            }.to_json,
            confidence: conf,
            created_at: ts,
            updated_at: ts,
            cert_severity: cert_sev,
            cert_likelihood: cert_like,
            cert_remediation: cert_rem,
            cert_priority: cert_pri,
            cert_level: cert_lvl,
            cwe_likelihood: cwe_like
        )

        assert_not ps.valid?
        assert_equal(count, PriorityScheme.count)
        assert_equal [:formula], ps.errors.keys
        assert_equal ["closing parenthesis without opening parenthesis"],
            ps.errors.messages[:formula]
    end

=begin
    test "validates column values used in formula valid" do
        pname = "colvalnumericality"
        p_id = 1
        formula = "(cert_severity + cert_likelihood)"
        w_cols = "w_cols"
        conf = 1.0
        cert_sev = 10
        cert_like = 10
        cert_rem = 0
        cert_pri = 1
        cert_lvl = 10
        cwe_like = 1
        ts = Time.now
        count = PriorityScheme.count
        ps = PriorityScheme.create(
            name: pname,
            project_id: p_id,
            formula: formula,
            p_scheme_type: "local",
            weighted_columns: w_cols,
            confidence: conf,
            created_at: ts,
            updated_at: ts,
            cert_severity: cert_sev,
            cert_likelihood: cert_like,
            cert_remediation: cert_rem,
            cert_priority: cert_pri,
            cert_level: cert_lvl,
            cwe_likelihood: cwe_like
        )

        assert ps.valid?
        assert_equal(count + 1, PriorityScheme.count)
        assert_equal [], ps.errors.keys
    end

    test "validates column values used in formula invalid" do
        pname = "colvalnumericality2"
        p_id = 1
        formula = "(cert_severity + cert_likelihood)"
        w_cols = "w_cols"
        conf = 1.0
        cert_sev = 10
        cert_like = 0
        cert_rem = 0
        cert_pri = 1
        cert_lvl = 10
        cwe_like = 1
        ts = Time.now
        count = PriorityScheme.count
        ps = PriorityScheme.create(
            name: pname,
            project_id: p_id,
            formula: formula,
            weighted_columns: w_cols,
            confidence: conf,
            created_at: ts,
            updated_at: ts,
            cert_severity: cert_sev,
            cert_likelihood: cert_like,
            cert_remediation: cert_rem,
            cert_priority: cert_pri,
            cert_level: cert_lvl,
            cwe_likelihood: cwe_like
        )

        assert_not ps.valid?
        assert_equal(count , PriorityScheme.count)
        assert_equal [:cert_likelihood], ps.errors.keys
        assert_equal ["column values used in the formula must be greater than zero"],
            ps.errors.messages[:cert_likelihood]
    end
=end
end
