
define :supervisor_worker, {
  :command => nil,
  :workers => nil,
  :user => nil,
  :autostart => true,
  :autorestart => 'unexpected',
  :stopsignal => nil,
  :stopwaitsecs => nil,
  :env => nil,
  :exitcodes => nil,
} do

  supervisor_worker_params = params

  raise "Please specify files in workers" unless supervisor_worker_params[:workers]
  raise "Please specify files in command" unless supervisor_worker_params[:command]

  supervisor_worker_params[:env] = {} unless supervisor_worker_params[:env]
  supervisor_worker_params[:env]['HOME'] = get_home supervisor_worker_params[:user]
  supervisor_worker_params[:env]['USER'] = supervisor_worker_params[:user]

  template "/etc/supervisor/conf.d/#{supervisor_worker_params[:name]}.conf" do
    mode '0644'
    cookbook "supervisor"
    source "worker.conf.erb"
    variables({
      :command => supervisor_worker_params[:command],
      :numprocs => supervisor_worker_params[:workers],
      :user => supervisor_worker_params[:user],
      :autostart => supervisor_worker_params[:autostart],
      :autorestart => supervisor_worker_params[:autorestart],
      :name => supervisor_worker_params[:name],
      :stopsignal => supervisor_worker_params[:stopsignal],
      :stopwaitsecs => supervisor_worker_params[:stopwaitsecs],
      :log_dir => node.supervisor.log_dir,
      :env => supervisor_worker_params[:env],
      :exitcodes => supervisor_worker_params[:exitcodes],
    })
    notifies :run, "execute[reload supervisor]"
  end

  sudo_sudoers_file "supervisor_#{supervisor_worker_params[:name]}" do
    content <<-EOF
#{supervisor_worker_params[:sudo_user] || supervisor_worker_params[:user]} ALL = (root) NOPASSWD: /usr/bin/supervisorctl restart #{supervisor_worker_params[:name]}*
EOF
  end

  if node.logrotate[:auto_deploy]

    logrotate_files = (1..supervisor_worker_params[:workers]).collect do |k|
      [
        "#{node.supervisor.log_dir}/#{supervisor_worker_params[:name]}_#{k - 1}_stdout.log",
        "#{node.supervisor.log_dir}/#{supervisor_worker_params[:name]}_#{k - 1}_stderr.log",
      ]
    end.flatten

    logrotate_file "supervisor_worker_#{supervisor_worker_params[:name]}" do
      user supervisor_worker_params[:user] if supervisor_worker_params[:user]
      variables :copytruncate => true
      files logrotate_files
    end

  end

end