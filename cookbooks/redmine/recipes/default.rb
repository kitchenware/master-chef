include_recipe "ruby"
include_recipe "unicorn"
include_recipe "capistrano"
include_recipe "mysql"
include_recipe "nginx"

ruby_user node.redmine.user do
  install_rbenv true
end

capistrano_app node.redmine.directory do
  user node.redmine.user
  without_cap true
end

git "#{node.redmine.directory}/current" do
  user node.redmine.user
  repository node.redmine.git_url
  reference node.redmine.version
end

directory "#{node.redmine.directory}/current/files" do
  owner node.redmine.user
  group node.redmine.user
  recursive true
end

%w{Gemfile Gemfile.lock .rbenv-version .rbenv-gemsets .bundle-option}.each do |f|
  template "#{node.redmine.directory}/current/#{f}" do
    owner node.redmine.user
    source f
    not_if "[ -f #{node.redmine.directory}/current/.redmine_ready ]"
  end
end

mysql_database "redmine:database"

template "#{node.redmine.directory}/current/config/database.yml" do
  owner node.redmine.user
  source "database.yml.erb"
  variables :database => mysql_config("redmine:database")
end

ruby_rbenv_command "initialize redmine" do
  user node.redmine.user
  directory "#{node.redmine.directory}/current"
  code "rm -f .warped && rbenv warp install && rake generate_session_store && RAILS_ENV=production rake db:migrate"
  file_check "#{node.redmine.directory}/current/.redmine_ready"
end

unicorn_app "redmine" do
  user node.redmine.user
  app_directory node.redmine.directory
  code_for_initd "export RAILS_RELATIVE_URL_ROOT='#{node.redmine.location}'"
end

nginx_add_default_location "redmine" do
  content <<-EOF

  location #{node.redmine.location} {
    try_files $uri $uri.html $uri/index.html @unicorn_redmine;
  }

  location @unicorn_redmine {
    proxy_pass http://unicorn_redmine_upstream;
    break;
  }
EOF
  upstream <<-EOF
upstream unicorn_redmine_upstream {
  server 'unix:#{node.redmine.directory}/shared/unicorn.sock' fail_timeout=0;
}
  EOF
end