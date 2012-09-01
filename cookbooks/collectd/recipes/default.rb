
package "collectd-core" do
  options "--no-install-recommends"
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("collectd", ".*collectd.*")

service "collectd" do
  supports :status => true, :reload => true, :restart => true
  action auto_compute_action
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

node.collectd.plugins.each do |name, config|
  collectd_plugin name do
    config config[:config] if config[:config]
  end
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
