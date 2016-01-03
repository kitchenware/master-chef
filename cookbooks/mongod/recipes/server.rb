if node.mongodb.version[0] === "3"
	if node.platform == "ubuntu" && node.apt.master_chef_add_apt_repo

		add_apt_repository "mongodb-org-3.0" do
			url "http://repo.mongodb.org/apt/ubuntu"
			distrib %x{lsb_release -cs}.strip + "/mongodb-org/3.0"
			components ['multiverse']
			key "7F0CEB10"
			key_server "keyserver.ubuntu.com"
			run_apt_get_update true
		end
	end

	if node.platform == "debian" && node.apt.master_chef_add_apt_repo

		add_apt_repository "debian_mongo" do
			key "7F0CEB10"
			key_server "keyserver.ubuntu.com"
			run_apt_get_update true
		end
	end

	package_fixed_version "mongodb-org" do
		version node.mongodb.version
	end

	service "mongod" do
		supports :restart => true
		action auto_compute_action
	end

	template "/etc/mongod.conf" do
		mode 0644
		variables node.mongodb.to_hash
		notifies :restart, "service[mongod]", :immediately
	end
end

include_recipe "logrotate"

if node.logrotate[:auto_deploy]

	logrotate_file "mongodb" do
	  files ["/var/log/mongodb/mongodb.log"]
	  variables :user => 'mongodb', :post_rotate => "kill -USR1 $(cat /var/lib/mongodb/mongod.lock) && rm -f /var/log/mongodb/mongodb.log.????-??-??T??-??-??"
	end

end