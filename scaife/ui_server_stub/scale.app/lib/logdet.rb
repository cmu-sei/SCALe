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

module LogDet
  # Returns ID of new determination
  def log_det(display, user_id)
    con = ActiveRecord::Base.connection

    # Only operate if no values changed
    old_det = con.execute('SELECT * FROM Determinations'\
                          " WHERE project_id='#{display.project_id}'"\
                          " AND meta_alert_id='#{display.meta_alert_id}'"\
                          ' ORDER BY time DESC;').first

    if old_det.present?
      if display.verdict == old_det['verdict'] &&
         display.notes == old_det['notes'] &&
         display.flag == (old_det['flag'] != 0) &&
         display.ignored == (old_det['ignored'] != 0) &&
         display.dead == (old_det['dead'] != 0) &&
         display.inapplicable_environment == (old_det['inapplicable_environment'] != 0) &&
         display.dangerous_construct.to_s == old_det['dangerous_construct'].to_s &&
         userid = old_det['user_id']
             print("No change in this update\n")
             return false
      end
    else # Still the initial determination (no changes made)
        if !(display.flag ||
           display.ignored ||
           display.dead ||
           display.inapplicable_environment) &&
           display.verdict == 0 &&
           display.dangerous_construct == 0 &&
           (display.notes == "" || display.notes == "0")
               print("No change in this update\n")
               return false
        end
    end

    result = con.execute("INSERT INTO Determinations ('project_id', 'meta_alert_id', "\
                " 'time', 'verdict', 'flag', 'notes', 'ignored', 'dead', "\
                " 'inapplicable_environment', 'dangerous_construct', 'user_id') "\
                "VALUES ('#{display.project_id}', "\
                "'#{display.meta_alert_id}', DATETIME('now'), "\
                "'#{display.verdict}', '#{display.flag ? 1 : 0}', "\
                " '#{display.notes}', '#{display.ignored ? 1 : 0}', "\
                "'#{display.dead ? 1 : 0}', "\
                " '#{display.inapplicable_environment ? 1 : 0}', "\
                "'#{display.dangerous_construct}', "\
                "'#{user_id}')")
    det_id = con.last_inserted_id(result)
    return det_id
  end
end
