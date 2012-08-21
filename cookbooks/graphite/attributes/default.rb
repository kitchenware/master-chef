default[:graphite][:packages] = {
  :whisper => {
    :url => "https://launchpad.net/graphite/0.9/0.9.10/+download/whisper-0.9.10.tar.gz",
    :version => "0.9.10",
  },
  :carbon => {
    :url => "https://launchpad.net/graphite/0.9/0.9.10/+download/carbon-0.9.10.tar.gz",
    :version => "0.9.10",
  },
  :graphite_webapp => {
    :url => "https://launchpad.net/graphite/0.9/0.9.10/+download/graphite-web-0.9.10.tar.gz",
    :version => "0.9.10",
  },
  :bucky => {
    :url => "http://pypi.python.org/packages/source/b/bucky/bucky-0.2.2.tar.gz",
    :version => "0.2.2",
  },
}

default[:graphite][:graphite] = {
  :listen => "0.0.0.0:80"
}

default[:graphite][:default_retention] = "10s:1d"

default[:graphite][:timezone] = "Europe/Paris"