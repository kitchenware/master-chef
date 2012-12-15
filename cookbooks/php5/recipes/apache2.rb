
include_recipe "apache2"
include_recipe "php5"

if node.apache2.default_vhost.enable
  
  apache2_vhost "apache2:default_vhost" do
    options :cookbook => "apache2"
  end
  
end

php5_apache2 "php5" do
  options node.php5[:apache2]
end
