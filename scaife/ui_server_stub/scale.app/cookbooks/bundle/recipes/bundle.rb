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

bash "download and install gems" do
  code <<-EOH
    gem update --system
    gem install json_pure bundler
  EOH
  user "root"
  action :run
end

bash "install vendor bundle" do
  # If the nokogiri build fails, install it (but nothing else) as root
  code <<-EOH
    cd /home/vagrant/scale.app
    bundle config build.nokogiri --use-system-libraries
    bundle install --path vendor/bundle --jobs 4
    bundle exec rake db:migrate
    bundle exec rake db:seed
  EOH
  user "vagrant"
  action :run
end
