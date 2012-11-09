define :resque_worker, {
	:command => nil,
	:nb_workers => nil,
	:user => nil,
	:autostart => true,
	} do
		resque_worker_params = params
		
		package "supervisor"

		service "supervisor" do
			supports :status => true
			action auto_compute_action
		end

		template "/etc/supervisor/conf.d/resque.conf" do
			mode 0644
			cookbook "rails"
			source "resque.conf.erb"
			variables({
				:command => resque_worker_params[:command],
				:numprocs => resque_worker_params[:nb_workers],
				:user => resque_worker_params[:user],
				:autostart => resque_worker_params[:autostart],
				})
			notifies :restart, resources(:service => "supervisor")
		end



	end