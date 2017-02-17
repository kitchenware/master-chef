
node.set[:nginx][:default_vhost][:enabled] = false

include_recipe "nginx"

conf = {
  :path => "#{node.cabot.root}/current",
  :cabot_port => node.cabot.nginx.cabot.cabot_port
}

conf[:google_auth_proxy_port] = node.cabot.google_auth_proxy_port
conf[:token] = node.cabot.x_auth_token

nginx_vhost "cabot:nginx:cabot" do
  options conf
end
