
define :supervisor_worker, {
  :command => nil,
  :workers => nil,
  :user => nil,
  :autostart => true,
  } do

  supervisor_worker_params = params

  template "/etc/supervisor/conf.d/#{supervisor_worker_params[:name]}.conf" do
    mode 0644
    cookbook "supervisor"
    source "worker.conf.erb"
    variables({
      :command => supervisor_worker_params[:command],
      :numprocs => supervisor_worker_params[:workers],
      :user => supervisor_worker_params[:user],
      :autostart => supervisor_worker_params[:autostart],
      :name => supervisor_worker_params[:name],
      :log_dir => node.supervisor.log_dir,
      })
    notifies :restart, resources(:service => "supervisor")
  end

  sudo_sudoers_file "supervisor_#{supervisor_worker_params[:name]}" do
    content <<-EOF
#{supervisor_worker_params[:user]} ALL = (root) NOPASSWD: /usr/bin/supervisorctl restart #{supervisor_worker_params[:name]}*
EOF
  end

end