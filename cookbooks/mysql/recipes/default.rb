package "mysql-server"

local_storage_read("mysql_password:root") do
  password = PasswordGenerator.generate 32
  Chef::Log.info "Mysql : new root password generated"
  execute "change mysql root password" do
    command "mysqladmin -u root password #{password}"
  end
  password
end
