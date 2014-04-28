default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => 'f09ee5b01645cc2231e7a3025cb8a5d3ed9b66e1',
  :node_version => '0.10.26',
  :log_level => 'info',
  :patterns_directories => [],
}
