include_recipe "apache2"

include_recipe "php5"

package "php-apc"

apache2_vhost "apc" do
	 options :document_root => "#{node.php5.apc.document_root}"  
end

php5_apache2 do
  options({
    :safe_mode => false,
    :memory_limit => "32M",
  })
end

apache2_enable_module "rewrite"
apache2_enable_module "status"
apache2_enable_module "authz_host"

template "/etc/php5/conf.d/apc.ini" do
  owner "root"
  mode 0644
  variables :shm_size => node.php5.apc.apc_shm_size
  source "apc.ini.erb"
  notifies :reload, resources(:service => "apache2")
end

directory "#{node.php5.apc.document_root}" do
  mode 0755
  owner "www-data"
  group "www-data"
  recursive true
end

template "#{node.php5.apc.document_root}/apc.php" do
  owner "www-data"
  mode 0755
  source "apc.php.erb"
end


template "#{node.php5.apc.document_root}/apc_clear_cache.php" do
  owner "www-data"
  mode 0755
  source "apc_clear_cache.php.erb"
end