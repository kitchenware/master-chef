
base_user node.gitlab.gitolite.user

directory node.gitlab.gitolite.path do
  owner node.gitlab.gitolite.user
end

git_clone node.gitlab.gitolite.path do
  repository node.gitlab.gitolite.url
  reference node.gitlab.gitolite.reference
  user node.gitlab.gitolite.user
end

directory "#{get_home node.gitlab.gitolite.user}/bin" do
  owner node.gitlab.gitolite.user
end
