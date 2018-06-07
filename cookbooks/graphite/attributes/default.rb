default[:graphite] = {
  :git => {
    :whisper => "git://github.com/graphite-project/whisper.git",
    :carbon => "git://github.com/bpaquet/carbon.git",
    :web_app => "git://github.com/bpaquet/graphite-web.git",
    :version => "0.9.12",
    :carbon_version => "6449af7801e6b2d0a95c3e14624c823db1230df5",
    :web_app_version => "c0ec555981783e7f89ee64b225e811cfcfcca1e2",
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

default[:graphite][:carbon] = {
  :port => 2003,
  :interface => '127.0.0.1',
  :max_updates_per_second => 500,
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

default[:grafana][:ini] = {
  :database => {
    :type => 'sqlite3'
  },
  :'log.file' => {
    :daily_rotate => false,
    :log_rotate => false,
  },
  :users => {
    :allow_sign_up => false,
    :allow_org_create => false,
    :auto_assign_org_role => 'Viewer',
  },
  :emails => {
    :welcome_email_on_sign_up => false,
  }
}

default[:graphite][:pypy] = {
  :download_url => 'https://bitbucket.org/pypy/pypy/downloads/pypy2-v6.0.0-linux64.tar.bz2',
  :deps => [
    'Twisted==18.4.0',
    'whisper==1.1.3',
  ]
}
