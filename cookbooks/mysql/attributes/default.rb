default[:mysql][:engine_config] = {
  :mysqld => {
    :bind_address => '127.0.0.1',
    :max_allowed_packet => '16M',
  }
}