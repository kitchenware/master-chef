include_recipe "mysql::server"

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

service "sonar" do
  supports :status => true, :restart => true, :reload => true
  action auto_compute_action
end