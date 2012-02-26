bash "add ppa sun java 6" do
  code "add-apt-repository ppa:sun-java-community-team/sun-java6 && apt-get update"
  not_if "ls /etc/apt/sources.list.d | grep sun-java"
end

package "sun-java6-jdk"
