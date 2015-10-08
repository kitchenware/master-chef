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
  :django_tags_version => "0.3.6",
  :log_days_retention => 5,
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
  :enable_udp => "False"
}

default[:graphite][:statsd] = {
  :user => 'statsd',
  :directory => '/opt/statsd',
  :port => 8125,
  :address => '0.0.0.0',
  :version => 'v0.7.2',
  :node_version => '0.10.4',
  :git => 'git://github.com/etsy/statsd.git',
  :graphite_host => 'localhost',
  :graphite_port => '2003',
  :flush_interval => 10000,
}

default[:grafana] = {
  :location => '/grafana',
  :base_url => "localhost" # set your grafana domain name here
}