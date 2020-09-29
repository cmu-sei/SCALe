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
require 'scaife/format_conversion'
require 'utility/db'

class FormatConversionTest < ActiveSupport::TestCase
  include Scaife::FormatConversion
  include Utility::Db

  setup do
    @db, @db_dir = create_test_ext_db()

    # populate db with test data
    ext_con = switch_db_con(true, @db)
    sql = "INSERT INTO MetaAlerts"\
      " (condition_id, confidence_score, priority_score)"\
      " VALUES(1,1.0,1),(2,2.0,2),(3,3.0,3),(4,4.0,4),(5,5.0,5),(6,6.0,6);"
    ext_con.insert(sql)
    ext_con.commit_db_transaction

    # disconnect from ext_db and reconnect to Rails db
    switch_db_con(false)
  end

  teardown do
    delete_test_ext_db(@db, @db_dir)
  end

  test "project_scale_to_scaife" do
    project_id = 10
    package_id = "5"
    meta_alert_id = nil
    is_prod = false
    

    r = JSON.parse(project_scale_to_scaife(project_id, package_id, meta_alert_id, is_prod))

    file = File.open Rails.configuration.x.test_data_dir.join(
      "project_scale_to_scaife_output.json")

    expected_output = JSON.load(file)

    assert_equal expected_output, r

  end

  test "project_scale_to_scaife_invalid project" do
    project_id = 91989823918
    package_id = nil
    meta_alert_id = nil
    is_prod = false

    r = project_scale_to_scaife(project_id, package_id, meta_alert_id, is_prod)

    assert_equal false, r
  end

end
