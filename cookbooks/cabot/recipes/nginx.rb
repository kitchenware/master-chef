
node.set[:nginx][:default_vhost][:enabled] = false

include_recipe "nginx"

nginx_vhost "cabot:nginx:cabot" do
  options :path => "#{node.cabot.root}/current", :cabot_port => node.cabot.nginx.cabot.cabot_port
end