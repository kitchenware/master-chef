include_recipe "tomcat"
include_recipe "nginx"

directory node.jenkins.home do
  owner node.tomcat.user
end

tomcat_instance "jenkins:tomcat" do
  war_url node.jenkins.url
  war_location node.jenkins.location
end

tomcat_jenkins_http_port = tomcat_config("jenkins:tomcat")[:connectors][:http][:port]

nginx_add_default_location "jenkins" do
  content <<-EOF

  location #{node.jenkins.location} {
    proxy_pass http://tomcat_jenkins_upstream;
    break;
  }

EOF
  upstream <<-EOF
  upstream tomcat_jenkins_upstream {
  server 127.0.0.1:#{tomcat_jenkins_http_port} fail_timeout=0;
}
  EOF
end
