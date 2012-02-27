include_recipe "tomcat"

directory node.jenkins.home do
  owner node.tomcat.user
end

tomcat_instance "jenkins" do
  env({
    'TOMCAT5_SECURITY' => 'no',
    'JENKINS_HOME' => node.jenkins.home,
  })
  connectors({
    "http" => {
      "port" => 8080,
      "address" => "127.0.0.1"},
    })
  control_port 8005
  war_url "http://mirrors.jenkins-ci.org/war/latest/jenkins.war"
  war_name "#{node.jenkins.location[1..-1]}"
end

nginx_add_default_location "jenkins" do
  content <<-EOF

  location #{node.jenkins.location} {
    proxy_pass http://tomcat_jenkins_upstream;
    break;
  }

EOF
  upstream <<-EOF
  upstream tomcat_jenkins_upstream {
  server 127.0.0.1:8080 fail_timeout=0;
}
  EOF
end
