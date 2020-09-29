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

bash "download and install Eclipse" do
  code <<-EOH
    wget 'https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/oxygen/1a/eclipse-java-oxygen-1a-linux-gtk-x86_64.tar.gz&r=1' -Oeclipse-java-oxygen-1a-linux-gtk-x86_64.tar.gz
    tar -zxvf eclipse-java-oxygen-1a-linux-gtk-x86_64.tar.gz -C /usr/local/
    rm eclipse-java-oxygen-1a-linux-gtk-x86_64.tar.gz
    ln -s /usr/local/eclipse/eclipse /usr/local/bin/eclipse
    cat > /usr/share/applications/eclipse.desktop <<EOF
    [Desktop Entry]
    Encoding=UTF-8
    Name=Eclipse
    Comment=Eclipse IDE
    Exec=/usr/local/bin/eclipse
    Icon=/usr/local/eclipse/icon.xpm
    Categories=Application;Development;Java;IDE
    Type=Application
    Terminal=0
    EOF
  EOH
  user "root"
  action :run
end
