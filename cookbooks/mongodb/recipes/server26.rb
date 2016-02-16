
include_recipe "mongodb::common"

package "mongodb-10gen" do
	action :remove
end

package_fixed_version "mongodb-org" do
	version node.mongodb.version
end

service "mongod" do
	supports :restart => true
	action auto_compute_action
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("mongod", "mongod")

template "/etc/mongod.conf" do
	source "mongodb.conf.erb"
	mode 0644
	variables node.mongodb.to_hash
	notifies :restart, "service[mongod]", :immediately
end

include_recipe "logrotate"

if node.logrotate[:auto_deploy]

	logrotate_file "mongod" do
	  files ["/var/log/mongodb/mongod.log"]
	  variables :user => 'mongodb'
	end

end