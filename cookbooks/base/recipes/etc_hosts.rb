
template "/etc/hosts" do
  mode '0644'
  source "hosts.erb"
  variables({
    :hostname => node.hostname,
    :fqdn => node[:forced_fqdn] || node[:fqdn] || "",
  })
end
