default[:jenkins][:home] = "/jenkins"
default[:jenkins][:url] = "http://mirrors.jenkins-ci.org/war/latest/jenkins.war"
default[:jenkins][:location] = "/jenkins"
default[:jenkins][:tomcat] = {
  :name => 'jenkins',
  :connectors => {
    :http => {
      'URIEncoding' => 'UTF-8'
    }
  },
  :env => {
    'JENKINS_HOME' => node.jenkins.home,
    'JAVA_OPTS' => '-XX:MaxPermSize=256m -Xmx512m -Xms128m',
  }
}

default[:jenkins][:update_site] = "http://mirrors.jenkins-ci.org/plugins"
default[:jenkins][:plugins] = []


default[:jenkins][:install_maven] = false

default[:maven][:version] = "3.0.5"
default[:maven][:home] = "/opt/maven/"
default[:maven][:zip_url] = "http://apache.opensourcemirror.com/maven/maven-3/#{node.maven.version}/binaries/apache-maven-#{node.maven.version}-bin.tar.gz"
