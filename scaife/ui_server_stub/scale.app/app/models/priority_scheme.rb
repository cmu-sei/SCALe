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

class PriorityScheme < ActiveRecord::Base
	include ActiveModel::Validations

	validates :name, uniqueness: true

	#TODO: validate presence of weighted_columns when it gets implemented
	validates :name, :project_id, :formula, :p_scheme_type, :weighted_columns,
	  :confidence, :created_at, :updated_at, :cert_severity, :cert_likelihood,
	  :cert_remediation, :cert_priority, :cert_level, :cwe_likelihood, presence: true

	validates :project_id, numericality: {
		only_integer: true,
		greater_than: 0,
	}

	validates :cert_severity, :cert_likelihood, :cert_remediation,
		:cert_priority, :cert_level, :cwe_likelihood,
		numericality: {
			only_integer: true,
			greater_than_or_equal_to: 0,
			less_than_or_equal_to: 10
		}

	validates :formula, formula_grouping: true

=begin
	creates a row in the table if the name is unique.

	params:
		pname (string) - name of the prioritization scheme
		p_id (int) - associated project id
		formula (string)
		w_cols (string) - weighted columns
		conf (decimal) - confidence
		cert_sev (int) - cert severity
		cert_like (int) - cert likelihood
		cert_rem (int) - cert remediation
		cert_pri (int) - cert priority
		cert_lvl (int) - cert level
		cwe_like (int) - cwe likelihood
	  scaife_id (hex 24-char string) - scaife priority scheme id

=end
	def self.createScheme(pname, p_id, formula, p_type, w_cols, conf, cert_sev,
		cert_like, cert_rem, cert_pri, cert_lvl, cwe_like, scaife_id=nil)
		ts = Time.now

		if not scaife_id.nil?
      ps = PriorityScheme.create(
        name: pname,
        project_id: p_id,
        formula: formula,
        p_scheme_type: p_type,
        weighted_columns: w_cols.to_json,
        confidence: conf,
        created_at: ts,
        updated_at: ts,
        cert_severity: cert_sev,
        cert_likelihood: cert_like,
        cert_remediation: cert_rem,
        cert_priority: cert_pri,
        cert_level: cert_lvl,
        cwe_likelihood: cwe_like,
        scaife_p_scheme_id: scaife_id
      )

		else
  		ps = PriorityScheme.create(
  			name: pname,
  			project_id: p_id,
  			formula: formula,
        p_scheme_type: p_type,
  			weighted_columns: w_cols.to_json,
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
		end

		if ps.valid?
			return true
		end

		return false
	end

	def self.editScheme(priority_id, pname, p_id, formula, w_cols, conf, cert_sev,
		cert_like, cert_rem, cert_pri, cert_lvl, cwe_like, scaife_id=nil)
		ts = Time.now
		ps = PriorityScheme.find_by(id: priority_id)

		if ps
			ps.project_id = p_id
			ps.formula = formula
			ps.weighted_columns = w_cols.to_json
			ps.confidence = conf
			ps.updated_at = ts
			ps.cert_severity = cert_sev
			ps.cert_likelihood = cert_like
			ps.cert_remediation = cert_rem
			ps.cert_priority = cert_pri
			ps.cert_level = cert_lvl
			ps.cwe_likelihood = cwe_like
			if not scaife_id.nil?
        ps.scaife_p_scheme_id = scaife_id
			end

			if ps.save
				return true
			end
		end

		return false
	end
end
