default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => 'f8827ec7a37a8f19325f06b406a1b2a5c598e810',
  :node_version => '0.10.24',
  :log_level => 'info',
  :patterns_directories => [],
  :nice => 10,
}
