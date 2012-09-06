default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => '0b00dd969680d55163af607f3b84f0d55c6ec784',
  :node_version => '0.8.7',
  :log_level => 'debug',
}

default[:elasticsearch] = {
  :user => 'elasticsearch',
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