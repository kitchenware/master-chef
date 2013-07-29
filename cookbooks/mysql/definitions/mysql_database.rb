
define :mysql_database, {
} do
  mysql_database_params = params

  config = extract_config mysql_database_params[:name]

  if config[:host] == "localhost" && node.mysql[:run_sql]

    unless config[:password]
      config[:password] = local_storage_read("mysql_password:#{config[:username]}") do
        PasswordGenerator.generate 32
      end
    end

    root_mysql_password = mysql_password "root"

    users = ["#{config[:username]}@localhost"]
    users << config[:username] unless node.mysql.engine_config.mysqld.bind_address == "127.0.0.1"

    c = "(\n"
    c += " echo \"CREATE DATABASE IF NOT EXISTS #{config[:database]};\"\n"
    users.each do |u|
      c += "echo \"CREATE USER #{u} IDENTIFIED BY \\\"#{config[:password]}\\\";\"\n"
      c += "echo \"GRANT ALL PRIVILEGES ON #{config[:database]} . * TO  #{u};\"\n";
    end
    c += ") | mysql --user=root --password=#{root_mysql_password}"

    execute "create database #{config[:database]}" do
      command c
      not_if "echo 'SHOW DATABASES' | mysql --user=root --password=#{root_mysql_password} | grep #{config[:database]}"
    end

  end

  if config[:mysql_wrapper]

    template config[:mysql_wrapper][:file] do
      cookbook "mysql"
      source "mysql.sh.erb"
      variables :config => config
      mode '0700'
      owner config[:mysql_wrapper][:owner]
      action :nothing
    end

    # directory enclosing wrapper file is often created after, or does not exists (server with db only)
    delayed_exec "create #{config[:mysql_wrapper][:file]}" do
      after_block_notifies :create, "template[#{config[:mysql_wrapper][:file]}]"
      block do
        File.exists? File.dirname(config[:mysql_wrapper][:file])
      end
    end

  end

end