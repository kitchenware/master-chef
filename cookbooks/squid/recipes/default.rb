
package "squid"

service "squid3" do
  provider Chef::Provider::Service::Upstart if (platform?("ubuntu") && node.lsb.codename == "trusty")
  supports :restart => true
  action auto_compute_action
end