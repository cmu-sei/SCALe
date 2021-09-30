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

require 'utility/db'

module Scaife
    module FormatConversion
        include Utility::Db
=begin

        convert a SCALe project to SCAIFE formatted JSON object

        params:
            project_id (int) - project_id
            package_id (string) - package id from SCAIFE NOTE: Packages should be
                                                        uploaded to SCAIFE first to get this package_id

        returns:
            obj (JSON object) - JSON object containing SCAIFE formatted project
            false (boolean) - if project with given project_id doesn't exist

=end
        def project_scale_to_scaife(project_id, package_id, meta_alert_id = nil, is_prod = false)
            project = Project.find_by(id: project_id)

            if project
                obj = Hash.new
                obj[:project_name] = project.name
                obj[:project_description] = project.description
                obj[:package_id] = package_id
                obj[:meta_alerts] = []

                if is_prod
                    ext_con = switch_db_con(true, :external, true)
                else
                    ext_db_path = Rails.configuration.x.external_db_dir.join(
                    project_id.to_s, Rails.configuration.x.external_db_basename)
                    ext_con = switch_db_con(true, ext_db_path)
                end
                
                sql1 = "SELECT id AS meta_alert_id, condition_id FROM MetaAlerts;"
                
                m_id_conditions = ext_con.execute(sql1)
                
                switch_db_con(false)
                if nil == meta_alert_id
                  # Get meta_alerts and determinations by project_id
                  meta_alerts = Display.where(project_id: project_id)
                    .group_by(&:meta_alert_id)

                  dets = Determination.where(project_id: project_id)
                  .order(time: :desc)
                  .group_by(&:meta_alert_id)
                else
                  # Get meta_alerts and determinations by project_id and meta_alert_id
                  meta_alerts = Display.where(project_id: project_id)
                    .where(meta_alert_id: meta_alert_id)
                    .group_by(&:meta_alert_id)

                  dets = Determination.where(project_id: project_id)
                    .where(meta_alert_id: meta_alert_id)
                    .order(time: :desc)
                    .group_by(&:meta_alert_id)
                end

                meta_alerts.each_pair do |m_id, alertConds|
                    alert_ids = alertConds.map{ |a| a.alert_id.to_s }
                    filepath = alertConds[0].path
                    line_number = alertConds[0].line

                    matching_record = m_id_conditions.find{|k| k["meta_alert_id"] == m_id}
                    if matching_record
                        condition_id = matching_record["condition_id"]
                    else
                        puts "Meta-alert " + m_id.to_s + " has no condition, and will not be sent to SCAIFE"
                        next
                    end

                    flag_list = []
                    ienv_list = []
                    ignored_list = []
                    verdict_list = []
                    dead_list = []
                    dc_list = []
                    notes_list = []
                     
                    if dets[m_id].present?                       
                        dets[m_id].each do |d|
                            verdict_num = d.verdict
                            verdict = ""
                
                            if 0 == verdict_num
                                verdict = "Unknown"
                            elsif 1 == verdict_num
                                verdict = "Complex"
                            elsif 2 == verdict_num
                                verdict = "False"
                            elsif 3 == verdict_num
                                verdict = "Dependent"
                            elsif 4 == verdict_num
                                verdict = "True"
                            end
    
                            flag_list.push({flag: d.flag, timestamp: d.time})
                            ienv_list.push({
                                inapplicable_environment: d.inapplicable_environment.to_s,
                                timestamp: d.time
                            })
                            ignored_list.push({ignored: d.ignored.to_s, timestamp: d.time})
                            verdict_list.push({verdict: verdict, timestamp: d.time})
                            dead_list.push({dead: d.dead.to_s, timestamp: d.time})
    
                            dc = d.dangerous_construct.to_i
    
                            dangerous_construct = "Unknown"
                            if 0 == dc
                                dangerous_construct = "No"
                            elsif 1 == dc
                                dangerous_construct = "Low Risk"
                            elsif 2 == dc
                                dangerous_construct = "Medium Risk"
                            elsif 3 == dc
                                dangerous_construct = "High Risk"
                            end
    
                            dc_list.push({
                                dangerous_construct: dangerous_construct,
                                timestamp: d.time
                            })
                            notes_list.push({notes: d.notes.to_s, timestamp: d.time})
                        end
                    end

                    obj[:meta_alerts].push({meta_alert_id: m_id,
                                            alert_ids: alert_ids,
                                            filepath: filepath,
                                            line_number: line_number, 
                                            condition_id: condition_id.to_s,
                                            determination: {flag_list: flag_list,
                                                            inapplicable_environment_list: ienv_list,
                                                            ignored_list: ignored_list,
                                                            verdict_list: verdict_list,
                                                            dead_list: dead_list,
                                                            dangerous_construct_list: dc_list,
                                                            notes_list: notes_list
                                                            }
                                         })
                    end

                return obj.to_json
            else
                return false
            end
        end

        def package_scale_to_scaife
        end
    end
end
