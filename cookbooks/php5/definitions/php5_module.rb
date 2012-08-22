
define :php5_module, {
} do

  php5_module_params = params

  package "php5-#{php5_module_params[:name]}" do
    notifies :reload, resources(:service => "apache2") if find_resources_by_name_pattern(/^apache2$/).size > 0
  end

end
