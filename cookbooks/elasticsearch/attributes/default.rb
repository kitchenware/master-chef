
default[:elasticsearch] = {
  :user => 'elastic',
  :url => 'http://github.com/downloads/elasticsearch/elasticsearch/elasticsearch-0.19.9.tar.gz',
  :directory => '/opt/elasticsearch',
  :options => '',
  :host => '127.0.0.1',
  :http_port => 9200,
  :tcp_port => 9300,
  :transport_zmq => {
    :enable => true,
    :listen => "tcp://127.0.0.1:9700",
    :url => "http://github.com/downloads/bpaquet/transport-zeromq/transport-zeromq-0.0.4-SNAPSHOT.zip",
  }
}