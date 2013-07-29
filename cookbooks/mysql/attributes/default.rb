default[:mysql] = {
  :use_percona => false,
  :percona_client_package_name => "percona-xtradb-cluster-client-5.5",
  :percona_server_package_name => "percona-xtradb-cluster-server-5.5",
  :server_package_name => "mysql-server",
  :client_package_name => "mysql-client"
}

default[:mysql][:engine_config] = {
  :mysqld => {
    :bind_address => '127.0.0.1',
    :max_allowed_packet => '16M',
  }
}

default[:mysql][:run_sql] = true
