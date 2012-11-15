
define :rails_app, {
  :app_directory => nil,
  :user => nil,
  :mysql_database => nil,
  :mysql_adapter => 'mysql2',
} do
  rails_app_params = params

  include_recipe "ruby"
  include_recipe "capistrano"

  [:app_directory, :user].each do |s|
    raise "Please specify #{s} with rails_app" unless rails_app_params[s]
  end

  unless rails_app_params[:app_directory]
    rails_app_params[:app_directory] = "#{get_home rails_app_params[:user]}/#{rails_app_params[:name]}" 
  end

  ruby_user rails_app_params[:user] do
    install_rbenv true
  end

  capistrano_app rails_app_params[:app_directory] do
    user rails_app_params[:user]
  end

  directory "#{rails_app_params[:app_directory]}/shared/pids" do
    owner rails_app_params[:user]
  end

  if rails_app_params[:mysql_database]

    include_recipe "mysql"

    mysql_database rails_app_params[:mysql_database]

    config = mysql_config(rails_app_params[:mysql_database])

    template "#{rails_app_params[:app_directory]}/shared/database.yml" do
      owner rails_app_params[:user]
      source "database.yml.erb"
      cookbook "rails"
      variables :database => config, :database_adapter => rails_app_params[:mysql_adapter]
    end

  end

  node.set[:deployed_rails_apps][rails_app_params[:name]] = rails_app_params

end

