default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => '8202dfc69f76bae651c4f99b2e419641b8c5602b',
  :node_version => '0.10.4',
  :log_level => 'info',
  :patterns_directories => [],
}

default[:kibana] = {
  :user => 'kibana',
  :git => 'git://github.com/rashidkpc/Kibana.git',
  :version => '6354c16176696f7575bd3ba8b68188c34f87c7c0',
  :directory => '/opt/kibana',
  :location => '/',
  :config => {
    :result_per_page => 200,
    :timezone => 'user',
    :time_format => 'mm/dd HH:MM:ss',
    :analyze_limit => 10000,
    :default_operator => 'OR',
    :elasticsearch => 'localhost:9200',
  }
}