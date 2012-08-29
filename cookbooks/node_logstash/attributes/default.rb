default[:node_logstash] = {
  :user => 'logstash',
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => 'd2c77e5d4650d74f6ea843faad46349c6be92dbb',
  :node_version => '0.8.7',
}