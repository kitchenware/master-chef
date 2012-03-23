
define :collectd_plugin, {
  :config => nil
} do

  collectd_plugin_params = params

  template "/etc/collectd/collectd.d/#{collectd_plugin_params[:name]}.conf" do
    cookbook "collectd"
    source "plugin.conf.erb"
    mode 0755
    variables :name => collectd_plugin_params[:name], :config => collectd_plugin_params[:config]
    notifies :restart, resources(:service => "collectd")
  end

end