
package "collectd-core" do
  options "--no-install-recommends"
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("collectd", ".*collectd.*")

service "collectd" do
  supports :status => true, :reload => true, :restart => true
  action auto_compute_action
end

directory node.collectd.config_directory do
  mode '0755'
end

template "/etc/collectd/collectd.conf" do
  mode '0644'
  source "collectd.conf.erb"
  variables :interval => node.collectd.interval
  notifies :restart, "service[collectd]"
end

node.collectd.plugins.each do |name, config|
  collectd_plugin name do
    config config[:config] if config[:config]
  end
end

if node.collectd.python_plugin.enabled

  incremental_template node.collectd.python_plugin.file do
    mode '0755'
    header <<-EOF
<LoadPlugin python>
  Globals true
</LoadPlugin>

EOF
    notifies :restart, "service[collectd]"
  end

end

delayed_exec "Remove collectd plugin" do
  after_block_notifies :restart, "service[collectd]"
  block do
    updated = false
    plugins = find_resources_by_name_pattern(/^#{node.collectd.config_directory}.*\.conf$/).map{|r| r.name}
    Dir["#{node.collectd.config_directory}/*.conf"].each do |n|
      unless plugins.include? n
        Chef::Log.info "Removing plugin #{n}"
        File.unlink n
        updated = true
      end
    end
    updated
  end
end
