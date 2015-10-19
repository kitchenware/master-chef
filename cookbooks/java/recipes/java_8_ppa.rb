if node.platform == "ubuntu" && node.apt.master_chef_add_apt_repo

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
  package "oracle-java8-set-default"

  execute "update alternatives for java 8" do
    user "root"
    command "update-java-alternatives -s java-8-oracle"
    not_if "readlink /etc/alternatives/java | grep java-8-oracle"
  end

else

  raise "Java 8 install is not implemented for your distro"

end