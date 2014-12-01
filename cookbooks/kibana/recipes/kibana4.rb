
base_user "kibana"

supervisor_worker "kibana" do
	user "kibana"
	workers 1
	command "#{node.kibana4.directory}/shared/run.sh"
end

capistrano_app node.kibana4.directory do
  user "root"
end

file "#{node.kibana4.directory}/shared/run.sh" do
	mode '0755'
	owner "kibana"
	content <<-EOF
#!/bin/sh

cd #{node.kibana4.directory}/current
bin/kibana
EOF
end

execute_version "install kibana 4" do
	command "cd #{node.kibana4.directory} && rm -rf current && curl -L -f -s #{node.kibana4.url}#{node.kibana4.version}.tar.gz -o kibana.tar.gz && tar xvzf kibana.tar.gz && rm kibana.tar.gz && mv kibana-* current"
	environment get_proxy_environment
	version node.kibana4.version
	file_storage "#{node.kibana4.directory}/.kibana_version"
end
