
include_recipe "git"

base_user node.gitlab.gitlab_shell.user

warp_install node.gitlab.gitlab_shell.user do
  rbenv true
end

git_clone "#{get_home node.gitlab.gitlab_shell.user}/gitlab-shell" do
  repository node.gitlab.gitlab_shell.url
  reference node.gitlab.gitlab_shell.reference
  user node.gitlab.gitlab_shell.user
end

directory node.gitlab.gitlab_shell.repositories do
  owner node.gitlab.gitlab_shell.user
end

template "#{get_home node.gitlab.gitlab_shell.user}/gitlab-shell/config.yml" do
  source "config.yml.erb"
  variables :repositories => node.gitlab.gitlab_shell.repositories
  owner node.gitlab.gitlab_shell.user
end

template "#{get_home node.gitlab.gitlab_shell.user}/gitlab-shell/.ruby-version" do
  source ".ruby-version"
  owner node.gitlab.gitlab_shell.user
end

ruby_rbenv_command "install gitlab-shell" do
  user node.gitlab.gitlab_shell.user
  directory "#{get_home node.gitlab.gitlab_shell.user}/gitlab-shell"
  code "rbenv warp install-ruby && ./bin/install"
  environment get_proxy_environment
  version node.gitlab.gitlab_shell.reference
end
