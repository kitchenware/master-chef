
define :collectd_plugin, {
  :config => nil
} do

  collectd_plugin_params = params

  template "#{node.collectd.config_directory}/#{collectd_plugin_params[:name]}.conf" do
    cookbook "collectd"
    source "plugin.conf.erb"
    mode '0755'
    variables :name => collectd_plugin_params[:name], :config => collectd_plugin_params[:config]
    notifies :restart, "service[collectd]"
  end

end