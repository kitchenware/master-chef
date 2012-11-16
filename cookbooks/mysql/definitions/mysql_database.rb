
define :mysql_database, {
} do
  mysql_database_params = params

  config = extract_config mysql_database_params[:name]

  if config[:host] == "localhost"

    unless config[:password]
      config[:password] = local_storage_read("mysql_password:#{config[:username]}") do
        PasswordGenerator.generate 32
      end
    end

    root_mysql_password = mysql_password "root"

    users = ["#{config[:username]}@localhost"]
    users << config[:username] unless node.mysql.bind_address == "127.0.0.1"

    command = "(\n"
    command += " echo \"CREATE DATABASE IF NOT EXISTS #{config[:database]};\"\n"
    users.each do |u|
      command += "echo \"CREATE USER #{u} IDENTIFIED BY \\\"#{config[:password]}\\\";\"\n"
      command += "echo \"GRANT ALL PRIVILEGES ON #{config[:database]} . * TO  #{u};\"\n";
    end
    command += ") | mysql --user=root --password=#{root_mysql_password}"

    puts command

    bash "create database #{config[:database]}" do
      code command
      not_if "echo 'SHOW DATABASES' | mysql --user=root --password=#{root_mysql_password} | grep #{config[:database]}"
    end

  end

  if config[:mysql_wrapper] && ! find_resources_by_name(File.dirname(config[:mysql_wrapper][:file])).empty?

    file config[:mysql_wrapper][:file] do
      content "#!/bin/sh -e\nmysql --user=#{config[:username]} --password=#{config[:password]} --host=#{config[:host]} #{config[:database]} $*"
      mode 0700
      owner config[:mysql_wrapper][:owner]
    end

  end

end