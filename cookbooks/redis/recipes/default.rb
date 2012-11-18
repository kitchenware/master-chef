package "redis-server"

service "redis-server" do
	supports :restart => true, :reload => true
	action [ :enable, :start ]
end

redis_config_template = "redis.conf.erb"

redis_config_template = "redis-2.1.conf.erb" if ["squeeze", "lucid"].include? node.lsb.codename

template "/etc/redis/redis.conf" do
	source redis_config_template
	owner "redis"
	variables node.redis
	notifies :restart, resources(:service => "redis-server")
end
