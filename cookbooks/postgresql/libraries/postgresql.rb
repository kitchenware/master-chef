module PostgresqlHelper

  def postgresql_password user
    local_storage_read "postgresql_password:#{user}"
  end

  def postgresql_config key
    config = extract_config key
    config[:password] = postgresql_password config[:username] unless config[:password]
    config
  end

  def postgresql_compute_host key
    config = extract_config key
    unless config[:host]
      config[:host] = yield
    end
    local_storage_write_memory "#{key}:host", config[:host]
  end

end

class Chef::Recipe
  include PostgresqlHelper
end

class Chef::Resource
  include PostgresqlHelper
end

class Chef::Provider
  include PostgresqlHelper
end

class Chef::ResourceDefinition
  include PostgresqlHelper
end