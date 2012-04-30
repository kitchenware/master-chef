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
    'TOMCAT5_SECURITY' => 'no',
    'JENKINS_HOME' => node.jenkins.home,
  }
}