include_recipe "nodejs"

nodejs_app "statsd" do
  user node.graphite.statsd.user
  script "stats.js"
  directory node.graphite.statsd.directory
  file_check ["#{node.graphite.statsd.directory}/current/.node_version"]
  opts "/etc/statsd.conf"
  add_log_param false
end

template "/etc/statsd.conf" do
  owner node.graphite.statsd.user
  mode 0644
  source "statsd.conf.erb"
  variables :config => node.graphite.statsd.to_hash
  notifies :restart, resources(:service => "statsd")
end

git_clone "#{node.graphite.statsd.directory}/current" do
  reference node.graphite.statsd.version
  repository node.graphite.statsd.git
  user node.graphite.statsd.user
end

bash "install nodejs for statsd" do
  user node.graphite.statsd.user
  code "export HOME=#{get_home node.graphite.statsd.user} && cd #{node.graphite.statsd.directory}/current && $HOME/.warp/client/node/install_node.sh"
  notifies :restart, resources(:service => "statsd")
  action :nothing
end

template "#{node.graphite.statsd.directory}/current/.node_version" do
  owner node.graphite.statsd.user
  mode 0644
  source "statsd_node_version.erb"
  variables :config => node.graphite.statsd.to_hash
  notifies :run, resources(:bash => "install nodejs for statsd"), :immediately
end