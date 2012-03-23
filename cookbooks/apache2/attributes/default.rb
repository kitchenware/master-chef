default[:apache2][:mpm] = :prefork

default[:apache2][:mpm_config][:prefork] = {
  :start => 10,
  :min_spare => 10,
  :max_spare => 20,
  :server_limit => 256,
  :max_clients => 256,
  :max_request_per_child => 20,
}