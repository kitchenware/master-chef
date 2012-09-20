
define :unicorn_app, {
  :unicorn_cmd => 'unicorn',
  :app_directory => nil,
  :user => nil,
  :code_for_initd => "",
  :location => '/',
  :configure_nginx => true,
} do

  unicorn_app_params = params

  [:app_directory, :user].each do |sym|
    raise "You have to specify #{sym} in unicorn_app" unless unicorn_app_params[sym]
  end

  capistrano_app unicorn_app_params[:app_directory] do
    user unicorn_app_params[:user]
  end

  unicorn_pid_file = "#{unicorn_app_params[:app_directory]}/shared/unicorn.pid"
  unicorn_config_file = "#{unicorn_app_params[:app_directory]}/shared/unicorn.conf.rb"
  unicorn_log_prefix = "#{unicorn_app_params[:app_directory]}/shared/log/unicorn"
  unicorn_socket_file = "unix:#{unicorn_app_params[:app_directory]}/shared/unicorn.sock"

  template "/etc/init.d/#{unicorn_app_params[:name]}" do
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
      :code_for_initd => unicorn_app_params[:code_for_initd]
    })
  end

  service unicorn_app_params[:name] do
    supports :status => true, :restart => true, :reload => true, :graceful_restart => true
    action auto_compute_action
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
      :pid_file => unicorn_pid_file,
      :nb_workers => node.cpu.total,
    })
    notifies :restart, resources(:service => unicorn_app_params[:name])
  end

  if unicorn_app_params[:configure_nginx]

    include_recipe "nginx"

    nginx_add_default_location unicorn_app_params[:name] do
      content <<-EOF

  location #{unicorn_app_params[:location]} {
    root #{unicorn_app_params[:app_directory]}/current/public;
    try_files $uri $uri.html $uri/index.html @unicorn_#{unicorn_app_params[:name]};
  }

  location @unicorn_#{unicorn_app_params[:name]} {
    proxy_pass http://unicorn_#{unicorn_app_params[:name]}_upstream;
    break;
  }
  EOF
      upstream <<-EOF
  upstream unicorn_#{unicorn_app_params[:name]}_upstream {
    server 'unix:#{unicorn_app_params[:app_directory]}/shared/unicorn.sock' fail_timeout=0;
  }
  EOF

    end

  end

end
