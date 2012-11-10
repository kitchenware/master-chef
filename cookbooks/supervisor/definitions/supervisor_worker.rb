
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
      })
    notifies :restart, resources(:service => "supervisor")
  end

end