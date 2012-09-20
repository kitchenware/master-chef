default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => 'b1ac99117dfbea074a49f3fb463382b96fb215c3',
  :node_version => '0.8.7',
  :log_level => 'debug',
  :patterns_directories => [],
}

default[:elasticsearch] = {
  :user => 'elastic',
  :url => 'https://github.com/downloads/elasticsearch/elasticsearch/elasticsearch-0.19.9.tar.gz',
  :directory => '/opt/elasticsearch',
  :options => '',
  :host => '127.0.0.1',
  :http_port => 9200,
  :tco_port => 9300,
}

default[:kibana] = {
  :user => 'kibana',
  :git => 'git://github.com/rashidkpc/Kibana.git',
  :version => '90a3e0f56c650844be6503c99f262e1d7ab1c262',
  :directory => '/opt/kibana',
  :location => '/',
}