
define :node_logstash_config, {
  :urls => []
} do

  node_logstash_config_params = params

  file "#{node.node_logstash.config_directory}/#{node_logstash_config_params[:name]}" do
    mode 0644
    content node_logstash_config_params[:urls].join("\n")
    notifies :restart, resources(:service => "logstash")
  end

end
