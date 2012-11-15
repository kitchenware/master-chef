
include_recipe "rails"

include_recipe "mysql::server"

rails_app "redmine" do
  app_directory node.redmine.directory
  user node.redmine.user
  mysql_database "redmine:database"
end

unicorn_rails_app "redmine" do
  location node.redmine.location
end

git_clone "#{node.redmine.directory}/current" do
  user node.redmine.user
  repository node.redmine.git_url
  reference node.redmine.version
  notifies :restart, resources(:service => "redmine")
end

directory "#{node.redmine.directory}/current/files" do
  owner node.redmine.user
  group node.redmine.user
  recursive true
end

link "#{node.redmine.directory}/current/config/database.yml" do
  to "#{node.redmine.directory}/shared/database.yml"
end

template "#{node.redmine.directory}/shared/configuration.yml" do
    variables :config => node.redmine
    source 'configuration.yml.erb'
    mode 0755
end

link "#{node.redmine.directory}/current/config/configuration.yml" do
  to "#{node.redmine.directory}/shared/configuration.yml"
end

deployed_files = %w{Gemfile.local Gemfile.lock .rbenv-version .rbenv-gemsets .bundle-option}

directory "#{node.redmine.directory}/shared/files" do
  owner node.redmine.user
end

deployed_files.each do |f|
  template "#{node.redmine.directory}/shared/files/#{f}" do
    owner node.redmine.user
    source f
  end
end

cp_command = deployed_files.map{|f| "cp #{node.redmine.directory}/shared/files/#{f} #{node.redmine.directory}/current/#{f}"}.join(' && ')

ruby_rbenv_command "initialize redmine" do
  user node.redmine.user
  directory "#{node.redmine.directory}/current"
  code "rm -f .warped && #{cp_command} && rbenv warp install && rake generate_session_store && RAILS_ENV=production rake db:migrate"
  file_storage "#{node.redmine.directory}/current/.redmine_ready"
  version node.redmine.version
end

