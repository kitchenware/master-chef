
define :apache2_disable_module, {
  :install => false,
} do

  apache2_disable_module_params = params

  execute "disable apache2 module #{apache2_disable_module_params[:name]}" do
    command "a2dismod #{apache2_disable_module_params[:name]}"
    only_if "dpkg-query -W libapache2-mod-#{apache2_disable_module_params[:name]}"
    notifies :restart, "service[apache2]"
  end

  node.set[:apache2][:modules_disabled] = [] unless node.apache2[:modules_disabled]
  node.set[:apache2][:modules_disabled] = node.set[:apache2][:modules_disabled] + [apache2_disable_module_params[:name]]

end
