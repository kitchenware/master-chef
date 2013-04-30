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


unless node[:jenkins][:server][:plugins].nil?
  node[:jenkins][:server][:plugins].each do |name|
    directory "#{node.jenkins.home}/plugins/#{name}" do
      owner node.tomcat.user
      group node.tomcat.user
      only_if { node[:jenkins][:server][:plugins].size > 0 }
      recursive true
      action :create
    end
  end
  
  execute "stop jenkins" do
    command "/etc/init.d/jenkins stop"
  end
  
  node[:jenkins][:server][:plugins].each do |name|
    execute "add jenkins plugin" do
      user node.tomcat.user
      group node.tomcat.user
      only_if { node[:jenkins][:server][:plugins].size > 0 }
      environment get_proxy_environment
      command "cd #{node.jenkins.home}/plugins && curl -f -L -o #{name}.hpi http://updates.jenkins-ci.org/latest/#{name}.hpi"
    end
  end
  
  
  execute "start jenkins" do
    command "/etc/init.d/jenkins start "
  end
end

