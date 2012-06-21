
include_recipe "apache2"
include_recipe "php5"

apache2_vhost "apache2:default_vhost" do
  options :document_root => "/var/www"
  cookbook "apache2"
end

php5_apache2 "php5" do
  options node.php5[:apache2]
end
