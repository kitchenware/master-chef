
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

default[:kibana3] = {
  :git => 'http://github.com/elasticsearch/kibana.git',
  :version => '4f1b33b316b7603ffa122296b2c2eee037ee8cfc',
  :directory => '/opt/kibana3',
  :location => '/kibana3',
}