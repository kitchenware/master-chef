default[:node_logstash] = {
  :user => 'logstash',
  :groups => ['adm'],
  :directory => '/opt/logstash',
  :config_directory => '/etc/logstash.d',
  :git => 'git://github.com/bpaquet/node-logstash.git',
  :version => 'cb6aed7e44dac1e195a36337420ca50468d2cc16',
  :node_version => '0.10.4',
  :log_level => 'info',
  :patterns_directories => [],
}

default[:kibana] = {
  :user => 'kibana',
  :git => 'git://github.com/rashidkpc/Kibana.git',
  :version => '90ce2c3ce5d3df3b3ee2135554d1c488607c1e84',
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