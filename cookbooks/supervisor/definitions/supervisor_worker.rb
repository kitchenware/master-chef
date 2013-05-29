
define :supervisor_worker, {
  :command => nil,
  :workers => nil,
  :user => nil,
  :autostart => true,
  :autorestart => 'unexpected',
  } do

  supervisor_worker_params = params

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
      :log_dir => node.supervisor.log_dir,
      })
    notifies :restart, resources(:service => node.supervisor.service_name)
  end

  sudo_sudoers_file "supervisor_#{supervisor_worker_params[:name]}" do
    content <<-EOF
#{supervisor_worker_params[:user]} ALL = (root) NOPASSWD: /usr/bin/supervisorctl restart #{supervisor_worker_params[:name]}*
EOF
  end

end