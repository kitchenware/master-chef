default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => 'cb6aed7e44dac1e195a36337420ca50468d2cc16',
  :node_version => '0.10.4',
  :log_level => 'info',
  :patterns_directories => [],
}
