
if %w{debian ubuntu}.include? node.platform

  template "/etc/apt/apt.conf.d/99confold" do
    source "99confold.erb"
    mode '0644'
  end

end