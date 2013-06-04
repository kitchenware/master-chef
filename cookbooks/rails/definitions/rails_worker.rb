define :rails_worker, {
  :rails_app => nil,
	:workers => nil,
  :command => 'bundle exec rake environment resque:work',
	:env => {},
  :vars_to_unset => [],
  :extended_path => nil,
	} do

	rails_worker_params = params

  rails_app = rails_worker_params[:rails_app] || rails_worker_params[:name]
  app_config = node.deployed_rails_apps[rails_app]
  raise "Rails app #{rails_app} not found" unless app_config

	[:workers, :command].each do |s|
    raise "Please specify #{s} with rails_worker" unless rails_worker_params[s]
  end

	include_recipe "supervisor"

  supervisor_worker rails_worker_params[:name] do
    command "#{app_config[:app_directory]}/shared/worker_#{rails_worker_params[:name]}.sh"
    workers rails_worker_params[:workers]
    user app_config[:user]
  end

	template "#{app_config[:app_directory]}/shared/worker_#{rails_worker_params[:name]}.sh" do
    cookbook "rails"
    source "worker.sh.erb"
    mode '0755'
    owner app_config[:user]
    variables({
      :app_directory => "#{app_config[:app_directory]}/current",
      :command => rails_worker_params[:command],
      :env => rails_worker_params[:env].merge({'RAILS_ENV' => 'production'}),
      :extended_path => rails_worker_params[:extended_path],
      :vars_to_unset => rails_worker_params[:vars_to_unset],
    })
    notifies :restart, "service[#{node.supervisor.service_name)}]"
  end

  template "#{app_config[:app_directory]}/shared/worker_#{rails_worker_params[:name]}_restart.sh" do
    cookbook "rails"
    source "worker_restart.sh.erb"
    mode '0755'
    owner app_config[:user]
    variables :name => rails_worker_params[:name]
  end

end

define :rails_resque_worker, {
  :rails_app => nil,
  :workers => nil,
  :queues => '*',
  :command => 'resque:work',
  :extended_path => nil,
  :vars_to_unset => [],
  :env => {},
  } do

  rails_resque_worker_params = params

  rails_worker rails_resque_worker_params[:name] do
    rails_app rails_resque_worker_params[:rails_app]
    command "bundle exec rake environment #{rails_resque_worker_params[:command]}"
    env(rails_resque_worker_params[:env].merge({'QUEUES' => rails_resque_worker_params[:queues]}))
    workers rails_resque_worker_params[:workers]
    extended_path rails_resque_worker_params[:extended_path]
    vars_to_unset rails_resque_worker_params[:vars_to_unset]
  end

end
