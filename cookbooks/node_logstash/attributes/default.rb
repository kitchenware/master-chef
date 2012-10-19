default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => '03d7fcefb67a213d866d819ad781522117866cd7',
  :node_version => '0.8.7',
  :log_level => 'debug',
  :patterns_directories => [],
}

default[:kibana] = {
  :user => 'kibana',
  :git => 'git://github.com/rashidkpc/Kibana.git',
  :version => 'be41ddc6e10c9ce6835c293246f6b0969305754f',
  :directory => '/opt/kibana',
  :location => '/',
}