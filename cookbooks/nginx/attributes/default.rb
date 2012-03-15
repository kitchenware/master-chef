default[:nginx][:deploy_default_config] = true
default[:nginx][:default_vhost] = {
  :listen => '0.0.0.0:80',
  :virtual_host => nil,
  :enabled => false,
  :locations => [],
}
default[:nginx][:config] = {
  :worker_connections => 100000,
}
