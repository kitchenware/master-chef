default[:graphite][:packages] = {
  :whisper_url => "https://launchpad.net/graphite/0.9/0.9.10/+download/whisper-0.9.10.tar.gz",
  :carbon_url => "https://launchpad.net/graphite/0.9/0.9.10/+download/carbon-0.9.10.tar.gz",
  :graphite_web_url => "https://launchpad.net/graphite/0.9/0.9.10/+download/graphite-web-0.9.10.tar.gz",
  :bucky_url => "http://pypi.python.org/packages/source/b/bucky/bucky-0.2.2.tar.gz",
}

default[:graphite][:graphite] = {
  :listen => "0.0.0.0:80"
}

default[:graphite][:default_retention] = "10s:1d"

default[:graphite][:timezone] = "Europe/Paris"