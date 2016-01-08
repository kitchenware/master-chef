
include_recipe "node_logstash::purge_old"

add_apt_repository "node-logstash" do
  url "https://deb.packager.io/gh/nodelogstashpackager/node-logstash"
  key "BD33EEB8"
  key_url "https://deb.packager.io/key"
  components ["master"]
end

if node.node_logstash[:version]
  package_fixed_version "node-logstash" do
    version "#{node.node_logstash.version}.#{node.lsb.codename}"
  end
else
  package "node-logstash"
end

service "node-logstash" do
  supports :status => true, :restart => true
  action auto_compute_action
end

node.node_logstash.groups.each do |g|

  add_user_in_group node.node_logstash.user do
    group g
  end

end

delayed_exec "Remove useless logstash config files" do
  after_block_notifies :restart, "service[node-logstash]"
  block do
    updated = false
    confs = find_resources_by_name_pattern(/^#{node.node_logstash.config_directory.gsub('/', "\/")}.*$/).map{|r| r.name}
    Dir["#{node.node_logstash.config_directory}/*"].each do |n|
      unless confs.include? n
        Chef::Log.info "Removing config files #{n}"
        File.unlink n
        updated = true
      end
    end
    updated
  end
end