default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => 'be2639e5d713abd670ddf11751b607a31fd88e55',
  :node_version => '0.10.24',
  :log_level => 'info',
  :patterns_directories => [],
}
