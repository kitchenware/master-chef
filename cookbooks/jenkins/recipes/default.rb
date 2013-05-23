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

if node.jenkins.plugins.size > 0

  directory "#{node.jenkins.home}/plugins" do
    owner node.tomcat.user
    group node.tomcat.user
  end

end

node.jenkins.plugins.each do |name|

  directory "#{node.jenkins.home}/plugins/#{name}" do
    owner node.tomcat.user
    group node.tomcat.user
  end

  execute "add jenkins plugin #{name}" do
    user node.tomcat.user
    group node.tomcat.user
    environment get_proxy_environment
    command "cd #{node.jenkins.home}/plugins && curl -f -s -L -o #{name}.hpi #{node.jenkins.update_site}/#{name}/latest/#{name}.hpi"
    not_if "[ -f #{node.jenkins.home}/plugins/#{name}.hpi ]"
    notifies :restart, resources(:service => "jenkins")
  end
end

if node.jenkins.install_maven

  directory "#{node.maven.home}" do
    recursive true
    owner node.tomcat.user
  end

  execute "install maven" do
    command "cd #{node.maven.home} && curl -f -s --location #{node.maven.zip_url} -o maven.tar.gz && tar -xzf maven.tar.gz && rm maven.tar.gz"
    not_if "test -d #{node.maven.home}/apache-maven-#{node.maven.version}"
  end

  template "#{node.jenkins.home}/hudson.tasks.Maven.xml" do
    owner node.tomcat.user
    source "hudson.tasks.Maven.xml.erb"
    variables ({:name => "maven3", :maven_home => "#{node.maven.home}/apache-maven-#{node.maven.version}"})
  end


 end