default[:node_logstash] = {
  :alarm_file => '/opt/logstash/shared/on_alarm',
  :groups => ['adm'],
  :config_directory => '/etc/node-logstash/plugins.conf.d',
  :patterns_directory => '/var/db/node-logstash/patterns',
  :custom_plugins_directory => '/var/db/node-logstash/custom_plugins',
  :alarm_file => '/var/db/node-logstash/on_alarm',
  :user => 'node-logstash',
  :patterns_directories => [],
  :nice => 10,
}
