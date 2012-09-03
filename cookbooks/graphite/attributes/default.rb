default[:graphite] = {
  :git => {
    :whisper => "git://github.com/graphite-project/whisper.git",
    :carbon => "git://github.com/graphite-project/carbon.git",
    :web_app => "git://github.com/graphite-project/graphite-web.git",
    :version => "0.9.10",
  },
  :directory => '/opt/graphite',
  :directory_install => '/opt/graphite/install',
}

default[:graphite][:graphite] = {
  :listen => "0.0.0.0:80"
}

default[:graphite][:default_retention] = "10s:1d"

default[:graphite][:timezone] = "Europe/Paris"

default[:graphite][:bucky] = {
  :url => "http://pypi.python.org/packages/source/b/bucky/bucky-0.2.2.tar.gz",
  :collectd_port => 25826,
}

default[:graphite][:carbon] = {
  :port => 2003,
}

default[:graphite][:statsd] = {
  :user => 'statsd',
  :directory => '/opt/statsd',
  :port => 8125,
  :version => 'v0.5.0',
  :node_version => '0.8.7',
  :git => 'git://github.com/etsy/statsd.git',
  :graphite_host => 'localhost',
  :graphite_port => '2003',
  :flush_interval => 10,
}