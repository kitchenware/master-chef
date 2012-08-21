
include_recipe "collectd"

execute "install bucky" do
  command "cd /tmp && wget #{node.graphite.packages.bucky_url} -O bucky.tar.gz && tar xvzf bucky.tar.gz && cd #{File.basename(node.graphite.packages.bucky_url)[0..-8]} && python setup.py install"
  not_if "[ -x /usr/local/bin/bucky ]"
end

directory "/etc/bucky" do
  mode 0755
end

basic_init_d "bucky" do
  daemon "/usr/local/bin/bucky"
  options "/etc/bucky/bucky.conf"
  file_check "/etc/bucky/bucky.conf"
  user "www-data"
end

template "/etc/bucky/bucky.conf" do
  source "bucky.conf.erb"
  mode 0644
  notifies :restart, resources(:service => "bucky")
end
