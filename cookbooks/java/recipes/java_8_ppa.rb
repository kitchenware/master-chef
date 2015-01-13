execute "accept oracle licence for java8" do
  command "echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections"
  not_if "sudo debconf-show oracle-java8-installer | grep \"accepted-oracle-license\" | grep true"
end

add_apt_repository "ppa_java8" do
  url "http://ppa.launchpad.net/webupd8team/java/ubuntu"
  key "EEA14886 "
  key_server "keyserver.ubuntu.com"
end

package "oracle-java8-installer"

