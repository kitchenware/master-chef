
default[:elasticsearch] = {
  :directory_data => '/opt/elasticsearch_data',
  :java_opts => nil,
  :heap_size => nil,
  :command_line_options => '',
  :host => '127.0.0.1',
  :http_port => 9200,
  :tcp_port => 9300,
  :cluster_name => 'elasticsearch',
  :one_node_mode => true,
  :allow_dynamic_scripts => true,
  :mlockall => true,
  :configure_zeromq_river => {
    :enable => true,
    :address => 'tcp://127.0.0.1:9700',
  },
  :plugins => {
    :head => {
      :enable => true,
      :id => 'mobz/elasticsearch-head'
    },
    :hq => {
      :enable => true,
      :id => 'royrusso/elasticsearch-HQ'
    },
    :kopf => {
      :enable => true,
      :id => 'lmenezes/elasticsearch-kopf',
    },
    :'elasticsearch-zeromq-torrent' => {
      :enable => true,
      :restart => true,
      :id => 'bpaquet/elasticsearch-zeromq-torrent/0.3',
      :url => 'https://github.com/bpaquet/elasticsearch-zeromq-torrent/releases/download/0.3/elasticsearch-zeromq-torrent-0.3.zip',
    }
  }
}