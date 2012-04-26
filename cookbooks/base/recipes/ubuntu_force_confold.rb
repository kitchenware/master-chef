if node['platform'] == "ubuntu"
  template "/etc/apt/apt.conf.d/99confold" do
    source "99confold.erb"
  end
end