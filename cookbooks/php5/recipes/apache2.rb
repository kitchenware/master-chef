
include_recipe "apache2"

include_recipe "php5"


if node.apache2.mpm == "event"
  # Ensure it's uninstalled. In case of switch from prefork, it's cleaner
  package "libapache2-mod-php5" do
    action :remove
  end
  package "libapache2-mod-fastcgi" do
    action :install
    notifies :restart, "service[apache2]"
	# At install, ensure it's enabled and started
    notifies :enable, "service[php5-fpm]"
    notifies :start, "service[php5-fpm]"
  end
  apache2_enable_module "fastcgi"
  apache2_enable_module "actions"
  service "php5-fpm" do
    action :start
  end
else
  package "libapache2-mod-fastcgi" do
    action :remove
  end
  package "libapache2-mod-php5" do
    action :install
    notifies :restart, "service[apache2]"
    notifies :disable, "service[php5-fpm]"
  end
  apache2_enable_module "php5"
  template "/etc/php5/apache2/php.ini" do
    mode '0644'
    cookbook "php5"
    source "php5.ini.erb"
    variables node.php5.php_ini
    notifies :reload, "service[apache2]"
  end
  service "php5-fpm" do
    action :stop
  end
end

apache2_enable_module "setenvif"

apache2_configuration_file "https_php" do
  content "SetEnvIf X-Forwarded-Proto https HTTPS=on"
end

if node.php5.php_ini["error_log"]

  directory File.dirname(node.php5.php_ini["error_log"]) do
    owner "www-data"
    mode '0755'
    recursive true
  end

end

if node.apache2.default_vhost.enabled

  apache2_vhost "apache2:default_vhost" do
    options :cookbook => "apache2"
  end

end
