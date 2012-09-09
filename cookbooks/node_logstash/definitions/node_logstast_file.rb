
define :node_logstash_files, {
  :files => [],
  :log_type => nil,
} do

  node_logstash_files_params = params

  config_content = node_logstash_files_params[:files].map do |f|
    s = "input://file://#{f}"
    s += "?type=#{node_logstash_files_params[:log_type]}" if node_logstash_files_params[:log_type]
    s
  end

  file "#{node.node_logstash.config_directory}/#{node_logstash_files_params[:name]}" do
    mode 0644
    content config_content.join("\n")
    notifies :restart, resources(:service => "logstash")
  end

end
