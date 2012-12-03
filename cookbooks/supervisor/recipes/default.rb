
include_recipe "sudo"

package "supervisor"

# http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=609457
if node.platform == "debian" || node.platform == "ubuntu"

  template "/etc/init.d/supervisor" do
    source "init_d"
    mode 0755
  end

end

template "/etc/default/supervisor" do
  source "supervisor.erb"
  variables :dodtime => Proc.new { find_resources_by_name_pattern(/^\/etc\/supervisor\/conf.d\/.*\.conf$/).length * node.supervisor.restart_delay_by_job }
  mode 0644
end


service "supervisor" do
  supports :status => true
  action auto_compute_action
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("supervisor", ".*supervisord.*")

delayed_exec "Remove useless supervisor config" do
  block do
    vhosts = find_resources_by_name_pattern(/^\/etc\/supervisor\/conf.d\/.*\.conf$/).map{|r| r.name}
    Dir["/etc/supervisor/conf.d/*.conf"].each do |n|
      unless vhosts.include? n
        Chef::Log.info "Removing supervisor config #{n}"
        File.unlink n
        notifies :restart, resources(:service => "supervisor")
      end
    end
  end
end
