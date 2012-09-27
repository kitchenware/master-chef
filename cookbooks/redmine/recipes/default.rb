
include_recipe "rails"

app_directory = unicorn_rails_app "redmine" do
  user node.redmine.user
  location node.redmine.location
  mysql_database "redmine:database"
end

git_clone "#{app_directory}/current" do
  user node.redmine.user
  repository node.redmine.git_url
  reference node.redmine.version
  notifies :restart, resources(:service => "redmine")
end

directory "#{app_directory}/current/files" do
  owner node.redmine.user
  group node.redmine.user
  recursive true
end

link "#{app_directory}/current/config/database.yml" do
  to "#{app_directory}/shared/database.yml"
end

template "#{app_directory}/shared/configuration.yml" do
    variables :config => node.redmine
    source 'configuration.yml.erb'
    mode 0755
end

link "#{app_directory}/current/config/configuration.yml" do
  to "#{app_directory}/shared/configuration.yml"
end

deployed_files = %w{Gemfile.local Gemfile.lock .rbenv-version .rbenv-gemsets .bundle-option}

directory "#{app_directory}/shared/files" do
  owner node.redmine.user
end

deployed_files.each do |f|
  template "#{app_directory}/shared/files/#{f}" do
    owner node.redmine.user
    source f
  end
end

cp_command = deployed_files.map{|f| "cp #{app_directory}/shared/files/#{f} #{app_directory}/current/#{f}"}.join(' && ')

ruby_rbenv_command "initialize redmine" do
  user node.redmine.user
  directory "#{app_directory}/current"
  code "rm -f .warped && #{cp_command} && rbenv warp install && rake generate_session_store && RAILS_ENV=production rake db:migrate"
  file_storage "#{app_directory}/current/.redmine_ready"
  version node.redmine.version
end
