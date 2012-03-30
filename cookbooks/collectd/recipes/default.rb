
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
  variables :interval => node.collectd.interval
  notifies :restart, resources(:service => "collectd")
end

node.collectd.default_plugins.each do |p|
  collectd_plugin p
end

collectd_plugin "syslog" do
  config "LogLevel \"#{node.collectd.log_level}\""
end

delayed_exec "Remove collectd plugin" do
  block do
    plugins = find_resources_by_name_pattern(/^\/etc\/collectd\/collectd.d\/.*\.conf$/).map{|r| r.name}
    Dir["/etc/collectd/collectd.d/*.conf"].each do |n|
      unless plugins.include? n
        Chef::Log.info "Removing plugin #{n}"
        File.unlink n
        notifies :restart, resources(:service => "collectd")
      end
    end
  end

end
