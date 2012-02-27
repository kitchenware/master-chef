base_ppa "sun-java" do
  url "ppa:sun-java-community-team/sun-java6"
end
  
bash "auto accept java license" do
  code "echo sun-java6-jdk shared/accepted-sun-dlj-v1-1 select true | /usr/bin/debconf-set-selections"
end

package "sun-java6-jdk"
