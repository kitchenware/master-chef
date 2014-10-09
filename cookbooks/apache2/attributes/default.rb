default[:apache2][:mpm] = :prefork

default[:apache2][:mpm_config][:prefork] = {
  :start => 10,
  :min_spare => 10,
  :max_spare => 20,
  :server_limit => 256,
  :max_clients => 256,
  :max_requests_per_child => 20,
}

default[:apache2][:mpm_config][:worker] = {
  :start_servers => 2,
  :min_spare_threads => 25,
  :max_spare_threads => 75,
  :thread_limit => 64,
  :threads_per_child => 25,
  :max_clients => 150,
  :max_requests_per_child => 0,
}
default[:apache2][:mpm_config][:event] = {
  :start_servers => 2,
  :max_clients => 150,
  :min_spare_threads => 25,
  :max_spare_threads => 75,
  :thread_limit	=> 64,
  :thread_per_child => 25,
  :max_resquests_per_child => 0
}

default[:apache2][:tuning] = {
  :server_signature => 'Off',
  :tokens => 'Prod',
  :hostname_lookups => 'On',
  :keepalive => 'On',
  :keepalive_timeout => 15,
  :max_keepalive_request => 100,
  :timeout => 300,
  :log_level => 'info',
  :enable_htaccess => true,
  :listen_backlog => 511,
}

default[:apache2][:server_root] = "/etc/apache2"
default[:apache2][:log_directory] = "/var/log/apache2"

default[:apache2][:default_vhost] = {
  :listen => '0.0.0.0:80',
  :document_root => '/var/www',
  :enabled => true,
}

default[:apache2][:modules] = ["dir", "mime", "authz_host", "alias"]
