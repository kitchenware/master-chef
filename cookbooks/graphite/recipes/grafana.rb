add_apt_repository "grafana_official" do
  url "https://packagecloud.io/grafana/testing/debian/"
  distrib "wheezy"
  components ["main"]
  key "D59097AB"
  key_server "keyserver.ubuntu.com"
end

package "grafana"

service "grafana-server" do
  supports :status => true, :restart => true
  action auto_compute_action
end

template "/etc/grafana/grafana.ini" do
  source 'grafana.ini.erb'
  variables ({
    :grafana_base_url => node.grafana.base_url,
    :grafana_location => node.grafana.location
  })
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, "service[grafana-server]"
end
