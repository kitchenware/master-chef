
# debian sqeeze : 2.4 : redis-server.pid
# debian wheezy : 2.4 : redis-server.pid
# ubuntu precise : 2.2 : redis-server.pid
# ubuntu lucid : 2.2 : redid.pid

redis_package_options = nil
redis_config_file = "redis.conf.erb"

if node.lsb.codename == "squeeze" && node.apt.master_chef_add_apt_repo

  add_apt_repository "squeeze-backports" do
    url "http://backports.debian.org/debian-backports"
    distrib "squeeze-backports"
  end

  # awfull, cf http://tickets.opscode.com/browse/CHEF-1547
  redis_package_version = "2:2.4.15-1~bpo60+2"

end

if node.lsb.codename == "lucid" && node.apt.master_chef_add_apt_repo

  add_apt_repository "ppa_redis" do
    url "http://ppa.launchpad.net/rwky/redis/ubuntu"
    key "5862E31D"
    key_server "keyserver.ubuntu.com"
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
	notifies :restart, "service[redis-server]"
end
