
include_recipe "collectd"

directory "/etc/bucky" do
  mode '0755'
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("bucky", "\\/etc\\/bucky\\/.*")

basic_init_d "bucky" do
  daemon "/usr/local/bin/bucky"
  options "/etc/bucky/bucky.conf"
  file_check ["/etc/bucky/bucky.conf"]
  user "www-data"
end

template "/etc/bucky/bucky.conf" do
  source "bucky.conf.erb"
  mode '0644'
  variables :bucky_port => node.graphite.bucky.collectd_port
  notifies :restart, "service[bucky]"
end


execute "install bucky" do
  command "pip install bucky==#{node.graphite.bucky.version}"
  environment get_proxy_environment
  not_if "pip show bucky | grep Version | grep #{node.graphite.bucky.version}"
end
