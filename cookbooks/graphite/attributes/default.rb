default[:graphite] = {
  :git => {
    :whisper => "git://github.com/graphite-project/whisper.git",
    :carbon => "git://github.com/graphite-project/carbon.git",
    :web_app => "git://github.com/graphite-project/graphite-web.git",
    :version => "0.9.12",
  },
  :directory => '/opt/graphite',
  :directory_install => '/opt/graphite/install',
  :django_version => '1.4.10',
}

default[:graphite][:graphite] = {
  :listen => "0.0.0.0:80"
}

default[:graphite][:storages] = {
  :default => {
    :pattern => '.*',
    :retention => '10s:1d',
  }
}

default[:graphite][:xFilesFactor] = 0.5

default[:graphite][:timezone] = "Europe/Paris"

default[:graphite][:bucky] = {
  :version => "0.2.6",
  :collectd_port => 25826,
}

default[:graphite][:carbon] = {
  :port => 2003,
  :interface => '127.0.0.1',
}

default[:graphite][:statsd] = {
  :user => 'statsd',
  :directory => '/opt/statsd',
  :port => 8125,
  :address => '0.0.0.0',
  :version => 'v0.7.0',
  :node_version => '0.10.4',
  :git => 'git://github.com/etsy/statsd.git',
  :graphite_host => 'localhost',
  :graphite_port => '2003',
  :flush_interval => 10000,
}

default[:grafana] = {
  :url => 'http://grafanarel.s3.amazonaws.com/grafana-',
  :version => '1.8.0',
  :directory => '/opt/grafana',
  :location => '/grafana',
  :elasticsearch_index => 'grafana-dash',
}