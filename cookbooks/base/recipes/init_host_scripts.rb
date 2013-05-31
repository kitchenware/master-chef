directory "/opt/init_host" do
  mode '0755'
end

template "/opt/init_host/regen_ssh.sh" do
  mode '0755'
  source "regen_ssh.sh.erb"
end

template "/opt/init_host/init_host.sh" do
  mode '0755'
  source "init_host.sh.erb"
end