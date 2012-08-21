include_recipe "tomcat"
include_recipe "nginx"

if node['platform'] == "ubuntu" 
  package "zlib1g-dev"
  package "build-essential"
  package "libxml2-dev"
  package "libxslt-dev"
  package "libsqlite3-dev"
  package "libssl-dev"
  if %x{lsb_release -cs} == "precise"
    package "libreadline-gplv2-dev"
  else
    package "libreadline5-dev"
  end 
end



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
