
include_recipe "php5::apache2"

php5_module "curl"

git_clone "/var/www/kibana" do
  user "root"
  reference node.kibana.version
  repository node.kibana.git
end

template "/var/www/kibana/config.php" do
  source "kibana_config.php.erb"
  mode 0644
  variables :elasticsearch_server => "localhost:#{node.elasticsearch.http_port}"
end