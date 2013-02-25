
package "squid"

service "squid3" do
  supports :restart => true
  action auto_compute_action
end