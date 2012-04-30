default[:jenkins][:home] = "/jenkins"
default[:jenkins][:location] = "/jenkins"
default[:jenkins][:tomcat] = {
  :name => 'jenkins',
  :env => {
    'TOMCAT5_SECURITY' => 'no',
    'JENKINS_HOME' => node.jenkins.home,
  }
}