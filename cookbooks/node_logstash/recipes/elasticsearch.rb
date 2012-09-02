
include_recipe "java"

base_user node.elasticsearch.user

basic_init_d "elasticsearch" do
  daemon "#{node.elasticsearch.directory}/bin/elasticsearch"
  user node.elasticsearch.user
  directory_check node.elasticsearch.directory
  options "-f " + node.elasticsearch.options
end

execute_version "install elasticsearch" do
  command(
    "cd /tmp && " +
    "rm -rf #{node.elasticsearch.directory} && " +
    "curl --location #{node.elasticsearch.url} -o #{File.basename(node.elasticsearch.url)} && " +
    "tar xvzf #{File.basename(node.elasticsearch.url)} && " +
    "mv #{File.basename(node.elasticsearch.url)[0..-8]} #{node.elasticsearch.directory} && "+
    "chown -R #{node.elasticsearch.user} #{node.elasticsearch.directory}"
  )
  version node.elasticsearch.url
  notifies :restart, resources(:service => "elasticsearch")
end

template "#{node.elasticsearch.directory}/config/elasticsearch.yml" do
  owner node.elasticsearch.user
  source "elasticsearch.yml.erb"
  mode 0644
  variables :config => node.elasticsearch.to_hash
  notifies :restart, resources(:service => "elasticsearch")
end
