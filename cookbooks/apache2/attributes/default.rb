default[:apache2][:mpm] = :prefork

default[:apache2][:mpm_config][:prefork] = {
  :start => 5,
  :min_spare => 5,
  :max_spare => 10,
  :max_clients => 150,
  :max_request_per_child => 20,
}