
define :unicorn_app, {
  :unicorn_cmd => 'unicorn',
  :app_directory => nil,
  :user => nil,
  :code_for_initd => "",
  :location => '/',
  :bind => nil,
  :configure_nginx => true,
  :extended_nginx_config => "",
  :vars_to_unset => [],
  :pid_file => 'shared/unicorn.pid',
  :unicorn_timeout => 600,
  :nb_workers => nil,
  :create_capistrano_app => true,
  :worker_boot_code => nil,
  :reload_files => [],
  :reload_cmd => nil,
  :delay_before_kill_old => 5,
  logrotate_options: {}
} do

  unicorn_app_params = params

  [:app_directory, :user].each do |sym|
    raise "You have to specify #{sym} in unicorn_app" unless unicorn_app_params[sym]
  end

  if unicorn_app_params[:create_capistrano_app]
    capistrano_app unicorn_app_params[:app_directory] do
      user unicorn_app_params[:user]
    end
  end

  unicorn_pid_file = "#{unicorn_app_params[:app_directory]}/#{unicorn_app_params[:pid_file]}"
  unicorn_config_file = "#{unicorn_app_params[:app_directory]}/shared/unicorn.conf.rb"
  unicorn_run_file = "#{unicorn_app_params[:app_directory]}/shared/#{unicorn_app_params[:unicorn_cmd]}_#{unicorn_app_params[:name]}"
  unicorn_log_prefix = "#{unicorn_app_params[:app_directory]}/shared/log/unicorn"
  unicorn_socket_file = "unix:#{unicorn_app_params[:app_directory]}/shared/unicorn.sock"

  template "/etc/init.d/#{unicorn_app_params[:name]}" do
    cookbook 'unicorn'
    source 'unicorn_init_d.erb'
    mode '0755'
    variables({
      :name => unicorn_app_params[:name],
      :app_directory => "#{unicorn_app_params[:app_directory]}/current",
      :cmd => unicorn_run_file,
      :unicorn_cmd => unicorn_app_params[:unicorn_cmd],
      :pid_file => unicorn_pid_file,
      :user => unicorn_app_params[:user],
      :code_for_initd => unicorn_app_params[:code_for_initd],
      :vars_to_unset => unicorn_app_params[:vars_to_unset],
      :config_file => unicorn_config_file,
    })
  end

  template unicorn_run_file do
    cookbook 'unicorn'
    source "unicorn.sh.erb"
    owner unicorn_app_params[:user]
    mode '0755'
    variables({
      :app_directory => "#{unicorn_app_params[:app_directory]}/current",
      :unicorn_cmd => unicorn_app_params[:unicorn_cmd],
      :config_file => unicorn_config_file,
      :home => get_home(unicorn_app_params[:user])
    })
  end

  service unicorn_app_params[:name] do
    supports :status => true, :restart => true, :reload => true, :reload => true
    action auto_compute_action
    unicorn_app_params[:reload_files].each do |x|
      subscribes :reload, "template[#{x}]"
    end
    reload_command unicorn_app_params[:reload_cmd] if unicorn_app_params[:reload_cmd]
    provider Chef::Provider::Service::Init::Debian if node.init_package == "systemd"
  end

  template unicorn_config_file do
    cookbook 'unicorn'
    source "unicorn.conf.rb.erb"
    owner unicorn_app_params[:user]
    mode '0644'
    variables({
      :app_directory => "#{unicorn_app_params[:app_directory]}/current",
      :unicorn_socket => unicorn_app_params[:bind] || unicorn_socket_file,
      :unicorn_timeout =>  unicorn_app_params[:unicorn_timeout],
      :log_prefix => unicorn_log_prefix,
      :pid_file => unicorn_pid_file,
      :nb_workers => unicorn_app_params[:nb_workers] || node.cpu.total,
      :worker_boot_code => unicorn_app_params[:worker_boot_code],
      :cmd => unicorn_run_file,
      :delay_before_kill_old => unicorn_app_params[:delay_before_kill_old],
    })
    notifies :reload, "service[#{unicorn_app_params[:name]}]"
  end

  node.set[:unicorn][:apps][unicorn_app_params[:name]] = {
    :socket => unicorn_socket_file,
    :root => "#{unicorn_app_params[:app_directory]}/current",
  }

  if unicorn_app_params[:configure_nginx]

    include_recipe "nginx"

    nginx_add_default_location unicorn_app_params[:name] do
      content <<-EOF

  #{unicorn_app_params[:extended_nginx_config]}

  location #{unicorn_app_params[:location]} {
    root #{unicorn_app_params[:app_directory]}/current/public;
    try_files $uri $uri.html $uri/index.html @unicorn_#{unicorn_app_params[:name]};
  }

  location @unicorn_#{unicorn_app_params[:name]} {
    proxy_pass http://unicorn_#{unicorn_app_params[:name]}_upstream;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
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

  if node.logrotate[:auto_deploy]

    logrotate_file "#{unicorn_app_params[:name]}_unicorn" do
      files [
        "#{unicorn_app_params[:app_directory]}/shared/log/unicorn.stdout.log",
        "#{unicorn_app_params[:app_directory]}/shared/log/unicorn.stderr.log",
      ]
      variables unicorn_app_params[:logrotate_options].merge(:user => "deploy", :copytruncate => true)
    end

  end


end
