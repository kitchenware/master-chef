if node.platform == "ubuntu" && node.apt.master_chef_add_apt_repo

	add_apt_repository "ubuntu_10gen" do
		url "http://downloads-distro.mongodb.org/repo/ubuntu-upstart"
		distrib "dist"
		components ['10gen']
		key "7F0CEB10"
		key_url "https://docs.mongodb.org/10gen-gpg-key.asc"
		run_apt_get_update true
	end
end

if node.platform == "debian" && node.apt.master_chef_add_apt_repo

	add_apt_repository "ubuntu_10gen" do
		url "http://downloads-distro.mongodb.org/repo/debian-sysvinit"
		distrib "dist"
		components ['10gen']
		key "7F0CEB10"
		key_url "https://docs.mongodb.org/10gen-gpg-key.asc"
		run_apt_get_update true
	end
end

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