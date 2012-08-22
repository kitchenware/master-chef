
define :unicorn_rails_app, {
  :app_directory => nil,
  :user => nil,
  :mysql_database => nil,
  :mysql_adapter => 'mysql2',
  :location => '/',
  :code_for_initd => "",
  :configure_nginx => true,
} do
  unicorn_rails_app_params = params

  include_recipe "ruby"
  include_recipe "unicorn"
  include_recipe "capistrano"

  raise "Please specify user for unicorn_rails_app" unless unicorn_rails_app_params[:user]

  rails_app_directory = unicorn_rails_app_params[:app_directory]
  rails_app_directory = "#{get_home unicorn_rails_app_params[:user]}/#{unicorn_rails_app_params[:name]}" unless rails_app_directory

  ruby_user unicorn_rails_app_params[:user] do
    install_rbenv true
  end

  capistrano_app rails_app_directory do
    user unicorn_rails_app_params[:user]
  end

  directory "#{rails_app_directory}/shared/pids" do
    owner unicorn_rails_app_params[:user]
  end

  if unicorn_rails_app_params[:mysql_database]

    include_recipe "mysql"

    mysql_database unicorn_rails_app_params[:mysql_database]

    template "#{rails_app_directory}/shared/database.yml" do
      owner unicorn_rails_app_params[:user]
      source "database.yml.erb"
      cookbook "rails"
      variables :database => mysql_config(unicorn_rails_app_params[:mysql_database]), :database_adapter => unicorn_rails_app_params[:mysql_adapter]
    end

  end

  initd = unicorn_rails_app_params[:code_for_initd]
  initd += "\nexport RAILS_RELATIVE_URL_ROOT='#{unicorn_rails_app_params[:location]}'" if unicorn_rails_app_params[:location] != "/"

  unicorn_app unicorn_rails_app_params[:name] do
    user unicorn_rails_app_params[:user]
    app_directory rails_app_directory
    code_for_initd initd
    location unicorn_rails_app_params[:location]
    configure_nginx unicorn_rails_app_params[:configure_nginx]
  end

  node[:unicorn_rails_app] = {} unless node[:unicorn_rails_app]
  node[:unicorn_rails_app][unicorn_rails_app_params[:name]] = rails_app_directory

end

