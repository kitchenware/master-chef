include_recipe "postgresql::server"
include_recipe "redis"
include_recipe "nginx"
include_recipe "supervisor"

base_user node.cabot.user

[node.cabot.log_dir, node.cabot.root].each do |dir|
  directory  dir do
    owner "cabot"
    recursive true
    mode 0755
  end
end

%w(build-essential libpq-dev python-dev nodejs npm python-pip python-virtualenv virtualenvwrapper).each do |p|
  package p
end

execute_version "update pip" do
  command "pip install --upgrade pip"
  environment get_proxy_environment
  version "1"
  file_storage "/.pip_updated"
end

execute_version "upgrade setuptools" do
  command "pip install setuptools --no-use-wheel --upgrade"
  environment get_proxy_environment
  version "1"
  file_storage "/.pip_setupstools"
end

execute_version "upgrade virtualenv" do
  command "pip install virtualenv --upgrade"
  environment get_proxy_environment
  version "1"
  file_storage "/.pip_virtualenv"
end

execute "link nodejs execute to node" do
  command "ln -s /usr/bin/nodejs /usr/bin/node"
  user "root"
  not_if "[ -f /usr/bin/node ]"
end

git_clone node.cabot.path do
  repository node.cabot.git_url
  reference node.cabot.git_reference
  user node.cabot.user
end

%w(migrate.sh run_celery.sh run_gunicorn.sh).each do |f|
  template "#{node.cabot.path}/#{f}" do
    source "#{f}.erb"
    owner node.cabot.user
    variables ({
      :database => node.postgresql.databases.cabot,
      :log_file => "#{node.cabot.log_dir}/cabot.log",
      :port => node.cabot.port,
      :extra_config => node.cabot.extra_config
    })
    mode 0755
  end
end

execute "remove distribute from python dependencies" do
  command "sed -i -e '/distribute==0.6.24/d' #{node.cabot.path}/setup.py"
  #not_if "cat #{node.cabot.path}/setup.py | grep distribute"
  subscribes :run, "execute[git clone #{node.cabot.git_url} to #{node.cabot.path}]"
end

template "#{node.cabot.path}/fixture.json" do
  source "fixture.json.erb"
  owner node.cabot.user
  mode 0755
end

execute "install cabot dependencies with pip" do
  command "virtualenv venv --distribute && pip install -e #{node.cabot.path}"
  user "root"
end

execute "install nodejs and dependencies" do
  command "npm install --no-color -g coffee-script less@1.3 --registry http://registry.npmjs.org/"
  user "root"
end

execute_version "cabot database migration" do
  command "cd #{node.cabot.path} && sh migrate.sh"
  environment get_proxy_environment
  version "1"
  file_storage "/.cabot_migration"
end

nginx_vhost "cabot:http" do
  options({
    :protocol => 'http',
    :source => 'nginx.conf.erb',
  })
end

supervisor_worker "cabot_gunicorn" do
  workers 1
  command "#{node.cabot.path}/run_gunicorn.sh"
  user node.cabot.user
  autorestart true
end

supervisor_worker "cabot_celery" do
  workers 1
  command "#{node.cabot.path}/run_celery.sh"
  user node.cabot.user
  autorestart true
end

execute "change permissions on logs files" do
  command "touch /var/log/cabot/cabot.log && chown -R cabot /var/log/cabot"
  notifies :restart, "service[#{node.supervisor.service_name}]"
end




