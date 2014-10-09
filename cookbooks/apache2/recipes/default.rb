
package "apache2-mpm-#{node.apache2.mpm}"

[
  "#{node.apache2.server_root}/sites-enabled/000-default",
  "#{node.apache2.server_root}/sites-available/default",
  "#{node.apache2.server_root}/sites-available/default-ssl",
  "#{node.apache2.server_root}/conf.d/security",
  "#{node.apache2.server_root}/httpd.conf",
  "#{node.apache2.server_root}/conf.d/other-vhosts-access-log",
  ].each do |f|
  # file is not used, because file provider generates a warning in 11.6,
  # because some of this files can be symlink
  ruby_block "remove file deployed by apache2 package #{f}" do
    block do
      File.unlink f if File.exists? f
    end
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
  mode '0644'
  notifies :restart, "service[apache2]"
end

template "#{node.apache2.server_root}/ports.conf" do
  source "ports.conf.erb"
  mode '0644'
  variables :ports => Proc.new{node.apache2[:ports] ? node.apache2.ports : ["80"]}
  notifies :restart, "service[apache2]"
end

node.apache2.modules.each do |m|
  apache2_enable_module m
end

delayed_exec "Remove useless apache2 vhost" do
  after_block_notifies :reload, resources(:service => "apache2")
  block do
    updated = false
    vhosts = find_resources_by_name_pattern(/^#{node.apache2.server_root}\/sites-enabled\/.*\.conf$/).map{|r| r.name}
    Dir["#{node.apache2.server_root}/sites-enabled/*.conf"].each do |n|
      unless vhosts.include? n
        Chef::Log.info "Removing vhost #{n}"
        File.unlink n
        updated = true
      end
    end
    updated
  end
end

delayed_exec "Remove useless apache2 modules" do
  after_block_notifies :restart, resources(:service => "apache2")
  block do
    updated = false
    modules = node.apache2[:modules_enabled] || []
    Dir["#{node.apache2.server_root}/mods-enabled/*.load"].each do |n|
      name = n.match(/\/([^\/]+).load$/)[1]
      unless modules.include? name
        Chef::Log.info "Disabling module #{name}"
        %x{a2dismod #{name}}
        updated = true
      end
    end
    updated
  end
end

delayed_exec "Remove useless apache2 configuration file" do
  after_block_notifies :restart, resources(:service => "apache2")
  block do
    updated = false
    conf_enabled = find_resources_by_name_pattern(/^\/etc\/apache2\/conf.d\/.*$/).map { |r| r.name }
    Dir["/etc/apache2/conf.d/*"].each do |n|
      Kernel.system "dpkg -S #{n} > /dev/null 2>&1"
      is_system_file = $?.exitstatus == 0
      unless is_system_file || conf_enabled.include?(n)
        Chef::Log.info "Removing apache2 configuration file #{n}"
        %x{rm #{n}}
        updated = true
      end
    end
    updated
  end
end

# when reloading conf, apache2 is not stopped
# if a reload failed, chef regenerates config files, and try to start apache
# it's work because apache2 is already launched, and loaded conf in apache2 is different
# from conf on disk
delayed_exec "Check apache2 config" do
  after_block_notifies :restart, resources(:service => "apache2")
  block do
    %x{apachectl configtest 2>&1 > /dev/null}
    $?.exitstatus != 0
  end
end
