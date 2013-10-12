
if node.lsb.codename == "squeeze"
  package "libicu44"
elsif node.lsb.codename == "lucid"
  package "libicu42"
else
  package "libicu48"
end

package "mailutils"

package "python-docutils"

include_recipe "redis"

include_recipe "mysql::server"

include_recipe "rails"

base_user node.gitlab.gitlab.user do
  group node.gitlab.gitlab_shell.group
end

warp_install node.gitlab.gitlab.user do
  rbenv true
end

mysql_database  "gitlab:database"

rails_app "gitlab" do
  user node.gitlab.gitlab.user
  app_directory node.gitlab.gitlab.path
  mysql_database "gitlab:database"
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("gitlab", ".*gitlab.*")

directory "#{node.gitlab.gitlab.path}/shared/tmp" do
  owner node.gitlab.gitlab.user
end

unicorn_rails_app "gitlab" do
  location node.gitlab.config.location
end

rails_worker "gitlab_sidekik" do
  rails_app "gitlab"
  workers 1
  command "bundle exec sidekiq -q post_receive,mailer,system_hook,project_web_hook,gitlab_shell,common,default"
end

add_user_in_group node.gitlab.gitlab.user do
  group node.gitlab.gitlab_shell.user
end

git_clone "#{node.gitlab.gitlab.path}/current" do
  repository node.gitlab.gitlab.url
  reference node.gitlab.gitlab.reference
  user node.gitlab.gitlab.user
  notifies :restart, "service[gitlab]"
  notifies :restart, "service[#{node.supervisor.service_name}]"
end

template "#{node.gitlab.gitlab.path}/shared/gitlab.yml" do
  owner node.gitlab.gitlab.user
  source "gitlab.yml.erb"
  variables(node.gitlab.config.merge({
    :repositories => node.gitlab.gitlab_shell.repositories,
    :hooks => "#{node.gitlab.gitlab_shell.path}/hooks",
    :satellites => "#{node.gitlab.gitlab.path}/shared/satellites",
    :user => node.gitlab.gitlab.user,
    :gitlab_shell_user => node.gitlab.gitlab_shell.user,
  }))
  notifies :restart, "service[gitlab]"
  notifies :restart, "service[#{node.supervisor.service_name}]"
end

link "#{node.gitlab.gitlab.path}/current/config/database.yml" do
  to "#{node.gitlab.gitlab.path}/shared/database.yml"
end

link "#{node.gitlab.gitlab.path}/current/config/gitlab.yml" do
  to "#{node.gitlab.gitlab.path}/shared/gitlab.yml"
end

file "#{get_home node.gitlab.gitlab.user}/.gitconfig" do
  owner node.gitlab.gitlab.user
  content <<-EOF
[core]
  autocrlf = input
[user]
  name = Gitlab
  email = #{node.gitlab.config.email_from}
EOF
end

directory_recurse_chmod_chown node.gitlab.gitlab_shell.repositories do
  chmod 'ug+rwX,o-rwx'
  owner node.gitlab.gitlab_shell.user
  group node.gitlab.gitlab_shell.user
end

deployed_files = %w{.bundle-option .ruby-version .rbenv-gemsets}

directory "#{node.gitlab.gitlab.path}/shared/files" do
  owner node.gitlab.gitlab.user
end

directory "#{node.gitlab.gitlab.path}/shared/satellites" do
  owner node.gitlab.gitlab.user
end

deployed_files.each do |f|
  template "#{node.gitlab.gitlab.path}/shared/files/#{f}" do
    owner node.gitlab.gitlab.user
    source f
  end
end

cp_command = deployed_files.map{|f| "cp #{node.gitlab.gitlab.path}/shared/files/#{f} #{node.gitlab.gitlab.path}/current/#{f}"}.join(" &&\n")

ruby_rbenv_command "gitlab db:migrate" do
  user node.gitlab.gitlab.user
  directory "#{node.gitlab.gitlab.path}/current"
  code <<-EOF
rm -f .warped &&
#{cp_command} &&
rbenv warp install &&
rm -rf log &&
ln -s #{node.gitlab.gitlab.path}/shared/log . &&
rm -rf tmp &&
ln -s #{node.gitlab.gitlab.path}/shared/tmp . &&
RAILS_ENV=production rake db:migrate
EOF
  environment get_proxy_environment
  version node.gitlab.gitlab.reference
end

ruby_rbenv_command "initialize gitlab" do
  user node.gitlab.gitlab.user
  directory "#{node.gitlab.gitlab.path}/current"
  code "echo yes | RAILS_ENV=production rake gitlab:setup"
  file_storage "#{node.gitlab.gitlab.path}/shared/.initialized"
  version 1
end

# charlock_holmes does not support moving after install
# following commands allow to user system magic file
file "#{get_home node.gitlab.gitlab.user}/.magic" do
  owner node.gitlab.gitlab.user
end

link "#{get_home node.gitlab.gitlab.user}/.magic.mgc" do
  to "/usr/share/file/magic.mgc"
end
