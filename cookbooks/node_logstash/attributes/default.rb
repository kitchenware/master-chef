default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => 'c21c19aaf9f7d5b2ebb8e2bc9f5cf3582652f38d',
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
  :git => 'git://github.com/rashidkpc/Kibana.git',
  :version => '376676cf33e5a2ce932604e1159a00db0ad17dda',
}