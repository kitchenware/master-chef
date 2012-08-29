
define :node_logstash_config, {
  :urls => []
} do

  node_logstash_config_params = params

  template "#{node.node_logstash.config_directory}/#{node_logstash_config_params[:name]}" do
    mode 0644
    source "config.erb"
    cookbook "node_logstash"
    variables :urls => node_logstash_config_params[:urls]
    notifies :restart, resources(:service => "logstash")
  end

end
