
define :nodejs_app, {
  :capistrano_path => nil,
  :user => nil,
  :group => nil,
  :script => nil,
  :opts => nil,
} do

  nodejs_app_params = params

  [:capistrano_path, :user, :group, :script, :opts].each do |sym|
    raise "You have to specify #{sym} in nodejs_app" unless nodejs_app_params[sym]
  end

  current_path = "#{nodejs_app_params[:capistrano_path]}/current"
  pid_files_path = "#{nodejs_app_params[:capistrano_path]}/shared/pids"
  log_path = "#{nodejs_app_params[:capistrano_path]}/shared/logs"
  
  Chef::Config.exception_handlers << ServiceErrorHandler.new(nodejs_app_params[:name], ".*#{nodejs_app_params[:capistrano_path]}.*")

  [pid_files_path, log_path].each do |d|
    directory d do
      owner nodejs_app_params[:user]
      group nodejs_app_params[:group]
      mode "0755"
      recursive true
      action :create
    end
  end

  template "/etc/init.d/#{nodejs_app_params[:name]}" do
    cookbook "nodejs"
    source "init_d.erb"
    mode "0755"
    variables({
      :name => nodejs_app_params[:name],
      :script => nodejs_app_params[:script],
      :user => nodejs_app_params[:user],
      :pid_files_path => pid_files_path,
      :app_path => current_path,
      :user_home => get_home(nodejs_app_params[:user]),
    })
  end

  service nodejs_app_params[:name] do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
  end

  template "/etc/default/#{nodejs_app_params[:name]}" do
    cookbook "nodejs"
    source "default.erb"
    mode "0755"
    variables(
      :opts => [
        "#{nodejs_app_params[:opts]}",
        "--log_directory=#{log_path}"
      ].join(" ")
      )
    notifies :restart, resources(:service => nodejs_app_params[:name])
  end

end
