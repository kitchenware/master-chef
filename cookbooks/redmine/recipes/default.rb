
include_recipe "rails"

unicorn_rails_app "redmine" do
  user node.redmine.user
  location node.redmine.location
  mysql_database "redmine:database"
end

app_directory = unicorn_rails_app_path "redmine"

git "#{app_directory}/current" do
  user node.redmine.user
  repository node.redmine.git_url
  reference node.redmine.version
end

directory "#{app_directory}/current/files" do
  owner node.redmine.user
  group node.redmine.user
  recursive true
end

link "#{app_directory}/current/config/database.yml" do
  to "#{app_directory}/shared/database.yml"
end

%w{Gemfile.local Gemfile.lock .rbenv-version .rbenv-gemsets .bundle-option}.each do |f|
  template "#{app_directory}/current/#{f}" do
    owner node.redmine.user
    source f
    not_if "[ -f #{app_directory}/current/.redmine_ready ]"
  end
end

ruby_rbenv_command "initialize redmine" do
  user node.redmine.user
  directory "#{app_directory}/current"
  code "rm -f .warped && rbenv warp install && rake generate_session_store && RAILS_ENV=production rake db:migrate && touch .redmine_ready"
  file_check "#{app_directory}/current/.redmine_ready"
end
