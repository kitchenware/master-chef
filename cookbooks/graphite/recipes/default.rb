
package "python-pip"
package "python-cairo"
package "python-twisted"

include_recipe "apache2"

apache2_enable_module "wsgi" do
  install true
end

directory node.graphite.directory_install do
  recursive true
end

execute_version "upgrade setuptools" do
  command "pip install setuptools --no-use-wheel --upgrade"
  version "1"
  file_storage "/.pip_setupstools"
end

execute_version "update pip" do
  command "pip install --upgrade pip"
  version "1"
  file_storage "/.pip_updated"
end

execute "install django" do
  command "pip install django==#{node.graphite.django_version}"
  environment get_proxy_environment
  not_if "pip show django | grep Version | grep #{node.graphite.django_version}"
end

execute "install django-tagging" do
  command "pip install django-tagging"
  environment get_proxy_environment
  not_if "pip show django-tagging | grep Version"
end

template "/etc/init.d/carbon" do
  source "carbon_init_d.erb"
  mode '0755'
  variables :graphite_directory => node.graphite.directory
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("carbon", "\\/opt\\/graphite\\/conf\\/.*")

service "carbon" do
  supports :status => true
  action auto_compute_action
end

[:whisper, :carbon, :web_app].each do |app|

  git_clone "#{node.graphite.directory_install}/#{app}" do
    reference node.graphite.git.version
    repository node.graphite.git[app]
    user 'root'
    notifies :restart, "service[carbon]" if app == :carbon
    notifies :restart, "service[apache2]" if app == :web_app
  end

  execute_version "install_#{app}" do
    command "cd #{node.graphite.directory_install}/#{app} && python setup.py install"
    version "#{app}_#{node.graphite.git.version}"
    file_storage "#{node.graphite.directory}/.#{app}"
    notifies :restart, "service[carbon]" if app == :carbon
    notifies :restart, "service[apache2]" if app == :web_app
  end

end

execute "configure carbon" do
  command "cd #{node.graphite.directory}/conf && cp carbon.conf.example carbon.conf && cp storage-schemas.conf.example storage-schemas.conf"
  not_if "[ -f #{node.graphite.directory}/conf/carbon.conf ]"
  notifies :restart, "service[carbon]"
end

directory "#{node.apache2.server_root}/wsgi" do
  owner "www-data"
  mode '0755'
end

secret_key = local_storage_read("graphite:secret_key") do
  PasswordGenerator.generate 64
end

template "#{node.graphite.directory}/webapp/graphite/local_settings.py" do
  source "local_settings.py.erb"
  mode '0644'
  variables({
    :timezone => node.graphite.timezone,
    :db_file => "#{node.graphite.directory}/storage/graphite.db",
    :secret_key => secret_key,
  })
  notifies :restart, "service[apache2]"
end

directory_recurse_chmod_chown "#{node.graphite.directory}/storage" do
  owner "www-data"
end

directory_recurse_chmod_chown "#{node.graphite.directory}/lib/twisted/plugins" do
  owner "www-data"
end

execute "create db" do
  user "www-data"
  command "cd #{node.graphite.directory}/webapp/graphite && python manage.py syncdb --noinput"
  not_if "[ -f #{node.graphite.directory}/storage/graphite.db ]"
end

execute "configure wsgi" do
  command "cd #{node.graphite.directory}/conf && cp graphite.wsgi.example graphite.wsgi"
  not_if "[ -f #{node.graphite.directory}/conf/graphite.wsgi ]"
end

apache2_vhost "graphite:graphite" do
  options :graphite_directory => node.graphite.directory, :wsgi_socket_prefix => "#{node.apache2.server_root}/wsgi"
end

template "#{node.graphite.directory}/conf/carbon.conf" do
  source "carbon.conf.erb"
  mode '0644'
  variables :carbon_receiver_port => node.graphite.carbon.port, :carbon_receiver_interface => node.graphite.carbon.interface
  notifies :restart, "service[carbon]"
end

template "#{node.graphite.directory}/conf/storage-aggregation.conf" do
  source "storage-aggregation.conf.erb"
  mode '0644'
  variables :default_xFilesFactor => node.graphite.xFilesFactor
  notifies :restart, "service[carbon]"
end

template "#{node.graphite.directory}/conf/storage-schemas.conf" do
  source "storage-schemas.conf.erb"
  mode '0644'
  variables :configs => node.graphite.storages
  notifies :restart, "service[carbon]"
end

