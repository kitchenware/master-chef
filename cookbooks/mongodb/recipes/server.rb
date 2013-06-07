
package_fixed_version "mongodb-10gen" do
  version "2.2.4"
end

service "mongodb" do
  supports :restart => true
  action auto_compute_action
end

template "/etc/mongodb.conf" do
  mode 0644
  variables node.mongodb.to_hash
  notifies :restart, "service[mongodb]"
end
