
package "socat"

if node.platform == "ubuntu" && node.apt.master_chef_add_apt_repo

  add_apt_repository "haproxy_dev" do
    url "http://ppa.launchpad.net/vbernat/haproxy-1.5/ubuntu"
    key "1C61B9CD"
    key_server "keyserver.ubuntu.com"
  end
  package "haproxy"

end

if node.lsb.codename == "wheezy" && node.apt.master_chef_add_apt_repo

  add_apt_repository "wheezy-backports" do
    url "http://ftp.debian.org/debian/"
    distrib "wheezy-backports"
    components ["main"]
  end
  package "haproxy"

end

if node.lsb.codename == "jessie" && node.apt.master_chef_add_apt_repo
  add_apt_repository "haproxy" do
    url "http://haproxy.debian.net"
    distrib "jessie-backports-1.8"
    components ["main"]
    key "95A42FE8353525F9"
    key_url "https://haproxy.debian.net/bernat.debian.org.gpg"
    run_apt_get_update true
  end
  apt_package "haproxy" do
    default_release "jessie-backports"
    version "1.8.\*"
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

  haproxy_vhost "stats_#{node.hostname}" do
    source "stats.conf.erb"
    variables :config => node.haproxy.config
  end

end
