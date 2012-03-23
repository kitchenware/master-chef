
if node['platform'] == "ubuntu"
  base_ppa "sun-java" do
    url "ppa:sun-java-community-team/sun-java6"
  end
end

if node['platform'] == "debian"
  add_apt_repository "sun-java" do
     url "http://ftp.ie.debian.org/debian"
     components ["non-free"]
  end
end
  
bash "auto accept java license" do
  code "echo sun-java6-jdk shared/accepted-sun-dlj-v1-1 select true | /usr/bin/debconf-set-selections"
  not_if "dpkg -s sun-java6-jdk"
end

package "sun-java6-jdk"
