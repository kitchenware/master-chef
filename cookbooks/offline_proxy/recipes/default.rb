include_recipe "nodejs"

base_user node.offline_proxy.user

warp_install node.offline_proxy.user do
  nvm true
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("offline_proxy", ".*offline_proxy.*")

nodejs_app "offline_proxy" do
  user node.offline_proxy.user
  directory node.offline_proxy.app_directory
  script "proxy.js"
  opts node.offline_proxy.opts
  check_start :max_delay => 10
end

directory "#{node.offline_proxy.app_directory}/shared/storage" do
  owner node.offline_proxy.user
end

git_clone "#{node.offline_proxy.app_directory}/current" do
  user node.offline_proxy.user
  repository "https://github.com/bpaquet/offline-proxy.git"
  reference "master"
  notifies :restart, "service[offline_proxy]"
end

link "#{node.offline_proxy.app_directory}/current/storage" do
  to "#{node.offline_proxy.app_directory}/shared/storage"
end

logrotate_file "offline_proxy" do
  user node.offline_proxy.user
  group node.offline_proxy.user
  files [
    "#{node.offline_proxy.app_directory}/shared/log/proxy.log",
    "#{node.offline_proxy.app_directory}/shared/log/proxy_stdout.log"
  ]
  variables :post_rotate => "kill -USR2 `cat #{node.offline_proxy.app_directory}/shared/proxy.pid`"
end

execute "install node and modules for offline_proxy" do
  user "deploy"
  command "export HOME=/home/#{node.offline_proxy.user} && cd #{node.offline_proxy.app_directory}/current && NO_WARP=1 $HOME/.warp/client/node/install.sh"
  notifies :restart, "service[offline_proxy]"
end



