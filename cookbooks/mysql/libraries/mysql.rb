module MysqlHelper

  def mysql_password user
    local_storage_read "mysql_password:#{user}"
  end

  def mysql_config key
    config = extract_config key
    config[:password] = mysql_password config[:username] unless config[:password]
    config
  end

end

class Chef::Recipe
  include MysqlHelper
end

class Chef::Resource
  include MysqlHelper
end

class Chef::Provider
  include MysqlHelper
end