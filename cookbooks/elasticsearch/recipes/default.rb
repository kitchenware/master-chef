
include_recipe "java"

add_apt_repository "elasticsearch" do
  url "http://packages.elastic.co/elasticsearch/2.x/debian"
  distrib "stable"
  components ["main"]
  key "D88E42B4"
  key_url "https://packages.elastic.co/GPG-KEY-elasticsearch"
end

if node.elasticsearch[:elasticsearch_version]

  package_fixed_version "elasticsearch" do
    version node.elasticsearch.elasticsearch_version
  end

else

  package "elasticsearch"

end

Chef::Config.exception_handlers << ServiceErrorHandler.new("elasticsearch", "\\/etc\\/elasticsearch")

service "elasticsearch" do
  supports :status => true, :restart => true, :reload => true
  action auto_compute_action
end

optional_config = node.elasticsearch[:config] || ""

if node.elasticsearch.configure_zeromq_river && node.elasticsearch.configure_zeromq_river.enable
  optional_config += [
    "# ZEROMQ Config",
    "zeromq.enabled: true",
    "zeromq.address: #{node.elasticsearch.configure_zeromq_river.address}"
  ].join("\n")
end

directory node.elasticsearch.directory_data do
  owner "elasticsearch"
  mode '0755'
  recursive true
end

template "/etc/elasticsearch/elasticsearch.yml" do
  owner "elasticsearch"
  source "elasticsearch.yml.erb"
  mode '0644'
  variables :config => node.elasticsearch.to_hash, :optional_config => optional_config
  notifies :restart, "service[elasticsearch]"
end

template "/etc/elasticsearch/logging.yml" do
  owner "elasticsearch"
  source "logging.yml.erb"
  mode '0644'
  notifies :restart, "service[elasticsearch]"
end

template "/etc/default/elasticsearch" do
  source "default.erb"
  mode '0644'
  variables :config => node.elasticsearch.to_hash
  notifies :restart, "service[elasticsearch]"
end

node.elasticsearch.plugins.each do |k, v|

  next unless v[:enable]

  command = "(/usr/share/elasticsearch/bin/plugin --remove #{v[:id]} || true) && "
  command += "/usr/share/elasticsearch/bin/plugin "
  if ENV['BACKUP_http_proxy']
    parsed = URI.parse(ENV['BACKUP_http_proxy'])
    command += "-DproxyHost=#{parsed.host} -DproxyPort=#{parsed.port} "
  end
  command += " install #{v[:url] || v[:id]}"

  execute_version "install elasticsearch plugin #{k}" do
    command command
    version "#{k}_#{v[:id]}"
    file_storage "/usr/share/elasticsearch/.plugin_install_#{k}"
    notifies :restart, "service[elasticsearch]" if v[:restart]
  end

end

if node.logrotate[:auto_deploy]

  logrotate_file "elasticsearch" do
    files [
      "/var/log/elasticsearch/#{node.elasticsearch.cluster_name}.log",
      "/var/log/elasticsearch/#{node.elasticsearch.cluster_name}_index_indexing_slowlog.log",
      "/var/log/elasticsearch/#{node.elasticsearch.cluster_name}_index_search_slowlog.log",
      "/var/log/elasticsearch/#{node.elasticsearch.cluster_name}_deprecation.log",
    ]
    variables :copytruncate => true, :user => "elasticsearch"
  end

end