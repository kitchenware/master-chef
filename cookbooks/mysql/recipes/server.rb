
include_recipe "mysql"

package "mysql-server"

Chef::Config.exception_handlers << ServiceErrorHandler.new("mysql", ".*mysql.*")

service "mysql" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

execute "reconfigure mysql bind address" do
  command "sed -ie 's/bind-address.*$/bind-address = #{node.mysql.bind_address}/' /etc/mysql/my.cnf"
  not_if "cat /etc/mysql/my.cnf | grep bind-address | grep #{node.mysql.bind_address}"
  notifies :restart, resources(:service => "mysql")
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

if node[:mysql] && node.mysql[:keep_test] != true
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