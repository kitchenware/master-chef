
include_recipe "java"

base_user node.elasticsearch.user

optional_config = node.elasticsearch[:config] || ""
init_d_code = []
init_d_code << "ulimit -n 65000\nexport JAVA_OPTS=\"#{node.elasticsearch.java_opts}\""

if node.elasticsearch.configure_zeromq_river && node.elasticsearch.configure_zeromq_river.enable
  zeromq_river_name = "zeromq_river_" + node.hostname
  optional_config += "\nnode.river: " + zeromq_river_name + "\n"
end

directory node.elasticsearch.directory_data do
  owner node.elasticsearch.user
  mode '0755'
  recursive true
end

node.elasticsearch.env_vars.each do |k, v|
  init_d_code << "export #{k}=\"#{v}\""
end

Chef::Config.exception_handlers << ServiceErrorHandler.new("elasticsearch", ".*elasticsearch.*")

basic_init_d "elasticsearch" do
  daemon "#{node.elasticsearch.directory}/bin/elasticsearch"
  user node.elasticsearch.user
  directory_check [node.elasticsearch.directory]
  options "-f " + node.elasticsearch.command_line_options
  code init_d_code.join("\n")
end

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
  environment get_proxy_environment
  version node.elasticsearch.url
  file_storage "#{node.elasticsearch.directory}/.elasticsearch_ready"
  notifies :restart, "service[elasticsearch]"
end

template "#{node.elasticsearch.directory}/config/elasticsearch.yml" do
  owner node.elasticsearch.user
  source "elasticsearch.yml.erb"
  mode '0644'
  variables :config => node.elasticsearch.to_hash, :optional_config => optional_config
  notifies :restart, "service[elasticsearch]"
end

template "#{node.elasticsearch.directory}/config/logging.yml" do
  owner node.elasticsearch.user
  source "logging.yml.erb"
  mode '0644'
  notifies :restart, "service[elasticsearch]"
end

node.elasticsearch.plugins.each do |k, v|

  next unless v[:enable]

  command = "(bin/plugin --remove #{v[:id]} || true) && "
  command += "bin/plugin --install #{v[:id]}"
  command += " --url #{v[:url]}" if v[:url]

  execute_version "install elasticsearch plugin #{k}" do
    command "cd #{node.elasticsearch.directory} && #{command}"
    environment get_proxy_environment
    version "#{k}_#{v[:id]}"
    file_storage "#{node.elasticsearch.directory}/.plugin_install_#{k}"
    notifies :restart, "service[elasticsearch]"
  end

end

if node.elasticsearch.configure_zeromq_river && node.elasticsearch.configure_zeromq_river.enable

  delayed_exec "configure zeromq river" do
    block do
      Chef::Log.info("Creating river " + zeromq_river_name + "into elasticsearch")
      driver = ElasticsearchDriver.new('localhost', node.elasticsearch.http_port)
      driver.wait_ready
      code, body = driver.get "/_river/#{zeromq_river_name}/_meta"
      if code == 200
        Chef::Log.info("River already exists")
      else
        code = driver.put "/_river/#{zeromq_river_name}/_meta", {
          :type => 'zeromq-logstash',
          :'zeromq-logstash' => {
            :address => node.elasticsearch.configure_zeromq_river.address,
          }
        }
        raise "Unable to create river : #{code} #{body}" unless code == 201
        Chef::Log.info("River created")
      end
    end
  end

end


if node.logrotate[:auto_deploy]

  logrotate_file "elasticsearch" do
    files [
      "#{node.elasticsearch.directory}/logs/#{node.elasticsearch.cluster_name}.log",
      "#{node.elasticsearch.directory}/logs/#{node.elasticsearch.cluster_name}_index_indexing_slowlog.log",
      "#{node.elasticsearch.directory}/logs/#{node.elasticsearch.cluster_name}_index_search_slowlog.log",
    ]
    variables :copytruncate => true, :user => node.elasticsearch.user
  end

end