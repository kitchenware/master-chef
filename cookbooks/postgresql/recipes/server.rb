
include_recipe "postgresql"

package "postgresql"

package "postgresql-contrib" if node.postgresql.contrib

if node.postgresql.version == node.default[:postgresql][:version]
  node.set[:postgresql][:version] = '8.4' if node.lsb.codename == "lucid" || node.lsb.codename == "squeeze"
end

if node.postgresql.service_name == node.default[:postgresql][:service_name] && node.lsb.codename == "lucid"
  node.set[:postgresql][:service_name] = 'postgresql-8.4'
end

service node.postgresql.service_name do
  supports :status => true, :restart => true
  restart_command node.postgresql[:restart_command] if node.postgresql[:restart_command]
  action auto_compute_action
end

Chef::Config.exception_handlers << ServiceErrorHandler.new(node.postgresql.service_name, ".*postgresql.*")

directory "/etc/postgresql/#{node.postgresql.version}/main/conf.d" do
  owner node.postgresql.user
  group node.postgresql.user
end

template "/etc/postgresql/#{node.postgresql.version}/main/pg_hba.conf" do
  source "pg_hba.conf.erb"
  variables node.postgresql
  mode '0640'
  owner node.postgresql.user
  notifies :restart, "service[#{node.postgresql.service_name}]", :immediately
end

root_postgresql_password = node.postgresql[:root_password]

if root_postgresql_password
  local_storage_write("postgresql_password:root", root_postgresql_password)
else
  root_postgresql_password = local_storage_read("postgresql_password:root") do
    password = PasswordGenerator.generate 32
    Chef::Log.info "Postgresql : new root password generated"
    password
  end
end

file "/root/.pgpass" do
  content <<-EOF
*:5432:*:#{node.postgresql.root_account}:#{root_postgresql_password}
EOF
  mode '0400'
end

execute "change postgresql root password" do
  user node.postgresql.user
  command "psql --command \"CREATE USER #{node.postgresql.root_account} WITH CREATEDB NOCREATEUSER NOCREATEROLE PASSWORD '#{root_postgresql_password}';\""
  not_if "PGPASSWORD=#{root_postgresql_password} psql postgres --username=#{node.postgresql.root_account} --command=\"select 1;\""
end

if node.postgresql.version.to_f >= 9.3

  execute "add include confd postgresql config file" do
    command "echo \"include_dir '/etc/postgresql/#{node.postgresql.version}/main/conf.d'\" >> /etc/postgresql/#{node.postgresql.version}/main/postgresql.conf"
    not_if "grep include_dir /etc/postgresql/#{node.postgresql.version}/main/postgresql.conf | grep -v '#'"
    notifies :restart, "service[#{node.postgresql.service_name}]", :immediately
  end

else

  execute "add include chef.conf postgresql config file" do
    command "echo \"include '/etc/postgresql/#{node.postgresql.version}/main/conf.d/chef.conf'\" >> /etc/postgresql/#{node.postgresql.version}/main/postgresql.conf"
    not_if "grep conf.d/chef.conf /etc/postgresql/#{node.postgresql.version}/main/postgresql.conf"
    notifies :restart, "service[#{node.postgresql.service_name}]", :immediately
  end

end

template "/etc/postgresql/#{node.postgresql.version}/main/conf.d/chef.conf" do
  source "chef.conf.erb"
  variables node.postgresql
  mode '0644'
  owner node.postgresql.user
  group node.postgresql.user
  notifies :restart, "service[#{node.postgresql.service_name}]", :immediately
end

if node[:postgresql] && node.postgresql[:databases] && !node.postgresql[:no_databases]

  node.postgresql.databases.keys.each do |k|

    postgresql_database "postgresql:databases:#{k}" do
      instance_name k
    end

    db_config = postgresql_config "postgresql:databases:#{k}"

    Chef::Log.info "************************************************************"
    Chef::Log.info "Postgresql database for #{k}"
    Chef::Log.info "Host          : #{db_config[:host]}"
    Chef::Log.info "Database name : #{db_config[:database]}"
    Chef::Log.info "User          : #{db_config[:username]}"
    Chef::Log.info "Password      : #{db_config[:password]}"
    Chef::Log.info "************************************************************"
  end

end

delayed_exec "Remove useless postgresql config files" do
  after_block_notifies :restart, resources(:service => "postgresql")
  block do
    updated = false
    confs = find_resources_by_name_pattern(/^\/etc\/postgresql\/#{node.postgresql.version}\/main\/conf.d\/.*$/).map{|r| r.name}
    Dir["/etc/postgresql/#{node.postgresql.version}/main/conf.d/*"].each do |n|
      unless confs.include?(n)
        Chef::Log.info "Removing useless postgresql config #{n}"
        File.unlink n
        updated = true
      end
    end
    updated
  end
end
