
package "exim4"

Chef::Config.exception_handlers << ServiceErrorHandler.new("exim4", "exim")

service "exim4" do
  supports :status => true, :reload => true, :restart => true
  action auto_compute_action
end

template "/etc/exim4/exim4.conf" do
  source "exim4.conf.erb"
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[exim4]"
end

if node.exim4[:passwd]
	file "/etc/exim4/passwd.client" do
		content node.exim4.passwd.join("\n")
		notifies :restart, "service[exim4]"
	end
end
