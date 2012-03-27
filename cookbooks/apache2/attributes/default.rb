default[:apache2][:mpm] = :prefork

default[:apache2][:mpm_config][:prefork] = {
  :start => 10,
  :min_spare => 10,
  :max_spare => 20,
  :server_limit => 256,
  :max_clients => 256,
  :max_request_per_child => 20,
}

default[:apache2][:tuning] =  {
  :server_signature => 'Off',
  :tokens => 'Prod',
  :hostname_lookups => 'On',
  :keepalive => 'On',
  :keepalive_timeout => 15,
  :max_keepalive_request => 100,
  :timeout => 300,
  :log_level => "info",
  :enable_htaccess => false,
}

default[:apache2][:modules] = ["dir"]