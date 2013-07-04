
include_recipe "unicorn"

base_user node.kibana.user

warp_install node.kibana.user do
  rbenv true
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("kibana", ".*kibana.*")

unicorn_app 'kibana' do
  user node.kibana.user
  location node.kibana.location
  app_directory node.kibana.directory
end

deployed_files = %w{Gemfile Gemfile.lock .rbenv-version .rbenv-gemsets}

directory "#{node.kibana.directory}/shared/files" do
  owner node.kibana.user
end

deployed_files.each do |f|
  template "#{node.kibana.directory}/shared/files/#{f}" do
    owner node.kibana.user
    source "kibana2/#{f}"
  end
end

cp_command = deployed_files.map{|f| "cp #{node.kibana.directory}/shared/files/#{f} #{node.kibana.directory}/current/#{f}"}.join(' && ')

git_clone "#{node.kibana.directory}/current" do
  user node.kibana.user
  reference node.kibana.version
  repository node.kibana.git
  notifies :restart, "service[kibana]"
end

ruby_rbenv_command "initialize kibana" do
  user node.kibana.user
  directory "#{node.kibana.directory}/current"
  code "rm -f .warped && #{cp_command} && rbenv warp install"
  environment get_proxy_environment
  version node.kibana.version
  notifies :restart, "service[kibana]"
end

elasticsearch_servers = node.kibana.config.elasticsearch
elasticsearch_servers = [elasticsearch_servers] if elasticsearch_servers.is_a? String

template "#{node.kibana.directory}/current/KibanaConfig.rb" do
  owner node.kibana.user
  source "kibana2/KibanaConfig.rb.erb"
  variables({:elasticsearch_servers => elasticsearch_servers}.merge(node.kibana.config))
  notifies :restart, "service[kibana]"
end
