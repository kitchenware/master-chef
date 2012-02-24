
if node[:ntp_servers]

  package "ntp"
  package "ntpdate"

  service "ntp" do
    supports :status => true, :reload => true, :restart => true
    action [ :enable, :start ]
  end

  template "/etc/ntp.conf" do
    source "ntp.conf.erb"
    variables :servers => node.ntp_servers
    mode 0644
    notifies :restart, resources(:service => "ntp")
  end

end
