default[:node_logstash] = {
  :alarm_file => '/opt/logstash/shared/on_alarm',
  :config_directory => '/etc/node-logstash/plugins.conf.d',
  :patterns_directory => '/var/db/node-logstash/patterns',
  :alarm_file => '/var/db/node-logstash/on_alarm',
  :user => 'node-logstash',
  :patterns_directories => [],
  :nice => 10,
}
