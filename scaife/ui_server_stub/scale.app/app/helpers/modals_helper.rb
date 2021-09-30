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

module ModalsHelper
=begin
	get all of the column values for priority scheme

	args:
		columns (Hash) - hash of the columns

rescue Exception => e

=end
	def getColumns(columns)
    # all leftover columns after removing defined columns are
    # user uploaded
    w_cols = columns

    conf = columns["confidence"]
    w_cols.delete("confidence")

    cert_sev = columns["cert_severity"]
    w_cols.delete("cert_severity")

    cert_like = columns["cert_likelihood"]
    w_cols.delete("cert_likelihood")

    cert_rem = columns["cert_remediation"]
    w_cols.delete("cert_remediation")

    cert_pri = columns["cert_priority"]
    w_cols.delete("cert_priority")

    cert_lvl = columns["cert_level"]
    w_cols.delete("cert_level")

    cwe_like = columns["cwe_likelihood"]
    w_cols.delete("cwe_likelihood")

    return conf, cert_sev, cert_like, cert_rem, cert_pri, cert_lvl, cwe_like,
    	w_cols
	end
end
