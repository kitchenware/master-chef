
include_recipe "java"

base_user node.elasticsearch.user

optional_config = ""
init_d_code = "ulimit -n 65000\n"

if node.elasticsearch.transport_zmq.enable

  include_recipe "libzmq::jzmq"

  optional_config += <<-EOF
zeromq.bind: #{node.elasticsearch.transport_zmq.listen}
EOF

  init_d_code += "export export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:#{node.libzmq.jzmq.directory}/lib"

end

basic_init_d "elasticsearch" do
  daemon "#{node.elasticsearch.directory}/bin/elasticsearch"
  user node.elasticsearch.user
  directory_check node.elasticsearch.directory
  options "-f " + node.elasticsearch.options
  code init_d_code
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("elasticsearch", ".*elasticsearch.*")

execute_version "install elasticsearch" do
  command(
    "cd /tmp && " +
    "([ ! -x /etc/init.d/elasticsearch ] || /etc/init.d/elasticsearch stop) && " +
    "rm -rf #{node.elasticsearch.directory} && " +
    "curl --location #{node.elasticsearch.url} -o #{File.basename(node.elasticsearch.url)} && " +
    "tar xvzf #{File.basename(node.elasticsearch.url)} && " +
    "mv #{File.basename(node.elasticsearch.url)[0..-8]} #{node.elasticsearch.directory} && "+
    "chown -R #{node.elasticsearch.user} #{node.elasticsearch.directory}"
  )
  version node.elasticsearch.url
  file_storage "#{node.elasticsearch.directory}/.elasticsearch_ready"
  notifies :restart, resources(:service => "elasticsearch")
end

template "#{node.elasticsearch.directory}/config/elasticsearch.yml" do
  owner node.elasticsearch.user
  source "elasticsearch.yml.erb"
  mode 0644
  variables :config => node.elasticsearch.to_hash, :optional_config => optional_config
  notifies :restart, resources(:service => "elasticsearch")
end

if node.elasticsearch.transport_zmq.enable

  execute_version "install transport zmq" do
    command "cd #{node.elasticsearch.directory} && curl --location #{node.elasticsearch.transport_zmq.url} -o /tmp/plugin_file.zip && rm -rf plugins/transport-zeromq &&  mkdir -p plugins/transport-zeromq && cd plugins/transport-zeromq && unzip /tmp/plugin_file.zip && rm jzmq-1.0.0.jar && ln -s /opt/jzmq/share/java/zmq.jar jzmq-1.0.0.jar"
    file_storage "#{node.elasticsearch.directory}/.zmq_transport"
    version node.elasticsearch.url + node.elasticsearch.transport_zmq.url
    notifies :restart, resources(:service => "elasticsearch")
  end

end
