include_recipe "mysql::server"
include_recipe "nginx"

mysql_database "sonar:database"

base_user node.sonar.user

directory node.sonar.path do
  owner node.sonar.user
  recursive true
end

execute_version "download sonar" do
  user node.sonar.user
  command <<-EOF
cd #{node.sonar.path} &&
rm -rf * &&
curl --location #{node.sonar.zip_url} -o sonar.zip &&
unzip sonar.zip &&
mv sonarqube-#{node.sonar.version} sonar &&
rm -f sonar.zip
EOF
  environment get_proxy_environment
  version node.sonar.zip_url
  file_storage "#{node.sonar.path}/.sonar_download"
end

template "#{node.sonar.path}/sonar/conf/sonar.properties" do
  owner node.sonar.user
  mode '0644'
  variables :db_config => mysql_config("sonar:database")
  source "sonar.properties.erb"
  notifies :restart, "service[sonar]"
end

template "/etc/init.d/sonar" do
  source "init_d.erb"
  #notifies :run, "execute[deploy sonar config in machine]"
end

execute_version "deploy sonar config in machine" do
  command <<-EOF
  sudo ln -s /opt/sonar/sonar/bin/linux-x86-64/sonar.sh /usr/bin/sonar
  sudo chmod 755 /etc/init.d/sonar
  sudo update-rc.d sonar defaults
EOF
environment get_proxy_environment
version node.sonar.zip_url
file_storage "#{node.sonar.path}/.sonar_deployed"
end

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
  server 127.0.0.1:9000 fail_timeout=0;
}
  EOF
end

service "sonar" do
  supports :status => true, :restart => true, :reload => true
  action auto_compute_action
end