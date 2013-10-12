
include_recipe "git"

base_user node.gitlab.gitlab_shell.user do
  group node.gitlab.gitlab_shell.group
end

warp_install node.gitlab.gitlab_shell.user do
  rbenv true
end

directory node.gitlab.gitlab_shell.path do
  owner node.gitlab.gitlab_shell.user
  group node.gitlab.gitlab_shell.group
end

execute "gitlab_shell_post_install" do
  command "cd #{node.gitlab.gitlab_shell.path} && mv bin bin.orig && mkdir bin && mkdir log"
  user node.gitlab.gitlab_shell.user
  action :nothing
end

git_clone node.gitlab.gitlab_shell.path do
  repository node.gitlab.gitlab_shell.url
  reference node.gitlab.gitlab_shell.reference
  user node.gitlab.gitlab_shell.user
  notifies :run, "execute[gitlab_shell_post_install]", :immediately
end

%w{gitlab-keys gitlab-projects}.each do |x|
  template "#{node.gitlab.gitlab_shell.path}/bin/#{x}" do
    source "sudo_wrapper.sh.erb"
    variables({
      :path => node.gitlab.gitlab_shell.path,
      :user => node.gitlab.gitlab_shell.user,
    })
    mode '0755'
    owner node.gitlab.gitlab_shell.user
  end
end

%w{gitlab-shell}.each do |x|
  template "#{node.gitlab.gitlab_shell.path}/bin/#{x}" do
    source "wrapper.sh.erb"
    variables({
      :path => node.gitlab.gitlab_shell.path,
    })
    mode '0755'
    owner node.gitlab.gitlab_shell.user
  end
end


directory node.gitlab.gitlab_shell.repositories do
  owner node.gitlab.gitlab_shell.user
end

template "#{node.gitlab.gitlab_shell.path}/config.yml" do
  source "config.yml.erb"
  variables({
    :repositories => node.gitlab.gitlab_shell.repositories,
    :gitlab_shell_user => node.gitlab.gitlab_shell.user,
    :log_file => "#{node.gitlab.gitlab_shell.path}/log/gitlab-shell.log",
  })
  owner node.gitlab.gitlab_shell.user
end

template "#{node.gitlab.gitlab_shell.path}/.ruby-version" do
  source ".ruby-version"
  owner node.gitlab.gitlab_shell.user
end

ruby_rbenv_command "install gitlab-shell" do
  user node.gitlab.gitlab_shell.user
  directory node.gitlab.gitlab_shell.path
  code "rbenv warp install-ruby && ./bin.orig/install"
  environment get_proxy_environment
  version node.gitlab.gitlab_shell.reference
end

sudo_sudoers_file "gitlab_shell" do
  content <<-EOF
%git ALL = (git) NOPASSWD: #{get_home node.gitlab.gitlab_shell.user}/gitlab-shell/bin/gitlab-keys
%git ALL = (git) NOPASSWD: #{get_home node.gitlab.gitlab_shell.user}/gitlab-shell/bin/gitlab-projects
EOF
end

link "#{get_home node.gitlab.gitlab_shell.user}/gitlab-shell" do
  to node.gitlab.gitlab_shell.path
end