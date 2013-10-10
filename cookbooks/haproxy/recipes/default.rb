
package "socat"

if node.platform == "ubuntu" && node.apt.master_chef_add_apt_repo

  add_apt_repository "haproxy_dev" do
    url "http://ppa.launchpad.net/vbernat/haproxy-1.5/ubuntu"
    key "1C61B9CD"
    key_server "keyserver.ubuntu.com"
  end

  package "haproxy"

end

if node.platform == "debian" && node.apt.master_chef_add_apt_repo
  # no debian repo with haproxy 1.5.x beurk

  haproxy_deb = "http://www.roedie.nl/downloads/haproxy/haproxy-1.5-dev19/haproxy_1.5.0-1~dev19-1_amd64.deb"
  base_haproxy_deb = File.basename(haproxy_deb)

  execute_version "install haproxy on debian system" do
    command "cd /tmp && curl -s -f #{haproxy_deb} -o #{base_haproxy_deb} && dpkg -i #{base_haproxy_deb}"
    environment get_proxy_environment
    version base_haproxy_deb
    file_storage "/.haproxy_version"
  end

end

service "haproxy" do
  supports :status => true, :restart => true, :reload => true
  action auto_compute_action
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("haproxy", ".*haproxy.*")

file "/etc/default/haproxy" do
  content "ENABLED=1"
  mode '0644'
  notifies :restart, "service[haproxy]"
end

incremental_template "/etc/haproxy/haproxy.cfg" do
  notifies :reload, "service[haproxy]"
end

haproxy_vhost "global" do
  source "global.conf.erb"
  variables :config => node.haproxy.config
end

if node.haproxy.config.stats.enabled

  haproxy_vhost "stats_#{node.hostname} %>" do
    source "stats.conf.erb"
    variables :config => node.haproxy.config
  end

end
