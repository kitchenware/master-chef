define :nginx_vhost, {
  :options => {}
} do
  nginx_vhost_params = params

  config, vhost_sym = extract_config_with_last nginx_vhost_params[:name]

  nginx_listen = "listen #{config[:listen]};\n"
  nginx_listen += "server_name #{config[:virtual_host]};\n" if config[:virtual_host]
  basic_auth = config[:basic_auth]

  ssl = config[:ssl]

  if ssl
    nginx_listen += "ssl on;\n";
    nginx_listen += "ssl_certificate /etc/nginx/#{vhost_sym}.crt;\n"
    nginx_listen += "ssl_certificate_key /etc/nginx/#{vhost_sym}.key;\n"

    %w{key crt}.each do |ext|
      template "/etc/nginx/#{vhost_sym}.#{ext}" do
        cookbook ssl[:cookbook]
        source ssl[ext.to_sym]
        mode 0600
        owner "www-data"
      end
    end

  end

  auth = ""
  if basic_auth
    auth += "\n"
    auth += "auth_basic \"#{basic_auth[:realm]}\";\n"

    if basic_auth[:file]
      auth += "auth_basic_user_file /etc/nginx/#{basic_auth[:file]}.passwd;\n"

      template "/etc/nginx/#{basic_auth[:file]}.passwd" do
        cookbook basic_auth[:cookbook]
        source "#{basic_auth[:file]}.passwd.erb"
        mode 0644
        notifies :reload, resources(:service => "nginx")
      end
    end

    if basic_auth[:users]
      auth += "auth_basic_user_file /etc/nginx/#{vhost_sym}.passwd;\n"

      passwd = ""
      basic_auth[:users].each do |k, v|
        passwd += "#{k}:#{v.crypt('salt')}\n"
      end

      file "/etc/nginx/#{vhost_sym}.passwd" do
        content passwd
        mode 0644
        notifies :reload, resources(:service => :nginx)
      end

    end

  end

  template "/etc/nginx/sites-enabled/#{vhost_sym.to_s}.conf" do
    source nginx_vhost_params[:options][:source] || "#{vhost_sym.to_s}.conf.erb"
    mode 0644
    variables({:listen => nginx_listen + auth, :listen_no_auth => nginx_listen, :config => config, :server_tokens => 'Off'}.merge(nginx_vhost_params[:options]))
    notifies :reload, resources(:service => "nginx")
  end

end
