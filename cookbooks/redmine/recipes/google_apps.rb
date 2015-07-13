
git_clone "#{node.redmine.directory}/current/plugins/google_apps" do
  user node.redmine.user
  repository node.redmine.google_apps_plugin_git
  reference "master"
  notifies :restart, "service[redmine]"
end

ruby_rbenv_command "initialize google apps plugin" do
  user node.redmine.user
  directory "#{node.redmine.directory}/current"
  code "RAILS_ENV=production rake redmine:plugins:assets"
  environment get_proxy_environment
  file_storage "#{node.redmine.directory}/current/.gapps_ready"
  version node.redmine.version
  notifies :restart, "service[redmine]"
end

file "#{node.redmine.directory}/current/config/initializers/openid.rb" do
  content "OpenIdAuthentication.store = :file"
  notifies :restart, "service[redmine]"
end
