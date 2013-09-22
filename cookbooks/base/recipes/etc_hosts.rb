
template "/etc/hosts" do
  mode '0644'
  source "hosts.erb"
  variables :hostname => node.hostname, :fqdn => node[:fqdn] || ""
end
