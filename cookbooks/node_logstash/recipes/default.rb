include_recipe "nodejs"

include_recipe "libzmq"

base_user node.node_logstash.user

directory node.node_logstash.config_directory

nodejs_app "logstash" do
  user node.node_logstash.user
  directory node.node_logstash.directory
  script "bin/node-logstash-agent"
  opts "--config_dir #{node.node_logstash.config_directory}"
  directory_check "#{node.node_logstash.directory}/current/node_modules"
end

git_clone "#{node.node_logstash.directory}/current" do
  reference node.node_logstash.version
  repository node.node_logstash.git
  user node.node_logstash.user
end

template "#{node.node_logstash.directory}/current/.node_version" do
  owner node.node_logstash.user
  source "node_version.erb"
  variables :node_version => node.node_logstash.node_version
end

execute_version "install node-logstash dependencies" do
  user node.node_logstash.user
  command "export HOME=#{get_home node.node_logstash.user} && cd #{node.node_logstash.directory}/current && rm -rf node_modules && $HOME/.warp/client/node/install.sh"
  version node.node_logstash.node_version + '_' + node.node_logstash.version
  notifies :restart, resources(:service => "logstash")
end

if node.node_logstash.configs

  node.node_logstash.configs.each do |k, v|
    node_logstash_config k do
      urls v
    end
  end

end