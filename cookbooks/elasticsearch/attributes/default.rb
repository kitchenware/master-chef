
default[:elasticsearch] = {
  :user => 'elastic',
  :url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.0.RC1.tar.gz',
  :directory => '/opt/elasticsearch',
  :directory_data => '/opt/elasticsearch_data',
  :java_opts => '',
  :env_vars => {},
  :command_line_options => '',
  :host => '127.0.0.1',
  :http_port => 9200,
  :tcp_port => 9300,
  :cluster_name => 'elasticsearch',
  :one_node_mode => true,
  :configure_zeromq_river => {
    :enable => true,
    :address => 'tcp://127.0.0.1:9700',
  },
  :plugins => {
    :head => {
      :enable => true,
      :id => 'mobz/elasticsearch-head'
    },
    :zeromq_river => {
      :enable => true,
      :id => 'bpaquet/elasticsearch-river-zeromq/0.0.2',
      :url => 'http://github.com/bpaquet/elasticsearch-river-zeromq/releases/download/v0.0.2/elasticsearch-river-zeromq-0.0.2.zip',
    }
  }
}