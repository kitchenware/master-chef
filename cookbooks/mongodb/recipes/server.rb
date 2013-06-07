if node['platform'] == "ubuntu"

	add_apt_repository "ubuntu_10gen" do
		url "http://downloads-distro.mongodb.org/repo/ubuntu-upstart"
		distrib "dist"
		components ['10gen']
		run_apt_get_update false
	end
	
	directory "/etc/apt/keys"

	template "/etc/apt/keys/ubuntu_10gen" do
		source "apt_keys/ubuntu_10gen"
		mode '0644'
	end

	execute "accept key for ubuntu_10gen" do
		command "apt-key add /etc/apt/keys/ubuntu_10gen"
		not_if "apt-key list | grep 7F0CEB10"
	end
end

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
