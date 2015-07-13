
git_clone "#{node.redmine.directory}/current/plugins/google_apps" do
  user node.redmine.user
  repository node.redmine.google_apps_plugin_git
  reference "master"
  notifies :restart, "service[redmine]"
end
