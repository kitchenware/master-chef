default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => '908c431c5c6a5de5d809399d238069250c425433',
  :node_version => '0.10.24',
  :log_level => 'info',
  :patterns_directories => [],
}
