
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

    bash "create database #{config[:database]}" do
      code <<-EOF
      (
      echo "CREATE USER #{config[:username]}@localhost IDENTIFIED BY \\"#{config[:password]}\\";"
      echo "CREATE DATABASE IF NOT EXISTS #{config[:database]};"
      echo "GRANT ALL PRIVILEGES ON #{config[:database]} . * TO  #{config[:username]}@localhost;"
      ) | mysql --user=root --password=#{root_mysql_password}
      EOF
      not_if "echo 'SHOW DATABASES' | mysql --user=root --password=#{root_mysql_password} | grep #{config[:database]}"
    end

  end

  if config[:mysql_wrapper]

    file config[:mysql_wrapper][:file] do
      content "#!/bin/sh -e\nmysql --user=#{config[:username]} --password=#{config[:password]} --host=#{config[:host]} #{config[:database]} $*"
      mode 0700
      owner config[:mysql_wrapper][:owner]
    end

  end

end