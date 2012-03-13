
define :apache2_enable_module, {
  
} do

  apache2_enable_module_params = params

  bash "enable apache2 module #{apache2_enable_module_params[:name]}" do
    code "a2enmod #{apache2_enable_module_params[:name]}"
    notifies :reload, resources(:service => "apache2")
    not_if "[ -h /etc/apache2/mods-enabled/#{apache2_enable_module_params[:name]} ]"
  end

end