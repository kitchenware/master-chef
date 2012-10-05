default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => '8f7cf4401943950baae23bd25de3a6df3ff1aee2',
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
  :tcp_port => 9300,
  :transport_zmq => {
    :enable => true,
    :listen => "tcp://127.0.0.1:9700",
    :plugin_url => "bpaquet/transport-zeromq/0.0.4-SNAPSHOT",
  }
}

default[:kibana] = {
  :user => 'kibana',
  :git => 'git://github.com/rashidkpc/Kibana.git',
  :version => '90a3e0f56c650844be6503c99f262e1d7ab1c262',
  :directory => '/opt/kibana',
  :location => '/',
}