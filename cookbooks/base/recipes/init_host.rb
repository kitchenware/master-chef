directory "/opt/init_host" do
  mode 0755
end

cookbook_file "/opt/init_host/regen_ssh.sh" do
  mode 0755
  source "regen_ssh.sh"
end

cookbook_file "/opt/init_host/init_host.sh" do
  mode 0755
  source "init_host.sh"
end