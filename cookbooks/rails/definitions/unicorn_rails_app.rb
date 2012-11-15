
define :unicorn_rails_app, {
  :rails_app => nil,
  :location => '/',
  :code_for_initd => "",
  :configure_nginx => true,
} do
  unicorn_rails_app_params = params

  include_recipe "unicorn"

  rails_app = unicorn_rails_app_params[:rails_app] || unicorn_rails_app_params[:name]
  app_config = node.deployed_rails_apps[rails_app]
  raise "Rails app #{rails_app} not found" unless app_config

  initd = unicorn_rails_app_params[:code_for_initd]
  initd += "\nexport RAILS_RELATIVE_URL_ROOT='#{unicorn_rails_app_params[:location]}'" if unicorn_rails_app_params[:location] != "/"

  unicorn_app unicorn_rails_app_params[:name] do
    unicorn_cmd 'unicorn_rails'
    user app_config[:user]
    app_directory app_config[:app_directory]
    code_for_initd initd
    location unicorn_rails_app_params[:location]
    configure_nginx unicorn_rails_app_params[:configure_nginx]
    pid_file "shared/pids/unicorn.pids"
  end

end

