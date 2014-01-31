
define :logrotate_file, {
  :cookbook => 'logrotate',
  :source => 'logrotate.erb',
  :variables => {},
  :files => nil,
} do
  logrotate_file_params = params

  raise "Please specify files in logrotate_file" unless logrotate_file_params[:files]

  template "/etc/logrotate.d/#{logrotate_file_params[:name]}" do
    cookbook logrotate_file_params[:cookbook]
    source logrotate_file_params[:source]
    mode '0644'
    variables({:files => logrotate_file_params[:files]}.merge(node.logrotate.default_config.to_hash).merge(logrotate_file_params[:variables]))
  end

end
