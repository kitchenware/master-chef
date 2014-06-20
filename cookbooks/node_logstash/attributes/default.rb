default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :alarm_file => '/opt/logstash/shared/on_alarm',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => 'b658f87fc66e832e99ebc98f59cfb00d34ea2f24',
  :node_version => '0.10.24',
  :log_level => 'info',
  :patterns_directories => [],
  :nice => 10,
}
