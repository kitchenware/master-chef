
define :apache2_vhost, {
  :options => {},
  :cookbook => nil
} do
  apache2_vhost_params = params

  config, vhost_sym = extract_config_with_last apache2_vhost_params[:name]

  apache2_listen = config[:listen]

  if apache2_listen =~ /^.*:\d+/
    node.set[:apache2][:ports] = [] unless node.apache2[:ports]
    node.set[:apache2][:ports] = node.set[:apache2][:ports] + [apache2_listen]
  end

  basic_auth = config[:basic_auth]

  apache2_description = ""
  if config[:domains] && config[:domains].size >= 1
    apache2_description = "ServerName #{config[:domains].first}"
    aliases = ""
    config[:domains][1..-1].each do |d|
      aliases += "#{d} "
    end
    apache2_description += "\nServerAlias #{aliases}\n" unless aliases.empty?
  end

  basic_auth_conf = ""
  if basic_auth

    apache2_enable_module "authz_user"
    apache2_enable_module "authn_file"
    apache2_enable_module "auth_basic"

    auth_name = basic_auth[:realm]
    basic_auth_conf += "AuthType Basic\n"
    basic_auth_conf += "AuthName \"#{auth_name}\"\n"
    basic_auth_conf += "AuthBasicProvider file\n"
    basic_auth_conf += "Require valid-user\n"

    if basic_auth[:file]
      basic_auth_conf += "AuthUserFile #{node.apache2.server_root}/#{basic_auth[:file]}.passwd\n"

      template "#{node.apache2.server_root}/#{basic_auth[:file]}.passwd" do
        cookbook basic_auth[:cookbook]
        source "#{basic_auth[:file]}.passwd.erb"
        mode 0644
        notifies :reload, resources(:service => "apache2")
      end
    end

    if basic_auth[:users]
      basic_auth_conf += "AuthUserFile #{node.apache2.server_root}/#{vhost_sym}.passwd\n"

      passwd = ""
      basic_auth[:users].each do |k, v|
        passwd += "#{k}:#{v.crypt('salt')}\n"
      end

      file "#{node.apache2.server_root}/#{vhost_sym}.passwd" do
        content passwd
        mode 0644
        notifies :reload, resources(:service => :apache2)
      end

    end

  end

  template "#{node.apache2.server_root}/sites-enabled/#{vhost_sym.to_s}.conf" do
    cookbook apache2_vhost_params[:cookbook] if apache2_vhost_params[:cookbook]
    source "#{vhost_sym.to_s}.conf.erb"
    mode 0644
    variables({
      :listen => apache2_listen,
      :basic_auth => basic_auth_conf,
      :description => apache2_description,
      :config => config
      }.merge(apache2_vhost_params[:options]))
    notifies :reload, resources(:service => "apache2")
  end

end
