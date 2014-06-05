default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => '643605113290776ec732c381b1acf8e30f7f846d',
  :node_version => '0.10.24',
  :log_level => 'info',
  :patterns_directories => [],
}
