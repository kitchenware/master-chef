default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => '51f142663496dc6b87a813583686358e721b5955',
  :node_version => '0.10.24',
  :log_level => 'info',
  :patterns_directories => [],
  :nice => 10,
}
