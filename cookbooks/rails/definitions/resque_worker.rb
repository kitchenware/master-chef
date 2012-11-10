define :resque_worker, {
	:workers => nil,
	:user => nil,
	:app_directory => nil,
	:queues => nil,
	} do

	resque_worker_params = params

	[:workers, :user, :app_directory, :queues].each do |s|
    raise "Please specify #{s} with resque_worker" unless resque_worker_params[s]
  end

	include_recipe "supervisor"

  include_recipe "redis"

  supervisor_worker resque_worker_params[:name] do
    command "#{resque_worker_params[:app_directory]}/shared/resque.sh"
    workers resque_worker_params[:workers]
    user resque_worker_params[:user]
  end

	template "#{resque_worker_params[:app_directory]}/shared/resque.sh" do
    cookbook "rails"
    source "resque.sh.erb"
    mode 0755
    owner resque_worker_params[:user]
    variables :app_directory => "#{resque_worker_params[:app_directory]}/current", :queues => resque_worker_params[:queues]
    notifies :restart, resources(:service => "supervisor")
  end

end