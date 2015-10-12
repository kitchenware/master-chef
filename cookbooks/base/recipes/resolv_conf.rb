
if node[:resolv_conf] && ! node[:no_resolv_conf_update]

  template "/etc/resolv.conf" do
    source "resolv.conf.erb"
    mode '0644'
    variables :resolv => node[:override_resolv_conf] || node.resolv_conf
  end

end
