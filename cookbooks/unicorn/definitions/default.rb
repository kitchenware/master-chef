
define :unicorn_app, {
  :unicorn_cmd => 'unicorn_rails',
  :app_directory => nil,
  :user => nil,
  :files_to_rotate => [],
} do

  unicorn_app_params = params

  [:app_directory, :user].each do |sym|
    raise "You have to specify #{sym} in unicorn_app" unless unicorn_app_params[sym]
  end

  unicorn_pid_file = "#{unicorn_app_params[:app_directory]}/shared/pids/unicorn.pid"
  unicorn_config_file = "#{unicorn_app_params[:app_directory]}/shared/unicorn.conf.rb"
  unicorn_log_prefix = "#{unicorn_app_params[:app_directory]}/shared/log/unicorn"
  unicorn_socket_file = "unix:#{unicorn_app_params[:app_directory]}/shared/unicorn.sock"

  template "/etc/init.d/unicorn" do
    cookbook 'unicorn'
    source 'unicorn_init_d.erb'
    mode 0755
    variables({
      :name => unicorn_app_params[:name],
      :app_directory => "#{unicorn_app_params[:app_directory]}/current",
      :unicorn_cmd => unicorn_app_params[:unicorn_cmd],
      :config_file => unicorn_config_file,
      :pid_file => unicorn_pid_file,
      :user => unicorn_app_params[:user],
    })
  end

  template unicorn_config_file do
    cookbook 'unicorn'
    source "unicorn.conf.rb.erb"
    owner unicorn_app_params[:user]
    mode 0644
    variables({
      :app_directory => "#{unicorn_app_params[:app_directory]}/current",
      :unicorn_socket => unicorn_socket_file,
      :log_prefix => unicorn_log_prefix,
      :pid_file => unicorn_pid_file
    })
  end

  service "unicorn" do
    supports :status => true, :restart => true, :reload => true, :graceful_restart => true
    action [ :enable, :start ]
  end

  monit_service "unicorn" do
    cookbook "unicorn"
    variables({:pid_file => unicorn_pid_file,
        :app_directory => "#{unicorn_app_params[:app_directory]}/current"})
  end

  template "/etc/sudoers.d/#{unicorn_app_params[:user]}_monit" do
    cookbook "unicorn"
    source "sudoers.erb"
    mode 0440
    variables({:user => unicorn_app_params[:user],
        :bin_file => "/usr/sbin/monit"})
  end

  logrotate_custom "unicorn" do
    files (unicorn_app_params[:files_to_rotate] + ["#{unicorn_log_prefix}*.log"])
    variables :user => unicorn_app_params[:user], :post_rotate => "[ -x /etc/init.d/unicorn ] && /etc/init.d/unicorn reopen_log"
  end

  if is_splunk_forwarder
    splunk_app "unicorn" do
      pattern "#{unicorn_log_prefix}*.log"
      sourcetype "unicorn"
    end
  end

end
