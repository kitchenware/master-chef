default[:memcached] = {
  :memory => 64, # in megs
  :port => 11211,
  :bind_address => "127.0.0.1",
  :user => "nobody",
  :maxconn => 1024,
  :extra_opts => '',
}
