include_recipe "nodejs"

include_recipe "libzmq"

base_user node.logstash.user

directory node.logstash.config_directory

nodejs_app "logstash" do
  user node.logstash.user
  directory node.logstash.directory
  script "bin/node-logstash-agent"
  opts "--config_directory #{node.logstash.config_directory}"
  directory_check "#{node.logstash.directory}/current/node_modules"
end

git_clone "#{node.logstash.directory}/current" do
  reference node.logstash.version
  repository node.logstash.git
  user node.logstash.user
end

template "#{node.logstash.directory}/current/.node_version" do
  owner node.logstash.user
  source "node_version.erb"
  variables :node_version => node.logstash.node_version
end

execute_version "install node-logstash dependencies" do
  user node.logstash.user
  command "export HOME=#{get_home node.logstash.user} && cd #{node.logstash.directory}/current && $HOME/.warp/client/node/install.sh"
  version node.logstash.node_version + '_' + node.logstash.version
  notifies :restart, resources(:service => "logstash")
end