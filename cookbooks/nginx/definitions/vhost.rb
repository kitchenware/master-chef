define :nginx_vhost, {
  :options => {}
} do
  nginx_vhost_params = params
  
  module_sym, vhost_sym = nginx_vhost_params[:name].split(':').map{|s| s.to_sym}
  
  config = node[module_sym][vhost_sym]

  nginx_listen = "listen #{config[:listen]};\n"
  nginx_listen += "server_name #{config[:virtual_host]};\n" if config[:virtual_host]
  basic_auth = config[:basic_auth]
  
  if basic_auth
    nginx_listen += "\n"
    nginx_listen += "auth_basic \"#{basic_auth[:realm]}\";\n"
    nginx_listen += "auth_basic_user_file /etc/nginx/#{basic_auth[:file]}.passwd;\n"
  end

  template "/etc/nginx/sites-enabled/#{vhost_sym.to_s}.conf" do
    source "#{vhost_sym.to_s}.conf.erb"
    mode 0644
    variables({:listen => nginx_listen, :config => node[module_sym][vhost_sym]}.merge(nginx_vhost_params[:options]))
    notifies :reload, resources(:service => "nginx")
  end

  if basic_auth

    template "/etc/nginx/#{basic_auth[:file]}.passwd" do
      cookbook basic_auth[:cookbook]
      source "#{basic_auth[:file]}.passwd.erb"
      mode 0644
      notifies :reload, resources(:service => "nginx")
    end

  end
  
end
