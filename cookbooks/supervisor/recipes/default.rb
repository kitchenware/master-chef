
package "supervisor"

service "supervisor" do
  supports :status => true
  action auto_compute_action
end

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
