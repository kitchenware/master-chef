default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => 'f9c510c38412d58ef4aa5bed8fe7131d4d3c0830',
  :node_version => '0.8.16',
  :log_level => 'info',
  :patterns_directories => [],
}

default[:kibana] = {
  :user => 'kibana',
  :git => 'git://github.com/rashidkpc/Kibana.git',
  :version => 'a47c8206a9ca3c07f33a3961a1766cd93b8839e6',
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