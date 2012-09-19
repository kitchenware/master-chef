
include_recipe "collectd"

execute_version "bucky" do
  command "cd /tmp && curl --location #{node.graphite.bucky.url} -o bucky.tar.gz && tar xvzf bucky.tar.gz && cd #{File.basename(node.graphite.bucky.url)[0..-8]} && python setup.py install"
  version File.basename(node.graphite.bucky.url)
end

directory "/etc/bucky" do
  mode 0755
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("bucky", "\\/etc\\/bucky\\/.*")

basic_init_d "bucky" do
  daemon "/usr/local/bin/bucky"
  options "/etc/bucky/bucky.conf"
  file_check "/etc/bucky/bucky.conf"
  user "www-data"
end

template "/etc/bucky/bucky.conf" do
  source "bucky.conf.erb"
  mode 0644
  variables :bucky_port => node.graphite.bucky.collectd_port
  notifies :restart, resources(:service => "bucky")
end
