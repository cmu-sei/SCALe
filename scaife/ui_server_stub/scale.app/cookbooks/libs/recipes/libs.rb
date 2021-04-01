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

bash "download and install libncurses5-dev package" do
  code <<-EOH
    apt-get install -y libncurses5-dev
  EOH
  user "root"
  action :run
end

bash "download and install libssl-dev package" do
  code <<-EOH
    apt-get install -y libssl-dev
  EOH
  user "root"
  action :run
end

bash "download and install zip package" do
  code <<-EOH
    apt-get install -y zip
  EOH
  user "root"
  action :run
end

bash "download and install open vm tools" do
  code <<-EOH
    apt-get install -y open-vm-tools open-vm-tools-desktop
  EOH
  user "root"
  action :run
end
