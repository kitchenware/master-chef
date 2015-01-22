
define :apache2_disable_module, {
} do

  apache2_disable_module_params = params

  execute "enable apache2 module #{apache2_disable_module_params[:name]}" do
    command "a2dismod #{apache2_disable_module_params[:name]}"
    notifies :restart, "service[apache2]"
    only_if "[ -h #{node.apache2.server_root}/mods-enabled/#{apache2_disable_module_params[:name]}.load ]"
  end

end
