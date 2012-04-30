define :nginx_vhost, {
  :options => {}
} do
  nginx_vhost_params = params

  config, vhost_sym = extract_config_with_last nginx_vhost_params[:name]
  
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
    variables({:listen => nginx_listen, :config => config, :server_tokens => 'Off'}.merge(nginx_vhost_params[:options]))
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
