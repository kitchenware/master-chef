
define :apache2_vhost, {
  :options => {}
} do
  apache2_vhost_params = params

  module_sym, vhost_sym = apache2_vhost_params[:name].split(':').map{|s| s.to_sym}
  config = node[module_sym][vhost_sym]

  apache2_listen = config[:listen]

  apache2_description = ""
  if config[:domains] && config[:domains].size >= 1
    apache2_description = "ServerName #{config[:domains].first}"
    aliases = ""
    config[:domains][1..-1].each do |d|
      aliases += "#{d} "
    end
    apache2_description += "\nServerAlias #{aliases}\n" unless aliases.empty?
  end

  template "/etc/apache2/sites-enabled/#{vhost_sym.to_s}.conf" do
    source "#{vhost_sym.to_s}.conf.erb"
    mode 0644
    variables({:listen => apache2_listen, :description => apache2_description, :config => config}.merge(apache2_vhost_params[:options]))
    notifies :reload, resources(:service => "apache2")
  end

  # TODO implements basic auth
  
end
