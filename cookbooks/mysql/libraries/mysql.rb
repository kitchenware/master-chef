module MysqlHelper

  def mysql_password user
    local_storage_read "mysql_password:#{user}"
  end

  def mysql_config key
    config = extract_config key
    config[:password] = mysql_password config[:username] unless config[:password]
    config
  end

  def mysql_compute_host key
    config = extract_config key
    unless config[:host]
      config[:host] = yield
    end
    local_storage_store_memory "#{key}:host", config[:host]
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

class Chef::ResourceDefinition
  include MysqlHelper
end