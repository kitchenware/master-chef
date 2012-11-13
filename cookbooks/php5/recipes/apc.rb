package "php-apc"

apache2_vhost "php5:apc_vhost" do
	 options :document_root => "#{node.php5.apc_vhost.document_root}", :listen => "#{node.php5.apc_vhost.listen}", :cookbook => "apache2", :source => "default_vhost.conf.erb"
end

template "/etc/php5/conf.d/apc.ini" do
  owner "root"
  mode 0644
  variables :config => node.php5.apc
  source "apc.ini.erb"
  notifies :reload, resources(:service => "apache2") if find_resources_by_name_pattern(/^apache2$/).size > 0
  notifies :reload, resources(:service => "php5-fpm") if find_resources_by_name_pattern(/^php5-fpm$/).size > 0
end

directory "#{node.php5.apc_vhost.document_root}" do
  mode 0755
  owner "www-data"
  group "www-data"
  recursive true
end

template "#{node.php5.apc_vhost.document_root}/apc.php" do
  owner "www-data"
  mode 0755
  source "apc.php.erb"
end

template "#{node.php5.apc_vhost.document_root}/apc_clear_cache.php" do
  owner "www-data"
  mode 0755
  source "apc_clear_cache.php.erb"
end