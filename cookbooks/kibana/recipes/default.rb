
capistrano_app node.kibana3.directory do
  user "root"
end

execute_version "install kibana" do
	command "cd #{node.kibana3.directory} && rm -rf current && curl -L -f -s #{node.kibana3.url}#{node.kibana3.version}.tar.gz -o kibana.tar.gz && tar xvzf kibana.tar.gz && rm kibana.tar.gz && mv kibana-* current"
	environment get_proxy_environment
	version node.kibana3.version
	file_storage "#{node.kibana3.directory}/.kibana_version"
end
