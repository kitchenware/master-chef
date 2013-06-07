package "memcached" do
	action :upgrade
end

service "memcached" do
	supports :status => true, :restart => true
	action [ :enable, :start ]
end

template "/etc/memcached.conf" do
  source "memcached.conf.erb"
  variables node.memcached.to_hash
  mode '0644'
  owner "root"
  group "root"
  notifies :restart, "service[memcached]"
end
