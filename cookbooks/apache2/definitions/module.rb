
define :apache2_enable_module, {
  :install => false,
} do

  apache2_enable_module_params = params

  if apache2_enable_module_params[:install]
    package "libapache2-mod-#{apache2_enable_module_params[:name]}"
  end

  bash "enable apache2 module #{apache2_enable_module_params[:name]}" do
    code "a2enmod #{apache2_enable_module_params[:name]}"
    notifies :reload, resources(:service => "apache2")
    not_if "[ -h /etc/apache2/mods-enabled/#{apache2_enable_module_params[:name]}.load ]"
  end

end