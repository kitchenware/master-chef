
if node[:disable_ipv6]

  template "/etc/sysctl.d/10-disable_ipv6.conf" do
    source "disable_ipv6.conf.erb"
    mode 0644
    notifies :restart, resources(:service => "procps")
  end

end
