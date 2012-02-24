include_recipe "ruby"
include_recipe "unicorn"

ruby_user node.redmine.user

git node.redmine.directory do
  user node.redmine.user
  repository "git://github.com/edavis10/redmine.git"
  reference node.redmine.version
end

%w{Gemfile Gemfile.lock .rbenv-version .rbenv-gemsets}.each do |f|
  cookbook_file "#{node.redmine.directory}/#{f}" do
    owner node.redmine.user
    source f
  end
end

