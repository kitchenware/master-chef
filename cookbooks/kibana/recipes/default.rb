
base_user "kibana"

capistrano_app node.kibana.directory do
  user "kibana"
end

basic_init_d "kibana" do
	daemon "#{node.kibana.directory}/shared/run.sh"
	user "kibana"
	make_pidfile true
	background true
  directory_check ["#{node.kibana.directory}/current"]
end

file "#{node.kibana.directory}/shared/run.sh" do
  mode '0755'
  owner "kibana"
  notifies :restart, "service[kibana]"
  content <<-EOF
#!/bin/bash

trap 'kill $(jobs -p) 2> /dev/null' EXIT

cd #{node.kibana.directory}/current
bin/kibana #{node.kibana.opts} >> #{node.kibana.directory}/shared/log/kibana.log 2>&1

EOF
end

execute_version "install kibana 4" do
  command "cd #{node.kibana.directory} && rm -rf current && curl -L -f -s #{node.kibana.url}#{node.kibana.version}.tar.gz -o kibana.tar.gz && tar xvzf kibana.tar.gz && rm kibana.tar.gz && mv kibana-* current && chown -R kibana #{node.kibana.directory}/current/optimize"
  environment get_proxy_environment
  version node.kibana.version
  file_storage "#{node.kibana.directory}/.kibana_version"
  notifies :restart, "service[kibana]"
end

if node.logrotate[:auto_deploy]

  logrotate_file "kibana" do
    files [
      "#{node.kibana.directory}/shared/log/kibana.log"
    ]
    variables :copytruncate => true, :user => "kibana"
  end

end