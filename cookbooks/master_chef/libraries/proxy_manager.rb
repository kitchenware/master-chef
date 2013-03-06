module ProxyManager

  def get_proxy_environment source = {}
    source['http_proxy'] = ENV['BACKUP_http_proxy'] if ENV['BACKUP_http_proxy']
    source['https_proxy'] = ENV['BACKUP_https_proxy'] if ENV['BACKUP_https_proxy']
    source
  end

end

class Chef::Recipe
  include ProxyManager
end

class Chef::Resource
  include ProxyManager
end

class Chef::Provider
  include ProxyManager
end

class Chef::ResourceDefinition
  include ProxyManager
end