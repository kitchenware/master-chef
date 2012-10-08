default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => '332ebfd60803ac56c23ba9afe9b191fca70f0b04',
  :node_version => '0.8.7',
  :log_level => 'debug',
  :patterns_directories => [],
}

default[:kibana] = {
  :user => 'kibana',
  :git => 'git://github.com/rashidkpc/Kibana.git',
  :version => 'aa964a564f956e836eb8343013ba47e1c972c73b',
  :directory => '/opt/kibana',
  :location => '/',
}