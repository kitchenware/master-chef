
define :apache2_enable_module, {
  :install => false,
  :disable_pattern => nil,
} do

  apache2_enable_module_params = params

  if apache2_enable_module_params[:install]
    package "libapache2-mod-#{apache2_enable_module_params[:name]}"
  end

  if apache2_enable_module_params[:disable_pattern]
    ruby_block "disable modules #{apache2_enable_module_params[:disable_pattern]}" do
      block do
        Dir["#{node.apache2.server_root}/mods-enabled/#{apache2_enable_module_params[:disable_pattern]}.load"].each do |x|
          m = File.basename(x).match(/(.*)\.load/)[1]
          next if m == apache2_enable_module_params[:name]
          Chef::Log.info("Disabling #{m}")
          %x{a2dismod -f #{m}}
        end
      end
    end
  end

  execute "enable apache2 module #{apache2_enable_module_params[:name]}" do
    command "a2enmod #{apache2_enable_module_params[:name]}"
    notifies :restart, "service[apache2]"
    not_if "[ -h #{node.apache2.server_root}/mods-enabled/#{apache2_enable_module_params[:name]}.load ]"
  end

  node.set[:apache2][:modules_enabled] = [] unless node.apache2[:modules_enabled]
  node.set[:apache2][:modules_enabled] = node.set[:apache2][:modules_enabled] + [apache2_enable_module_params[:name]]

end
