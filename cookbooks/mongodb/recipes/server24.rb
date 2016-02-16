
include_recipe "mongodb::common"

package_fixed_version "mongodb-10gen" do
	version node.mongodb.version
end

service "mongodb" do
	supports :restart => true
	action auto_compute_action
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("mongodb", "mongodb")

template "/etc/mongodb.conf" do
	mode 0644
	variables node.mongodb.to_hash
	notifies :restart, "service[mongodb]", :immediately
end

include_recipe "logrotate"

if node.logrotate[:auto_deploy]

	logrotate_file "mongodb" do
	  files ["/var/log/mongodb/mongodb.log"]
	  variables :user => 'mongodb', :post_rotate => "kill -USR1 $(cat /var/lib/mongodb/mongod.lock) && rm -f /var/log/mongodb/mongodb.log.????-??-??T??-??-??"
	end

end