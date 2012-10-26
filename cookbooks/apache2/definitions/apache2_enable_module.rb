
define :apache2_enable_module, {
  :install => false,
} do

  apache2_enable_module_params = params

  if apache2_enable_module_params[:install]
    package "libapache2-mod-#{apache2_enable_module_params[:name]}"
  end

  bash "enable apache2 module #{apache2_enable_module_params[:name]}" do
    code "a2enmod #{apache2_enable_module_params[:name]}"
    notifies :restart, resources(:service => "apache2")
    not_if "[ -h #{node.apache2.server_root}/mods-enabled/#{apache2_enable_module_params[:name]}.load ]"
  end

  node.set[:apache2][:modules_enabled] = [] unless node.apache2[:modules_enabled]
  node.set[:apache2][:modules_enabled] = node.set[:apache2][:modules_enabled] + [apache2_enable_module_params[:name]]

end
