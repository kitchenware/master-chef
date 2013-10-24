
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

  node.set[:mysql][:engine_config][:mysqld][:bind_address] = '0.0.0.0' if node.mysql.engine_config.mysqld.bind_address == '127.0.0.1'

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

root_mysql_password = node.mysql[:root_password]

if root_mysql_password
  local_storage_write("mysql_password:root", root_mysql_password)
else
  root_mysql_password = local_storage_read("mysql_password:root") do
    password = PasswordGenerator.generate 32
    Chef::Log.info "Mysql : new root password generated"
    password
  end
end

execute "change mysql root password" do
  command "mysqladmin -u root password #{root_mysql_password}"
  only_if "echo 'select 1;' | mysql --user=root --password="
end

file "/root/.my.cnf" do
  content <<-EOF
[client]
user=root
host=localhost
password=#{root_mysql_password}
EOF
  mode '0400'
end

if node.mysql.use_percona && node.mysql[:percona_cluster]

  local_node = nil
  node["network"]["interfaces"].each do |name, config|
    config["addresses"].each do |ip, ip_config|
    local_node = ip if node.mysql.percona_cluster.nodes.include? ip
    end
  end

  raise "No local ip found in node cluster definition #{node.mysql.percona_cluster.name}" unless local_node

  config = node.mysql.percona_cluster.to_hash
  config["local_node"] = local_node
  config["root_password"] = root_mysql_password
  config["is_master"] = local_node == config["master"]
  config["mysql_commands"] = [
    "CREATE USER '#{config["rep_username"]}'@'localhost' IDENTIFIED BY '#{config["rep_password"]}';",
    "GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '#{config["rep_username"]}'@'localhost';",
    "FLUSH PRIVILEGES;"
  ]
  config["mysql_commands"] += node.mysql.percona_cluster.mysql_commands if node.mysql.percona_cluster[:mysql_commands]

  ruby_block "update percona cluster" do
    block do
      PerconaCluster.new(config).converge true
    end
    action :nothing
  end

  template "/etc/mysql/conf.d/cluster.cnf" do
    source 'percona_cluster.cnf.erb'
    mode '0644'
    variables config
    notifies :run, "ruby_block[update percona cluster]", :immediately
  end

  ruby_block "manage percona cluster" do
    block do
      PerconaCluster.new(config).converge
    end
  end

  node.set[:mysql][:run_sql] = false unless config["is_master"]

end

if node[:mysql] && ! node.mysql[:keep_test] && node.mysql[:run_sql]
  execute "remove test mysql database" do
    command "echo 'drop database test;' | mysql --user=root --password=#{root_mysql_password}"
    only_if "echo 'show databases;' | mysql --user=root --password=#{root_mysql_password} | grep ^test$"
  end
end

if node[:mysql] && node.mysql[:databases]

  node.mysql.databases.keys.each do |k|

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