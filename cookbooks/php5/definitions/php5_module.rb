
define :php5_module, {
} do

  php5_module_params = params

  package "php5-#{php5_module_params[:name]}" do
  	#tmp test to avoid php5-fpm installation
  	options "--no-install-recommends"
    notifies :reload, resources(:service => "apache2") if find_resources_by_name_pattern(/^apache2$/).size > 0
    notifies :reload, resources(:service => "php5-fpm") if find_resources_by_name_pattern(/^php5-fpm$/).size > 0
  end

end
