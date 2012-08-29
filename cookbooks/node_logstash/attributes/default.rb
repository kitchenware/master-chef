default[:logstash] = {
  :user => 'logstash',
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => '50429bb35f53772ea2e65a8fb36d23a778de77db',
  :node_version => '0.8.7',
}