
git_clone "#{node.redmine.directory}/current/plugins/#{File.basename(node.redmine.google_apps_plugin_git).split(".").first}" do
  user node.redmine.user
  repository node.redmine.google_apps_plugin_git
  reference node.redmine.google_apps_plugin_branch
  notifies :restart, "service[redmine]"
end
