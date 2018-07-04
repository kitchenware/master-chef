
package "python-pip"
package "python-dev"
package "python-cairo"
package "python-twisted"
package "python-virtualenv"
package "libffi-dev"

include_recipe "apache2"

apache2_enable_module "proxy"
apache2_enable_module "proxy_http"

apache2_enable_module "wsgi" do
  install true
end

directory node.graphite.directory_install do
  recursive true
end

include_recipe "base::python"

if node.lsb.codename == "lucid"

  execute_version "fix pip install under lucid" do
    command "easy_install pip"
    environment get_proxy_environment
    version "1"
    file_storage "/.fix_pip_install"
  end

end


# download pypy
pypy_archive = node.graphite.pypy.download_url.split('/').last
pypy_extract_dir = pypy_archive.gsub(/\.tar.*/,"")
pypy_bin = "#{node.graphite.directory}/virtualenv-carbon-cache/bin/pypy"

remote_file "#{node.graphite.directory}/#{pypy_archive}" do
  source node.graphite.pypy.download_url
  user 'root'
  group 'root'
  action :create_if_missing
end

execute 'extract pypy archive' do
  command "tar xjf #{node.graphite.directory}/#{pypy_archive} -C #{node.graphite.directory}"
  not_if { ::File.exist?("#{node.graphite.directory}/#{pypy_extract_dir}") }
end

link '/usr/local/bin/pypy' do
  to "#{node.graphite.directory}/#{pypy_extract_dir}/bin/pypy"
  link_type :symbolic
end

execute 'create virtualenv' do
  command "virtualenv -p pypy #{node.graphite.directory}/virtualenv-carbon-cache"
  not_if { ::File.exist?(pypy_bin) }
end


node.graphite.pypy.deps.each do |dep|
  execute "pip install #{dep}" do
    command "#{pypy_bin} -m pip install #{dep}"
    not_if "#{pypy_bin} -m pip freeze | grep -e '^#{dep}$'"
  end
end

execute "install cffi" do
  command "pip install cffi==1.11.5"
  environment get_proxy_environment
  not_if "pip show cffi | grep 'Version: 1.11.5'"
end

template "/etc/init.d/carbon" do
  source "carbon_init_d.erb"
  mode '0755'
  variables :graphite_directory => node.graphite.directory,
            :whisper_dev_shm_size => node.graphite[:whisper_dev_shm_size],
            :pypy => "#{pypy_bin}"
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("carbon", "\\/opt\\/graphite\\/conf\\/.*")

service "carbon" do
  supports :status => true
  action auto_compute_action
end

[:whisper, :carbon, :web_app].each do |app|

  version = node.graphite.git["#{app}_version"]
  version = node.graphite.git.version if version.nil? || version == ""

  git_clone "#{node.graphite.directory_install}/#{app}" do
    reference version
    repository node.graphite.git[app]
    user 'root'
    notifies :restart, "service[carbon]" if app == :carbon
    notifies :restart, "service[apache2]" if app == :web_app
  end

  execute_version "install_#{app}" do
    command "cd #{node.graphite.directory_install}/#{app} && python setup.py install"
    version "#{app}_#{version}"
    file_storage "#{node.graphite.directory}/.#{app}"
    notifies :restart, "service[carbon]" if app == :carbon
    notifies :restart, "service[apache2]" if app == :web_app
  end

  execute "install graphite-web requirements" do
    command "pip install -r requirements.txt"
    cwd "#{node.graphite.directory_install}/#{app}"
    environment get_proxy_environment
    only_if {app == :web_app}
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
    :db_file => "graphite.db",
    :storage_dir => "#{node.graphite.directory}/storage",
    :secret_key => secret_key,
  })
  notifies :restart, "service[apache2]"
end

directory_recurse_chmod_chown "#{node.graphite.directory}/storage" do
  owner "www-data"
  mode '0755'
end

if node.graphite[:whisper_dev_shm_size]

  execute "symlink whisper" do
    command "rm -rf #{node.graphite.directory}/storage/whisper && ln -s /dev/shm/whisper #{node.graphite.directory}/storage/whisper"
    not_if "[ -h #{node.graphite.directory}/storage/whisper ]"
    notifies :restart, "service[carbon]"
  end

end

directory_recurse_chmod_chown "#{node.graphite.directory}/lib/twisted/plugins" do
  owner "www-data"
end

execute "create db" do
  user "www-data"
  command "cd #{node.graphite.directory}/webapp/graphite && python manage.py syncdb --noinput"
  not_if "[ -f #{node.graphite.directory}/storage/graphite.db ]"
end

template "#{node.graphite.directory}/conf/graphite.wsgi" do
    source "graphite.wsgi.erb"
    notifies :restart, "service[apache2]"
end

apache2_vhost "graphite:graphite" do
  options({
    :graphite_directory => node.graphite.directory,
    :wsgi_socket_prefix => "#{node.apache2.server_root}/wsgi",
    :grafana => node.grafana,
  })
end

template "#{node.graphite.directory}/conf/carbon.conf" do
  source "carbon.conf.erb"
  mode '0644'
  variables({
    :carbon_receiver_port => node.graphite.carbon.port,
    :carbon_receiver_interface => node.graphite.carbon.interface,
    :max_updates_per_second => node.graphite.carbon.max_updates_per_second,
  })
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

if node.logrotate[:auto_deploy]

  logrotate_file "carbon" do
    files ["#{node.graphite.directory}/storage/log/carbon-cache/carbon-cache-a/*.log"]
    variables :user => 'www-data', :nocreate => true
  end

  logrotate_file "graphite" do
    files ["#{node.graphite.directory}/storage/log/webapp/*.log"]
    variables :user => 'www-data', :nocreate => true, :post_rotate => "/etc/init.d/apache2 reload > /dev/null"
  end

end
