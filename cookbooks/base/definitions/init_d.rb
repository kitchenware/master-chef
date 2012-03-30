
define :basic_init_d, {
  :daemon => nil,
  :options => "",
  :user => nil,
  :make_pidfile => true,
  :background => true,
  :file_check => [],
  :executable_check => [],
  :auto_start => true,
  :working_directory => nil,
  :log_file => nil,
} do
  basic_init_d_params = params

  raise "Please specify daemon with basic_init_d" unless basic_init_d_params[:daemon]

  start_options = ""
  start_options += " -m" if basic_init_d_params[:make_pidfile]
  start_options += " -b" if basic_init_d_params[:background]
  start_options += " -c #{basic_init_d_params[:user]}" if basic_init_d_params[:user]
  start_options += " -d #{basic_init_d_params[:working_directory]}" if basic_init_d_params[:working_directory]

  end_of_command = ""
  end_of_command = "2>&1 | tee #{basic_init_d_params[:log_file]}" if basic_init_d_params[:log_file]
  
  template "/etc/init.d/#{basic_init_d_params[:name]}" do
    cookbook "base"
    source "basic_init_d.erb"
    mode 0755
    variables({
      :daemon => basic_init_d_params[:daemon],
      :name => basic_init_d_params[:name],
      :pid_file => "/var/run/#{basic_init_d_params[:name]}.pid",
      :options => basic_init_d_params[:options],
      :file_check => basic_init_d_params[:file_check],
      :executable_check => basic_init_d_params[:executable_check] + ["$DAEMON"],
      :start_options => start_options,
      :end_of_command => end_of_command,
      })
  end

  if basic_init_d_params[:auto_start]
    service basic_init_d_params[:name] do
      supports :status => true, :restart => true
      action [ :enable, :start ]
    end
  end

end