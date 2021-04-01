# <legal>
# SCALe version r.6.5.5.1.A
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

bash "download and install ruby" do
  code <<-EOH
    env DEBIAN_FRONTEND=noninteractive  apt-get install -y ruby
  EOH
  user "root"
  action :run
end

bash "download and install ruby2.5-dev" do
  code <<-EOH
    apt-add-repository -y ppa:brightbox/ruby-ng
    apt-get install -y ruby2.5-dev zlib1g-dev liblzma-dev libxml2-dev libxslt1-dev
  EOH
  user "root"
  action :run
end

bash "download and install rubygems-integration" do
  code <<-EOH
    apt-get install -y rubygems-integration
  EOH
  user "root"
  action :run
end
