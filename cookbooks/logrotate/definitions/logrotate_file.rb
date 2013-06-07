
define :logrotate_file, {
  :cookbook => 'logrotate',
  :source => 'logrotate.erb',
  :variables => {},
  :files => nil,
  :user => 'root',
  :group => 'root',
  :copytruncate => false,
  } do
  logrotate_file_params = params

  raise "Please specify files in logrotate_file" unless logrotate_file_params[:files]

  template "/etc/logrotate.d/#{logrotate_file_params[:name]}" do
    cookbook logrotate_file_params[:cookbook]
    source logrotate_file_params[:source]
    mode '0644'
    variables(
        {
            :files => logrotate_file_params[:files],
            :user => logrotate_file_params[:user],
            :group => (logrotate_file_params[:group] || logrotate_file_params[:user]),
            :copytruncate => logrotate_file_params[:copytruncate]
        }.merge(logrotate_file_params[:variables]))
  end

end
