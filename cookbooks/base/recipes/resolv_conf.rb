
if node[:resolv_conf]

  template "/etc/resolv.conf" do
    source "resolv.conf.erb"
    mode 0644
    variables :resolv => node.resolv_conf
  end

end
