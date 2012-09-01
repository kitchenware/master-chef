
package "apache2-mpm-#{node.apache2.mpm}"

[
  "#{node.apache2.server_root}/sites-enabled/000-default",
  "#{node.apache2.server_root}/sites-available/default",
  "#{node.apache2.server_root}/sites-available/default-ssl",
  "#{node.apache2.server_root}/conf.d/security",
  "#{node.apache2.server_root}/conf.d/other-vhosts-access-log",
  ].each do |f|
  file f do
    action :delete
  end
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("apache2", "\\/etc\\/apache2.*")

service "apache2" do
  supports :status => true, :restart => true, :reload => true
  action auto_compute_action
end

template "#{node.apache2.server_root}/apache2.conf" do
  if node.apache2.mpm_config.prefork == "auto"
    mpm_auto = {
      :prefork => {
        :start => node.cpu.total * 4,
        :min_spare => node.cpu.total * 8,
        :max_spare => node.cpu.total * 16,
        :server_limit => node.cpu.total * 512,
        :max_clients => node.cpu.total * 512,
        :max_request_per_child => node.cpu.total * 1024,
      }
    }
    variables :mpm => mpm_auto, :tuning => node.apache2.tuning, :server_root => node.apache2.server_root, :log_directory => node.apache2.log_directory
  else
    variables :mpm => node.apache2.mpm_config, :tuning => node.apache2.tuning, :server_root => node.apache2.server_root, :log_directory => node.apache2.log_directory
  end
  source "apache2.conf.erb"
  mode 0644
  notifies :restart, resources(:service => "apache2")
end

template "#{node.apache2.server_root}/ports.conf" do
  source "ports.conf.erb"
  mode 0644
  variables :ports => Proc.new{node.apache2.ports == [] ? ["80"] : node.apache2.ports}
  notifies :restart, resources(:service => "apache2")
end

node.apache2.modules.each do |m|
  apache2_enable_module m
end

delayed_exec "Remove useless apache2 vhost" do
  block do
    vhosts = find_resources_by_name_pattern(/^#{node.apache2.server_root}\/sites-enabled\/.*\.conf$/).map{|r| r.name}
    Dir["#{node.apache2.server_root}/sites-enabled/*.conf"].each do |n|
      unless vhosts.include? n
        Chef::Log.info "Removing vhost #{n}"
        File.unlink n
        notifies :reload, resources(:service => "apache2")
      end
    end
  end
end

delayed_exec "Remove useless apache2 modules" do
  block do
    modules = node.apache2[:modules_enabled] || []
    Dir["#{node.apache2.server_root}/mods-enabled/*.load"].each do |n|
      name = n.match(/\/([^\/]+).load$/)[1]
      unless modules.include? name
        Chef::Log.info "Disabling module #{name}"
        %x{a2dismod #{name}}
        notifies :restart, resources(:service => "apache2")
      end
    end
  end
end
