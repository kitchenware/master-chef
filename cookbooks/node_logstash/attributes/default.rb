default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :no_warp => false,
  :alarm_file => '/opt/logstash/shared/on_alarm',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => '98723eaaf160211cd8e0c6b9b3cdd9b316ab2ddb',
  :node_version => '0.10.24',
  :log_level => 'info',
  :patterns_directories => [],
  :nice => 10,
}
