default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :no_warp => false,
  :alarm_file => '/opt/logstash/shared/on_alarm',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => '3218dc789a5afbf720a04a5f3776d248e2250134',
  :node_version => '0.10.24',
  :log_level => 'info',
  :patterns_directories => [],
  :nice => 10,
}
