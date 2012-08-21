
define :nodejs_app, {
  :user => nil,
  :script => nil,
  :directory => nil,
  :opts => nil,
  :node_env => "production",
} do

  nodejs_app_params = params

  raise "You have to specify user in nodejs_app" unless nodejs_app_params[:user]
  raise "You have to specify script in nodejs_app" unless nodejs_app_params[:script]

  include_recipe "capistrano"
  include_recipe "warp"

  base_user nodejs_app_params[:user]

  directory ||= get_home(nodejs_app_params[:user])

  app_path = ::File.join(directory, nodejs_app_params[:name])
  current_path = ::File.join(app_path, "current")
  log_file = "#{app_path}/shared/log/#{nodejs_app_params[:name]}.log"

  Chef::Config.exception_handlers << ServiceErrorHandler.new(nodejs_app_params[:name], ".*#{app_path}.*")

  warp_install nodejs_app_params[:user] do
    nvm true
  end

  capistrano_app app_path do
    user nodejs_app_params[:user]
  end

  template "#{app_path}/shared/run_node.sh" do
    source "run_node.sh.erb"
    cookbook "nodejs"
    owner nodejs_app_params[:user]
    variables({
      :name => nodejs_app_params[:name],
      :log_file => log_file,
      :node_env => nodejs_app_params[:node_env],
    })
    mode 0755
  end

  template "/etc/init.d/#{nodejs_app_params[:name]}" do
    cookbook "nodejs"
    source "init.d.erb"
    mode "0755"
    variables({
      :name => nodejs_app_params[:name],
      :script => nodejs_app_params[:script],
      :user => nodejs_app_params[:user],
      :user_home => get_home(nodejs_app_params[:user]),
      :app_path => current_path,
      :pid_file => "#{app_path}/shared/#{nodejs_app_params[:name]}.pid",
      :runner => "#{app_path}/shared/run_node.sh"
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
    variables :opts => nodejs_app_params[:opts]
    notifies :restart, resources(:service => nodejs_app_params[:name])
  end

end
