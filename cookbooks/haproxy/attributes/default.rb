
default[:haproxy][:config] = {
  :socket => "/var/run/haproxy.socket",
  :stats => {
    :port => '127.0.0.1:8076',
    :enabled => true,
  },
  :global => {
    :maxconn => 10000,
  },
}
