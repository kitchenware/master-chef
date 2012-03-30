default[:graphite][:packages] = {
  :whisper => {
    :url => "https://launchpad.net/graphite/0.9/0.9.9/+download/whisper-0.9.9.tar.gz",
    :version => "0.9.9",
  },
  :carbon => {
    :url => "https://launchpad.net/graphite/0.9/0.9.9/+download/carbon-0.9.9.tar.gz",
    :version => "0.9.9",
  },
  :graphite_webapp => {
    :url => "https://launchpad.net/graphite/0.9/0.9.9/+download/graphite-web-0.9.9.tar.gz",
    :version => "0.9.9",
  },
  :bucky => {
    :url => "http://pypi.python.org/packages/source/b/bucky/bucky-0.0.11.tar.gz",
    :version => "0.0.11",
  },
}

default[:graphite][:graphite] = {
  :listen => "0.0.0.0:80"
}

default[:graphite][:default_retention] = "10s:1d"

default[:graphite][:timezone] = "Europe/Paris"