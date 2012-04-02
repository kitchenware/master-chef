
define :apache2_vhost, {
  :options => {}
} do
  apache2_vhost_params = params

  module_sym, vhost_sym = apache2_vhost_params[:name].split(':').map{|s| s.to_sym}
  config = node[module_sym][vhost_sym]

  apache2_listen = config[:listen]
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
    p auth_name
    basic_auth_conf += "AuthType Basic\n"
    basic_auth_conf += "AuthName #{auth_name}\n"
    basic_auth_conf += "AuthBasicProvider file\n"
    basic_auth_conf += "AuthUserFile /etc/apache2/#{basic_auth[:file]}.passwd\n"
    basic_auth_conf += "Require user graphite\n"
  end

  template "/etc/apache2/sites-enabled/#{vhost_sym.to_s}.conf" do
    source "#{vhost_sym.to_s}.conf.erb"
    mode 0644
    variables({:listen => apache2_listen, :basic_auth => basic_auth_conf, :description => apache2_description, :config => config}.merge(apache2_vhost_params[:options]))
    notifies :reload, resources(:service => "apache2")
  end

  if basic_auth
    template "/etc/apache2/#{basic_auth[:file]}.passwd" do
      cookbook basic_auth[:cookbook]
      source "#{basic_auth[:file]}.passwd.erb"
      mode 0644
      notifies :reload, resources(:service => "apache2")
    end
  end
  
end
