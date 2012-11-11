package "redis-server"

service "redis-server" do
	supports :restart => true, :reload => true
	action [ :enable, :start ]
end

template "/etc/redis/redis.conf" do
	source "redis.conf.erb"
	owner "redis"
	variables node.redis
	notifies :restart, resources(:service => "redis-server")
end




