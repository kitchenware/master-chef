
redis_package_options = nil
redis_config_file = "redis.conf.erb"

if node.lsb.codename == "squeeze" && node.apt.master_chef_add_apt_repo

  add_apt_repository "squeeze-backports" do
    url "http://backports.debian.org/debian-backports"
    distrib "squeeze-backports"
    components ["main"]
  end

  # awfull, cf http://tickets.opscode.com/browse/CHEF-1547
  redis_package_version = "2:2.4.15-1~bpo60+2"

end

if node.lsb.codename == "lucid" && node.apt.master_chef_add_apt_repo

  base_ppa "redis" do
    url "ppa:rwky/redis"
  end

  redis_config_file = "redis-2.6.conf.erb"

end

package "redis-server" do
  version redis_package_version if redis_package_version
end

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
