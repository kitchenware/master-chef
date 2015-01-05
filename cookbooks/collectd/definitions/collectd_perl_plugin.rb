
define :collectd_perl_plugin, {
  :config => nil,
  :template_cookbook => nil,
  :conf_file_name => nil,
  :perl_file_name => nil,
  :perl_plugin_name => nil,
} do

  collectd_perl_plugin_params = params

  collectd_perl_plugin_params[:conf_file_name] ||= "#{collectd_perl_plugin_params[:name]}.conf.erb"
  collectd_perl_plugin_params[:perl_file_name] ||= "#{collectd_perl_plugin_params[:name]}.pm.erb"
  collectd_perl_plugin_params[:perl_plugin_name] ||= collectd_perl_plugin_params[:name]

  template "#{node.collectd.home_directory}/lib/collectd/plugins/perl/Collectd/Plugins/#{collectd_perl_plugin_params[:perl_plugin_name]}.pm" do
    variables collectd_perl_plugin_params[:config] if collectd_perl_plugin_params[:config]
    cookbook collectd_perl_plugin_params[:template_cookbook] if collectd_perl_plugin_params[:template_cookbook]
    source collectd_perl_plugin_params[:perl_file_name]
    mode '0644'
    owner 'collectd'
    notifies :restart, "service[collectd]"
  end

  incremental_template_part collectd_perl_plugin_params[:name] do
    cookbook collectd_perl_plugin_params[:template_cookbook] if collectd_perl_plugin_params[:template_cookbook]
    target "#{node.collectd.config_directory}/perl.conf"
    source collectd_perl_plugin_params[:conf_file_name]
    variables collectd_perl_plugin_params[:config] if collectd_perl_plugin_params[:config]
  end

end