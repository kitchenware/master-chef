
default[:haproxy][:config] = {
  :socket => "/var/run/haproxy.socket",
  :stats => {
    :port => '127.0.0.1:8076',
    :enabled => true,
  },
  :global => {
    :maxconn => 10000,
    :ulimit => 50000,
    :log_config => "log /dev/log daemon warning",
  },
}
