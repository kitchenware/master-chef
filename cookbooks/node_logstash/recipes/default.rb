
include_recipe "node_logstash::purge_old"

package "apt-transport-https" if node.lsb.codename == 'wheezy'

add_apt_repository "node-logstash" do
  url "https://deb.packager.io/gh/nodelogstashpackager/node-logstash"
  key "BD33EEB8"
  key_url "https://deb.packager.io/key"
  components ["master"]
end

if node.node_logstash[:version]
  package_fixed_version "node-logstash" do
    version node.node_logstash.version
  end
else
  package "node-logstash"
end

service "node-logstash" do
  supports :status => true, :restart => true
  action auto_compute_action
end
