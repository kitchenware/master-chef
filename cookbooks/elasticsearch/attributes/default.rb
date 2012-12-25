
default[:elasticsearch] = {
  :user => 'elastic',
  :url => 'http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.20.1.tar.gz',
  :directory => '/opt/elasticsearch',
  :directory_data => '/opt/elasticsearch_data',
  :java_opts => '',
  :options => '',
  :host => '127.0.0.1',
  :http_port => 9200,
  :tcp_port => 9300,
  :transport_zmq => {
    :enable => true,
    :listen => 'tcp://127.0.0.1:9700',
    :url => 'http://warp-repo.s3-eu-west-1.amazonaws.com/transport-zeromq-0.0.5.zip',
  }
}