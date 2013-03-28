
define :unicorn_rails_app, {
  :rails_app => nil,
  :location => '/',
  :code_for_initd => "",
  :vars_to_unset => [],
  :configure_nginx => true,
  :extended_nginx_config => "",
  :unicorn_timeout => 600
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
    vars_to_unset unicorn_rails_app_params[:vars_to_unset]
    location unicorn_rails_app_params[:location]
    unicorn_timeout unicorn_rails_app_params[:unicorn_timeout]
    configure_nginx unicorn_rails_app_params[:configure_nginx]
    extended_nginx_config unicorn_rails_app_params[:extended_nginx_config]
    pid_file "shared/pids/unicorn.pids"
  end

end

