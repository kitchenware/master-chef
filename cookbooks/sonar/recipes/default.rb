include_recipe "mysql"
include_recipe "tomcat"
include_recipe "nginx"

mysql_database "sonar:database"

db_config = mysql_config "sonar:database"

Chef::Log.info "************************************************************"
Chef::Log.info "Mysql database for sonar"
Chef::Log.info "Host          : #{db_config[:host]}"
Chef::Log.info "Database name : #{db_config[:database]}"
Chef::Log.info "User          : #{db_config[:username]}"
Chef::Log.info "Password      : #{db_config[:password]}"
Chef::Log.info "************************************************************"

build_dir = "#{node.sonar.path.build}"
sonar_file_name = "sonar-#{node.sonar.version}"

directory "#{node.sonar.path.root_path}" do
  owner node.tomcat.user
  recursive true
end

execute "install sonar home" do  
  command "cd #{build_dir} && wget #{node.sonar.zip_url} && unzip #{node.sonar.path.build}/#{sonar_file_name}.zip && rm -f #{build_dir}/#{sonar_file_name}.zip"
  not_if "[ -d #{build_dir}/#{sonar_file_name}/war ]"
end

execute "change sonar home owner" do
  command "chown -R #{node.tomcat.user} #{node.sonar.path.build}/#{sonar_file_name}"
end

template "#{node.sonar.path.root_path}/#{sonar_file_name}/conf/sonar.properties" do
  mode 0644
  variables :password => db_config[:password]
  source "sonar.properties.erb"
end

execute "build sonar war" do
  command "cd #{node.sonar.path.build}/sonar-#{node.sonar.version}/war && sh build-war.sh"
  not_if "[ -f #{node.sonar.path.build}/sonar-#{node.sonar.version}/war/sonar.war ]"
end

tomcat_instance "sonar:tomcat" do
  war_url "file://#{node.sonar.path.build}/#{sonar_file_name}/war/sonar.war"
  war_location node.sonar.location
end

tomcat_sonar_http_port = tomcat_config("sonar:tomcat")[:connectors][:http][:port]

nginx_add_default_location "sonar" do
  content <<-EOF

  location #{node.sonar.location} {
    proxy_pass http://tomcat_sonar_upstream;
    proxy_read_timeout 600s;
    break;
  }

EOF
  upstream <<-EOF
  upstream tomcat_sonar_upstream {
  server 127.0.0.1:#{tomcat_sonar_http_port} fail_timeout=0;
}
  EOF
end
