include_recipe "mysql::server"
include_recipe "tomcat"
include_recipe "nginx"

mysql_database "sonar:database"

directory node.sonar.path do
  owner node.tomcat.user
  recursive true
end

target_war = tomcat_instance "sonar:tomcat" do
  war_location node.sonar.location
end

execute "build sonar war" do
  user node.tomcat.user
  command "cd #{node.sonar.path}/sonar/war && sh build-war.sh && cp sonar.war #{target_war}"
  action :nothing
end

execute_version "download sonar" do
  user node.tomcat.user
  command <<-EOF
cd #{node.sonar.path} &&
rm -rf * &&
curl --location #{node.sonar.zip_url} -o sonar.zip &&
unzip sonar.zip &&
mv sonar-#{node.sonar.version} sonar &&
rm -f sonar.zip
EOF
  version node.sonar.zip_url
  file_storage "#{node.sonar.path}/.sonar_download"
  notifies :run, resources(:execute => "build sonar war"), :immediately
end

template "#{node.sonar.path}/sonar/conf/sonar.properties" do
  owner node.tomcat.user
  mode '0644'
  variables :db_config => mysql_config("sonar:database")
  source "sonar.properties.erb"
  notifies :run, resources(:execute => "build sonar war"), :immediately
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
