
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

  if node.lsb.codename == "squeeze"

    deb_curl_dpkg "multiarch_support" do
      url "http://ftp.us.debian.org/debian/pool/main/e/eglibc/multiarch-support_2.13-38_amd64.deb"
    end

    deb_curl_dpkg "libpcre3" do
      url "http://ftp.us.debian.org/debian/pool/main/p/pcre3/libpcre3_8.30-5_amd64.deb"
    end

    deb_curl_dpkg "libssl1.1.0" do
      url "http://ftp.us.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1e-2_amd64.deb"
    end

  end

  deb_curl_dpkg "haproxy" do
    url "http://www.roedie.nl/downloads/haproxy/haproxy-1.5-dev19/haproxy_1.5.0-1~dev19-1_amd64.deb"
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
