
define :mysql_database, {
  :password => nil,
  :username => nil
} do
  mysql_database_params = params

  mysql_database_params[:username] = mysql_database_params[:name] unless mysql_database_params[:username]

  raise "Please specify password" unless mysql_database_params[:password]

  bash "create database #{mysql_database_params[:name]}" do
    code <<-EOF
    (
    echo "CREATE USER #{mysql_database_params[:username]}@localhost IDENTIFIED BY \\"#{mysql_database_params[:password]}\\";"
    echo "CREATE DATABASE IF NOT EXISTS #{mysql_database_params[:name]};"
    echo "GRANT ALL PRIVILEGES ON #{mysql_database_params[:name]} . * TO  #{mysql_database_params[:username]}@localhost;"
    ) | mysql
    EOF
    not_if "echo 'SHOW DATABASES' | mysql | grep #{mysql_database_params[:name]}"
  end

end