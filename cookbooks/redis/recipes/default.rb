
redis_config_file = "redis.conf.erb"

if node.lsb.codename == "squeeze"

  add_apt_repository "squeeze-backports" do
    url "http://backports.debian.org/debian-backports"
    distrib "squeeze-backports"
    components ["main"]
  end

end

if node.lsb.codename == "lucid"

  base_ppa "redis" do
    url "ppa:rwky/redis"
  end

  redis_config_file = "redis-2.6.conf.erb"

end

package "redis-server"

service "redis-server" do
	supports :restart => true, :reload => true
	action [ :enable, :start ]
end

template "/etc/redis/redis.conf" do
	source redis_config_file
	owner "redis"
	variables node.redis
	notifies :restart, resources(:service => "redis-server")
end
