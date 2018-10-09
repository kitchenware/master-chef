
if File.exists? "/etc/init.d/grafana"
  service "grafana" do
    action [:stop, :disable]
  end
end

file "/etc/init.d/grafana" do
  action :delete
end

execute "purge old grafana" do
  command "rm -rf /opt/grafana"
  only_if "[ -d /opt/grafana ]"
end

add_apt_repository "grafana" do
  url "https://packagecloud.io/grafana/stable/debian/"
  key "D59097AB"
  key_url "https://packagecloud.io/gpg.key"
  distrib "wheezy"
end

if node.grafana[:grafana_version]

  package_fixed_version "grafana" do
    version node.grafana.grafana_version
  end

else

  package "grafana"

end

Chef::Config.exception_handlers << ServiceErrorHandler.new("grafana-server", "grafana")

service "grafana-server" do
  supports :status => true, :restart => true, :reload => true
  action auto_compute_action
end

template "/etc/grafana/grafana.ini" do
  source "grafana.ini.erb"
  variables node.grafana
  notifies :restart, "service[grafana-server]"
end

template "/etc/default/grafana-server" do
  source "grafana.default.erb"
  variables node.grafana
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[grafana-server]"
end
