
define :collectd_plugin, {
  :config => nil
} do

  collectd_plugin_params = params

  template "/etc/collectd/collectd.d/#{collectd_plugin_params[:name]}.conf" do
    cookbook "collectd"
    source "plugin.conf.erb"
    variables :name => collectd_plugin_params[:name], :config => collectd_plugin_params[:config]
    notifies :reload, resources(:service => "collectd")
  end

end