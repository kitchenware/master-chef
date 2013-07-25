
include_recipe "mysql"

server_package_name = node.mysql.use_percona ? node.mysql.percona_server_package_name : node.mysql.server_package_name
Chef::Log.info "Using mysql server package #{server_package_name}"

package server_package_name

Chef::Config.exception_handlers << ServiceErrorHandler.new("mysql", ".*mysql.*")

service "mysql" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

if node.mysql.use_percona

  template "/etc/mysql/my.cnf" do
    source "my.cnf.percona.erb"
    mode '0644'
    notifies :restart, "service[mysql]", :immediately
  end

end

mysql_conf = []

node.mysql.engine_config.keys.sort.each do |k|
  mysql_conf << "[#{k}]"
  node.mysql.engine_config[k].keys.sort.each do |kk|
    mysql_conf << "#{kk} = #{node.mysql.engine_config[k][kk]}"
  end
  mysql_conf << ""
end

file "/etc/mysql/conf.d/chef_override.cnf" do
  content mysql_conf.join("\n")
  mode '0644'
  notifies :restart, "service[mysql]", :immediately
end

root_mysql_password = local_storage_read("mysql_password:root") do
  password = PasswordGenerator.generate 32
  Chef::Log.info "Mysql : new root password generated"
  password
end

execute "change mysql root password" do
  command "mysqladmin -u root password #{root_mysql_password}"
  only_if "echo 'select 1;' | mysql --user=root --password= "
end

if node[:mysql] && ! node.mysql[:keep_test]
  execute "remove test mysql database" do
    command "echo 'drop database test;' | mysql --user=root --password=#{root_mysql_password} "
    only_if "echo 'show databases;' | mysql --user=root --password=#{root_mysql_password} | grep ^test$ "
  end
end

if node[:mysql] && node.mysql[:databases]

  node.mysql.databases.keys.each do |k|
    node.set[:mysql][:databases][k][:database] = k

    mysql_database "mysql:databases:#{k}" do
      instance_name k
    end

    db_config = mysql_config "mysql:databases:#{k}"

    Chef::Log.info "************************************************************"
    Chef::Log.info "Mysql database for #{k}"
    Chef::Log.info "Host          : #{db_config[:host]}"
    Chef::Log.info "Database name : #{db_config[:database]}"
    Chef::Log.info "User          : #{db_config[:username]}"
    Chef::Log.info "Password      : #{db_config[:password]}"
    Chef::Log.info "************************************************************"
  end

end