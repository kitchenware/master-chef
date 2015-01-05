
base_user "collectd" do
  home node.collectd.home_directory
end

package node.collectd.package_name do
  options "--no-install-recommends"
  version node.collectd[:package_version] if node.collectd[:package_version]
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("collectd", ".*collectd.*")

service "collectd" do
  supports :status => true, :reload => true, :restart => true
  action auto_compute_action
end

directory node.collectd.config_directory do
  owner "collectd"
  mode '0755'
end

template "/etc/collectd/collectd.conf" do
  mode '0644'
  owner "collectd"
  source "collectd.conf.erb"
  variables :interval => node.collectd.interval, :directory => node.collectd.config_directory
  notifies :restart, "service[collectd]"
end

[
  "#{node.collectd.home_directory}/bin",
  "#{node.collectd.home_directory}/lib/",
  "#{node.collectd.home_directory}/lib/collectd",
  "#{node.collectd.home_directory}/lib/collectd/plugins",
  "#{node.collectd.home_directory}/lib/collectd/plugins/python",
  "#{node.collectd.home_directory}/lib/collectd/plugins/perl",
  "#{node.collectd.home_directory}/lib/collectd/plugins/perl/Collectd",
  "#{node.collectd.home_directory}/lib/collectd/plugins/perl/Collectd/Plugins",
].each do |x|
  directory x do
    owner "collectd"
  end
end

node.collectd.plugins.each do |name, config|
  collectd_plugin name do
    config config[:config] if config[:config]
  end
end

incremental_template "#{node.collectd.config_directory}/python.conf" do
  mode '0755'
  header <<-EOF
<LoadPlugin "python">
  Globals true
</LoadPlugin>
EOF
  header_if_block "<Plugin \"python\">"
  footer_if_block "</Plugin>"
  indentation 2
  owner "collectd"
  notifies :restart, "service[collectd]"
end

incremental_template "#{node.collectd.config_directory}/perl.conf" do
  mode '0755'
  header <<-EOF
<LoadPlugin "perl">
  Globals true
</LoadPlugin>
EOF
  header_if_block <<-EOF
<Plugin "perl">
  IncludeDir "#{node.collectd.home_directory}/lib/collectd/plugins/perl"
  BaseName "Collectd::Plugins"
EOF
  footer_if_block "</Plugin>"
  indentation 2
  owner "collectd"
  notifies :restart, "service[collectd]"
end

incremental_template "#{node.collectd.config_directory}/exec.conf" do
  mode '0755'
  header <<-EOF
LoadPlugin "exec"
EOF
  header_if_block "<Plugin \"exec\">"
  footer_if_block "</Plugin>"
  indentation 2
  owner "collectd"
  notifies :restart, "service[collectd]"
end

delayed_exec "Remove useless collectd plugin" do
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
