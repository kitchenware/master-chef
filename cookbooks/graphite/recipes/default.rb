
package "python-cairo"
package "python-django"
package "python-django-tagging"
package "python-twisted"
package "python-setuptools"

include_recipe "apache2"

apache2_enable_module "python" do
  install true
end

apache2_enable_module "wsgi" do
  install true
end

execute "install whisper" do
  command "cd /tmp && wget #{node.graphite.packages.whisper.url} && tar xvzf whisper-#{node.graphite.packages.whisper.version}.tar.gz && cd whisper-#{node.graphite.packages.whisper.version} && python setup.py install"
  not_if "[ -f /usr/local/bin/whisper-info.py ]"
end

execute "install carbon" do
  command "cd /tmp && wget #{node.graphite.packages.carbon.url} && tar xvzf carbon-#{node.graphite.packages.carbon.version}.tar.gz && cd carbon-#{node.graphite.packages.carbon.version} && python setup.py install"
  not_if "[ -f /opt/graphite/bin/carbon-cache.py ]"
end

execute "configure carbon" do
  command "cd /opt/graphite/conf && cp carbon.conf.example carbon.conf && cp storage-schemas.conf.example storage-schemas.conf"
  not_if "[ -f /opt/graphite/conf/carbon.conf ]"
end

execute "install graphite webapp" do
  command "cd /tmp && wget #{node.graphite.packages.graphite_webapp.url} && tar xvzf graphite-web-#{node.graphite.packages.graphite_webapp.version}.tar.gz && cd graphite-web-#{node.graphite.packages.graphite_webapp.version} && python setup.py install"
  not_if "[ -f /opt/graphite/bin/run-graphite-devel-server.py ]"
end

directory "/etc/apache2/wsgi" do
  owner "www-data"
  mode 0755
end

execute "create db" do
  command "cd /opt/graphite/webapp/graphite && python manage.py syncdb --noinput"
  not_if "[ -f /opt/graphite/storage/graphite.db ]"
end

execute "change storage owner" do
  command "chown -R www-data /opt/graphite/storage"
  not_if "ls -al /opt/graphite/storage | grep www-data"
end

execute "configure wsgi" do
  command "cd /opt/graphite/conf && cp graphite.wsgi.example graphite.wsgi"
  not_if "[ -f /opt/graphite/conf/graphite.wsgi ]"
end

apache2_vhost "graphite:graphite" do
  options :graphite_directory => "/opt/graphite", :wsgi_socket_prefix => "/etc/apache2/wsgi"
end

template "/etc/init.d/carbon" do
  source "carbon_init_d.erb"
  mode 0755
end

service "carbon" do
  supports :status => true
  action [ :enable, :start ]
end

template "/opt/graphite/conf/carbon.conf" do
  source "carbon.conf.erb"
  mode 0644
  notifies :restart, resources(:service => "carbon")
end

template "/opt/graphite/conf/storage-schemas.conf" do
  source "storage-schemas.conf.erb"
  mode 0644
  variables :default_retention => node.graphite.default_retention
  notifies :restart, resources(:service => "carbon")
end

execute "install bucky" do
  command "cd /tmp && wget #{node.graphite.packages.bucky.url} && tar xvzf bucky-#{node.graphite.packages.bucky.version}.tar.gz && cd bucky-#{node.graphite.packages.bucky.version} && python setup.py install"
  not_if "[ -x /usr/local/bin/bucky ]"
end

directory "/etc/bucky" do
  mode 0755
end

template "/etc/init.d/bucky" do
  source "bucky_init_d.erb"
  mode 0755
end

service "bucky" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end

template "/etc/bucky/bucky.conf" do
  source "bucky.conf.erb"
  mode 0644
  notifies :restart, resources(:service => "bucky")
end

