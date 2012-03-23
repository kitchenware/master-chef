
define :php5_apache2, {
  :options => {}
} do

  php5_apache2_params = params

  package "libapache2-mod-php5" do
    notifies :reload, resources(:service => "apache2")
  end

  options = {}
  php5_apache2_params[:options].each do |k, v|
    options[k.is_a?(String) ? k : k.to_s] = v
  end

  template "/etc/php5/apache2/php.ini" do
    cookbook "php5"
    source "php5.ini.erb"
    variables node.php5.php_ini.to_hash.merge(options)
    notifies :reload, resources(:service => "apache2")
  end

end