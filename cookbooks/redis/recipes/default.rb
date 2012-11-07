package "redis-server"

service "redis-server" do
	supports :restart => true, :reload => true
	action [ :enable, :start ]
end

template "/etc/redis/redis.conf" do 
	source "redis.conf.erb"
	owner "redis"
	variables(
		:bind_address => node[:redis][:bind_address],
		:port => node[:redis][:port],
		:appendonly => node[:redis][:appendonly]
		)	
	notifies :restart, resources(:service => "redis-server")
end




