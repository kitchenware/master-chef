
capistrano_app node.grafana.directory do
  user "root"
end

execute_version "install grafana" do
	command "cd #{node.grafana.directory} && rm -rf current && curl -L -f -s #{node.grafana.url}#{node.grafana.version}.tar.gz -o grafana.tar.gz && tar xvzf grafana.tar.gz && rm grafana.tar.gz && mv grafana-* current"
	environment get_proxy_environment
	version node.grafana.version
	file_storage "#{node.grafana.directory}/.grafana_version"
end

template "#{node.grafana.directory}/current/config.js" do
	source "grafana.config.js.erb"
end