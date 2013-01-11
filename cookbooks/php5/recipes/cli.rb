
include_recipe "php5"

package "php5-cli"

template "/etc/php5/cli/php.ini" do
  mode '0644'
  cookbook "php5"
  source "php5.ini.erb"
  variables node.php5.cli_php_ini
end