
include_recipe "sudo"

package "supervisor"

if node.supervisor.service_name != "supervisor" && (node.platform == "debian" || node.platform == "ubuntu")

  if File.exist? "/etc/init.d/supervisor"

    service "supervisor" do
      action [:disable, :stop]
    end

  end

  file "/etc/init.d/supervisor" do
    action :delete
  end

end

basic_init_d node.supervisor.service_name do
  daemon "/usr/bin/supervisord"
  make_pidfile false
  check_stop({
    :term_time => Proc.new { find_resources_by_name_pattern(/^\/etc\/supervisor\/conf.d\/.*\.conf$/).length * node.supervisor.restart_delay_by_job },
    :kill_time => Proc.new { 5 },
  })
end

service node.supervisor.service_name do
  supports :status => true, :restart => true
  action auto_compute_action
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("supervisor", ".*supervisord.*")

delayed_exec "Remove useless supervisor config" do
  after_block_notifies :restart, resources(:service => node.supervisor.service_name)
  block do
    updated = false
    vhosts = find_resources_by_name_pattern(/^\/etc\/supervisor\/conf.d\/.*\.conf$/).map{|r| r.name}
    Dir["/etc/supervisor/conf.d/*.conf"].each do |n|
      unless vhosts.include? n
        Chef::Log.info "Removing supervisor config #{n}"
        File.unlink n
        updated = true
      end
    end
    updated
  end
end
