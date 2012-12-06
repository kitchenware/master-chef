default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => '037b103bd18a31945d896eb1b5db9bf2c0c1c26c',
  :node_version => '0.8.7',
  :log_level => 'debug',
  :patterns_directories => [],
}

default[:kibana] = {
  :user => 'kibana',
  :git => 'git://github.com/rashidkpc/Kibana.git',
  :version => '41a12980eea9ebc751a83b8b95d378fb1b64fb12',
  :directory => '/opt/kibana',
  :location => '/',
  :config => {
    :result_per_page => 100,
    :timezone => 'user',
    :time_format => 'mm/dd HH:MM:ss',
    :analyze_limit => 10000,
    :default_operator => 'OR',
    :elasticsearch => 'localhost:9200',
  }
}