
require 'digest'

node.set[:postgresql][:databases][:cabot] = {
  :host => 'localhost',
  :database => 'cabot',
  :username => 'cabot',
}

include_recipe "postgresql::server"
include_recipe "redis"
include_recipe "supervisor"

base_user node.cabot.user

package "python-pip"
package "python-dev"
package "libpq-dev"
package "node-less"
package "coffeescript"

include_recipe "base::python"

execute_version "upgrade virtualenv" do
  command "pip install virtualenv --upgrade"
  environment get_proxy_environment
  version "1"
  file_storage "/.pip_virtualenv"
end

[
  node.cabot.root,
  "#{node.cabot.root}/shared",
  "#{node.cabot.root}/shared/logs",
].each do |x|
  directory x do
    owner "cabot"
  end
end

git_clone "#{node.cabot.root}/current" do
  repository node.cabot.git
  reference node.cabot.version
  user node.cabot.user
  notifies :restart, "service[#{node.supervisor.service_name}]"
end

execute "create cabot virtual env" do
  command "cd #{node.cabot.root} && virtualenv venv"
  user "cabot"
  not_if "[ -d #{node.cabot.root}/venv ]"
end

django_secret_key = local_storage_read("cabot:django_secret_key") do
  PasswordGenerator.generate 64
end

template "#{node.cabot.root}/shared/run.sh" do
  owner "cabot"
  source "run.sh.erb"
  mode "0755"
  variables :root => node.cabot.root, :virtual_env => "#{node.cabot.root}/venv"
end

template "#{node.cabot.root}/shared/production.env" do
  owner "cabot"
  source "production.env.erb"
  variables ({
    :database => node.postgresql.databases.cabot,
    :password => node.postgresql.databases.cabot.password || postgresql_password(node.postgresql.databases.cabot.username),
    :log_file => "#{node.cabot.root}/shared/logs/cabot.log",
    :port => node.cabot.port,
    :extra_config => node.cabot.extra_config,
    :django_secret_key => django_secret_key,
    :plugins => node.cabot.plugins,
  })
  notifies :restart, "service[#{node.supervisor.service_name}]"
end

execute_version "install cabot dependencies" do
  command "cd #{node.cabot.root}/current && . #{node.cabot.root}/venv/bin/activate && /opt/cabot/shared/run.sh pip install --process-dependency-links -e ."
  user "cabot"
  file_storage "#{node.cabot.root}/.dependencies"
  version node.cabot.version + '_' + Digest::MD5.hexdigest(SortedJsonDump.pretty_generate(node.cabot.plugins.to_hash))
end

[
  "syncdb --noinput",
  "migrate cabotapp --noinput",
  "migrate djcelery --noinput",
  "collectstatic --noinput",
  "compress",
].each_with_index do |x, k|
  execute_version "cabot database migrations #{k}" do
    command "#{node.cabot.root}/shared/run.sh python manage.py #{x}"
    user node.cabot.user
    environment get_proxy_environment
    version node.cabot.version
    file_storage "#{node.cabot.root}/.cabot_migration_#{k}"
  end
end

execute "create django admin" do
  command <<-EOF
. #{node.cabot.root}/venv/bin/activate &&
. #{node.cabot.root}/shared/production.env &&
cd #{node.cabot.root}/current &&
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python manage.py shell &&
touch #{node.cabot.root}/.admin
EOF
  user node.cabot.user
  not_if "[ -f #{node.cabot.root}/.admin ]"
end

supervisor_worker "cabot_gunicorn" do
  workers 1
  command "#{node.cabot.root}/shared/run.sh gunicorn cabot.wsgi:application --config gunicorn.conf"
  user node.cabot.user
  autorestart true
end

supervisor_worker "cabot_celery" do
  workers 1
  command "#{node.cabot.root}/shared/run.sh celery worker -B -A cabot --loglevel=INFO --concurrency=16 -Ofair"
  user node.cabot.user
  autorestart true
end

if node.logrotate[:auto_deploy]

  logrotate_file "cabot" do
    files [
      "#{node.cabot.root}/shared/logs/cabot.log"
    ]
    variables :copytruncate => true, :user => "cabot"
  end

end

