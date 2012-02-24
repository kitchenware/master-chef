default[:nginx][:deploy_default_config] = true
default[:nginx][:config] = {
  :worker_connections => 100000,
}
