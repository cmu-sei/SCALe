# This file should contain all the record creation needed to seed the
# database with its default values.
#
# The data can then be loaded with the rake db:seed (or created
# alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

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

# make sure any non-standard app dirs exist
[ Rails.configuration.x.db_dir,
  Rails.configuration.x.external_db_dir,
  Rails.configuration.x.db_backup_dir,
  Rails.configuration.x.archive_dir,
  Rails.configuration.x.archive_backup_dir,
  Rails.configuration.x.archive_nobackup_dir].each do |d|
    FileUtils.makedirs(d)
end

# probably might want to port this to ruby, but we're using the
# python for expediency
init_db_script = Rails.root.join("scripts/init_shared_tables.py").to_s
internal_db = Rails.configuration.x.db_path
cmd = "#{init_db_script} #{internal_db}"
puts "initializing static/shared data: #{cmd}"
output = `#{cmd}`
if $? != 0
  puts "problem executing:"
  puts cmd
end
if output =~ /\S+/
  puts output
end

if Rails.env == "test"
  user = "test_user"
  passwd = "test_passwd"
  puts "ENV == test; creating test user: #{user}:#{passwd}"
  User.create("Test", "User", "ORG", user, passwd).save!
end
