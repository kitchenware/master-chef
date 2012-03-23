
package "collectd-core" do
  options "--no-install-recommends"
end


Chef::Config.exception_handlers << ServiceErrorHandler.new("collectd", ".*collectd.*")

service "collectd" do
  supports :status => true, :reload => true, :restart => true
  action [ :enable, :start ]
end

directory "/etc/collectd/collectd.d" do
  mode 0755
end

template "/etc/collectd/collectd.conf" do
  mode 0644
  source "collectd.conf.erb"
  notifies :reload, resources(:service => "collectd")
end

node.collectd.default_plugins.each do |p|
  collectd_plugin p
end

